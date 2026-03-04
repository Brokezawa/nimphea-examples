## Shared task implementations for nimphea examples
## Include this from each example's .nimble AFTER defining `linkerScript`, `bin`, and optional `customDefines`
##
## Boot Modes:
##   BOOT_NONE  - Direct flash to internal memory (0x08000000), STM DFU PID
##   BOOT_SRAM  - Bootloader loads app from QSPI (0x90040000), Daisy PID, requires -d:bootSram
##   BOOT_QSPI  - Bootloader loads app from QSPI (0x90040000), Daisy PID, requires -d:bootQspi
##
## Usage:
##   const linkerScript = "STM32H750IB_flash.lds"
##   const customDefines = "-d:useCMSIS"  # Optional: for libraries or boot modes
##   const dfuPid = "df11"  # Optional: override USB PID for custom bootloaders
##   include "../../nimble_tasks.nims"

import os, strutils

# Allow examples to define custom build flags
when not declared(customDefines):
  const customDefines = ""

# Flash configuration - allows per-example customization
when not declared(dfuPid):
  const dfuPid = "df11"  # DFU USB Product ID (Daisy bootloader)

when not declared(flashAddressInternal):
  const flashAddressInternal = "0x08000000"  # BOOT_NONE: direct internal flash

when not declared(flashAddressQspi):
  const flashAddressQspi = "0x90040000"  # BOOT_SRAM/BOOT_QSPI: bootloader address

# Compute flash address based on boot mode (BOOT_NONE vs BOOT_SRAM/BOOT_QSPI)
let flashAddress = 
  if customDefines.contains("bootQspi") or customDefines.contains("bootSram"):
    flashAddressQspi
  else:
    flashAddressInternal

task make, "Build for ARM Cortex-M7":
  ## Build example for ARM Cortex-M7 Daisy hardware
  ## Configuration is loaded from parent config.nims
  
  let pkgPath = gorge("nimble path nimphea 2>/dev/null").strip()
  if pkgPath.len == 0:
    echo "Error: nimphea package not found."
    echo "Run 'nimble install nimphea' first."
    quit(1)
  
  # Setup build directories
  let nimcacheDir = "build/nimcache"
  mkDir("build")
  mkDir(nimcacheDir)
  
  # Compile Nim to object files (config.nims provides compiler flags)
  var nimCmd = "nim cpp --noLinking:on --nimcache:" & nimcacheDir & " "
  if customDefines.len > 0:
    nimCmd.add(customDefines & " ")
  nimCmd.add("src/" & bin[0] & ".nim")
  exec nimCmd
  
  # Collect object files
  var objs: seq[string] = @[]
  for kind, path in walkDir(nimcacheDir):
    if kind == pcFile and path.endsWith(".o"):
      objs.add(path)
  if objs.len == 0:
    echo "Error: no object files found after compile"
    quit(1)
  
  # Link with ARM cross-linker
  let lds = pkgPath / "libDaisy/core/" & linkerScript
  var linkCmd = "arm-none-eabi-g++ -o build/" & bin[0] & ".elf " & join(objs, " ")
  linkCmd.add(" -mcpu=cortex-m7 -mthumb -mfpu=fpv5-d16 -mfloat-abi=hard")
  linkCmd.add(" --specs=nano.specs --specs=nosys.specs")
  linkCmd.add(" -L" & pkgPath / "libDaisy/build -ldaisy")
  
  # Check if CMSIS or FatFs were defined and add appropriate libraries
  if customDefines.contains("useCMSIS"):
    linkCmd.add(" -L" & pkgPath / "build -lCMSISDSP")
  if customDefines.contains("useFatFsLFN"):
    linkCmd.add(" -L" & pkgPath / "build -lfatfs_ccsbcs")
  
  # Skip default -T if boot mode override is defined (check customDefines instead of when)
  if not customDefines.contains("bootSram") and not customDefines.contains("bootQspi"):
    if fileExists(lds):
      linkCmd.add(" -T" & lds)
  
  # Add remaining linker flags (others come from config.nims passL)
  linkCmd.add(" -Wl,-Map=build/" & bin[0] & ".map -Wl,--gc-sections -Wl,--print-memory-usage")
  linkCmd.add(" -Wl,--allow-multiple-definition")
  
  exec linkCmd
  
  # Generate binary and print size
  exec "arm-none-eabi-objcopy -O binary build/" & bin[0] & ".elf build/" & bin[0] & ".bin"
  exec "arm-none-eabi-size build/" & bin[0] & ".elf"
  
  echo "✓ Build complete: build/" & bin[0] & ".bin"

task clear, "Remove build artifacts for example":
  ## Remove all build artifacts (nimble clean cannot be overridden)
  if dirExists("build"):
    rmDir("build")
    echo "✓ Removed build/"

task flash, "Flash via DFU":
  ## Flash binary to Daisy via DFU
  ## Automatically detects boot mode and uses appropriate memory address
  ## Supports BOOT_NONE (internal flash) and BOOT_SRAM/BOOT_QSPI (bootloader-managed)
  
  let dfuCmd = "dfu-util -a 0 -s " & flashAddress & ":leave -D build/" & bin[0] & 
               ".bin -d ,0483:" & dfuPid
  exec dfuCmd

task stlink, "Flash via ST-Link":
  ## Flash ELF to Daisy via OpenOCD and ST-Link debugger
  ## NOTE: Only works with BOOT_NONE mode (direct internal flash)
  ##       Bootloaded modes (BOOT_SRAM/BOOT_QSPI) require DFU flashing
  
  if customDefines.contains("bootSram") or customDefines.contains("bootQspi"):
    echo "Error: ST-Link (OpenOCD) cannot be used with bootloaded modes (BOOT_SRAM/BOOT_QSPI)"
    echo "        These modes require DFU flashing. Use 'nimble flash' instead."
    quit(1)
  
  exec "openocd -f interface/stlink.cfg -f target/stm32h7x.cfg -c \"program build/" & bin[0] & ".elf verify reset exit\""
