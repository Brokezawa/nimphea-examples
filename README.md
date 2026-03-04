# Nimphea Examples

This repository contains a collection of examples for the Nimphea Nim wrapper for the Daisy Audio Platform.

## Structure

Each example is a standalone Nim project located in the `examples/` directory.

## How to Build and Flash

To build and flash an example, you should have Nimphea installed via Nimble:

```bash
nimble install nimphea
```

Then, navigate to the example directory:

```bash
cd examples/blink
nimble make
nimble flash # Via USB DFU
# OR
nimble stlink # Via ST-Link probe
```

## Boot Modes

Examples support three boot modes controlled by compiler defines in `project.nimble`:

### BOOT_NONE (Default)
- Direct flash to internal flash (0x08000000)
- No bootloader required
- Best for development and simple projects
- Use with `nimble stlink` (ST-Link) or `nimble flash` (DFU)

### BOOT_SRAM
- Application runs from SRAM (0x20000000), loaded by DFU bootloader
- Requires pre-installed DFU bootloader on device
- Allows iterative development without re-flashing bootloader
- Limited to ~512KB (SRAM size)
- Use: Add `-d:bootSram` to `customDefines` in project.nimble
- Flash with `nimble flash` (DFU only)

### BOOT_QSPI
- Application stored in QSPI flash (0x90040000)
- Requires DFU bootloader with QSPI support
- Provides 128MB additional storage for large applications
- Essential for applications with large libraries (e.g., CMSIS-DSP)
- Use: Add `-d:bootQspi` to `customDefines` in project.nimble
- Flash with `nimble flash` (DFU only)

For detailed information, see [BOOT_MODES.md](../nimphea/docs/BOOT_MODES.md).

## Optional Libraries

Examples can opt-in to additional libraries via compiler defines:

### CMSIS-DSP
- Optimized ARM math and signal processing functions
- ~1MB library - requires BOOT_QSPI mode due to size
- Add `-d:useCMSIS` to `customDefines` in project.nimble
- Example: `cmsis_demo` demonstrates FFT capabilities

### FatFs LFN
- Long filename support for file operations
- Enables filenames longer than 8.3 characters
- Add `-d:useFatFsLFN` to `customDefines` in project.nimble
- Used with QSPI storage for complex file systems

For more details, see [BUILD_SYSTEM.md](../nimphea/docs/BUILD_SYSTEM.md).

## Hardware Testing

For detailed instructions on how to set up your hardware for these examples, please refer to the [Hardware Testing Guide](TESTING_GUIDE.md).

## List of Examples

### Basic
- **blink**: The classic LED blink example.
- **cmsis_demo**: Demonstrates optimized ARM math functions.

### Audio
- **audio_demo**: Stereo passthrough, sine wave, and distortion.
- **codec_comparison**: Automatic codec detection for different hardware versions.

### Controls and Peripherals
- **adc_demo**: Reading potentiometers and multiplexers.
- **gpio_demo**: Button and LED interactions.
- **pwm_demo**: LED fading, RGB rainbow, and servo control.
- **encoder**: Rotary encoder reading.

### Communication
- **comm_demo**: I2C scanner and SPI communication.
- **usb_serial**: Virtual serial port over USB.
- **midi_demo**: MIDI I/O via USB and UART.

### Display
- **oled_basic**: Text display on SSD1306.
- **oled_graphics**: Drawing shapes.
- **oled_spi**: SPI-based OLED communication.
- **oled_visualizer**: Real-time audio waveform/metering.
- **ui_demo**: Full UI framework showcase.

### Storage and System
- **sdram_test**: External memory verification.
- **storage_demo**: QSPI flash and settings management.
- **system_demo**: System clock info and logging.
- **panicoverride**: Rapid LED blink on system crash.
