## Centralized build configuration for nimphea examples
## This file is automatically loaded by the Nim compiler for all examples
##
## IMPORTANT: This config.nims is loaded for ALL nim/nimble invocations in this
## directory tree. We need to detect when we're compiling a nimscript (.nims)
## vs a regular Nim (.nim) file to avoid applying ARM settings to host scripts.

import std/os, std/strutils

# Detect if we're compiling a nimscript file
# We check compileOptions to see if the target file ends with .nims
const compileOptions = staticExec("echo $*").strip()
const isNimscript = compileOptions.contains(".nims")

when not isNimscript:
  # Find nimphea package - must be installed via nimble
  const nimpheaPath = strip(staticExec("nimble path nimphea 2>/dev/null || echo ''"))
  
  when nimpheaPath.len == 0:
    static:
      echo "Error: nimphea package not found."
      echo "Please install nimphea: nimble install nimphea"
      quit(1)
  
  # Base configuration for ARM cross-compilation
  switch("path", nimpheaPath)
  switch("path", nimpheaPath / "nimphea")
  switch("path", nimpheaPath / "nimphea/cmsis")
  switch("backend", "cpp")
  switch("cpu", "arm")
  switch("os", "standalone")
  switch("cc", "gcc")
  switch("gcc.exe", "arm-none-eabi-gcc")
  switch("gcc.cpp.exe", "arm-none-eabi-g++")
  switch("mm", "arc")
  switch("opt", "size")
  switch("exceptions", "goto")
  switch("define", "useMalloc")
  switch("define", "noSignalHandler")
  
  # ARM CPU flags
  switch("passC", "-mcpu=cortex-m7")
  switch("passC", "-mthumb")
  switch("passC", "-mfpu=fpv5-d16")
  switch("passC", "-mfloat-abi=hard")
  
  # General compiler flags from libDaisy Makefile
  switch("passC", "-Wall")
  switch("passC", "-Wno-missing-attributes")
  switch("passC", "-Wno-stringop-overflow")
  switch("passC", "-fdata-sections")
  switch("passC", "-ffunction-sections")
  switch("passC", "-fno-exceptions")
  switch("passC", "-fno-rtti")
  switch("passC", "-fno-unwind-tables")
  switch("passC", "-fshort-enums")
  switch("passC", "-std=gnu++14")
  
  # Include paths from nimphea
  switch("passC", "-I" & nimpheaPath / "libDaisy/src")
  switch("passC", "-I" & nimpheaPath / "libDaisy")
  switch("passC", "-I" & nimpheaPath / "libDaisy/Drivers/STM32H7xx_HAL_Driver/Inc")
  switch("passC", "-I" & nimpheaPath / "libDaisy/Drivers/CMSIS_5/CMSIS/Core/Include")
  switch("passC", "-I" & nimpheaPath / "libDaisy/src/sys")
  switch("passC", "-I" & nimpheaPath / "libDaisy/Drivers/CMSIS-Device/ST/STM32H7xx/Include")
  switch("passC", "-I" & nimpheaPath / "libDaisy/Middlewares/ST/STM32_USB_Host_Library/Core/Inc")
  switch("passC", "-I" & nimpheaPath / "libDaisy/src/usbh")
  switch("passC", "-I" & nimpheaPath / "libDaisy/src/usbd")
  switch("passC", "-I" & nimpheaPath / "libDaisy/Middlewares/Third_Party/FatFs/src")
  switch("passC", "-I" & nimpheaPath / "libDaisy/Middlewares/ST/STM32_USB_Device_Library/Core/Inc")
  switch("passC", "-I" & nimpheaPath / "libDaisy/Middlewares/ST/STM32_USB_Host_Library/Class/MSC/Inc")
  
  # CMSIS-DSP include paths
  switch("passC", "-I" & nimpheaPath / "libDaisy/Drivers/CMSIS-DSP/Include")
  switch("passC", "-I" & nimpheaPath / "libDaisy/Drivers/CMSIS_5/CMSIS/DSP/Include")
  
  # Preprocessor defines from libDaisy Makefile
  switch("passC", "-DUSE_HAL_DRIVER")
  switch("passC", "-DSTM32H750xx")
  switch("passC", "-DHSE_VALUE=16000000")
  switch("passC", "-DCORE_CM7")
  switch("passC", "-DSTM32H750IB")
  switch("passC", "-DARM_MATH_CM7")
  switch("passC", "-DUSE_FULL_LL_DRIVER")
  switch("passC", "-DFILEIO_ENABLE_FATFS_READER")
  
  # Linker flags from libDaisy Makefile
  switch("passL", "-lc")
  switch("passL", "-lm")
  switch("passL", "-lnosys")
  switch("passL", "-Wl,--cref")
  
  # Determine boot mode from defines and set up linker script + C defines
  # Boot modes (matching libDaisy):
  # - BOOT_NONE  : App flashed directly to internal flash (0x08000000)
  # - BOOT_SRAM  : App in QSPI, bootloader loads to RAM (0x90040000)
  # - BOOT_QSPI  : App in QSPI, bootloader loads to flash (0x90040000)
  when defined(bootQspi):
    switch("passC", "-DBOOT_APP")
    switch("passL", "-T" & nimpheaPath / "libDaisy/core/STM32H750IB_qspi.lds")
  elif defined(bootSram):
    switch("passC", "-DBOOT_APP")
    switch("passL", "-T" & nimpheaPath / "libDaisy/core/STM32H750IB_sram.lds")
  # else: BOOT_NONE - flash.lds is linked in the example's .nimble make task
  
  # Optional debug mode (opt-in via -d:debug)
  when defined(debug):
    switch("opt", "none")
    switch("passC", "-g")
    switch("passC", "-ggdb")
    switch("passC", "-DDEBUG")
  
  # Optional: FatFs LFN support (opt-in via -d:useFatFsLFN)
  when defined(useFatFsLFN):
    switch("passL", "-L" & nimpheaPath / "build -lfatfs_ccsbcs")
  
  # Optional: CMSIS-DSP support (opt-in via -d:useCMSIS)
  when defined(useCMSIS):
    switch("passL", "-L" & nimpheaPath / "build -lCMSISDSP")
