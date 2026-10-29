# NixOS for the Lenovo Yoga Tablet 2 830L

This repo contains a NixOS configuration for the Lenovo Yoga Tablet 2 830L,
an Android tablet based on the Intel Atom Z3745, an x86_64 processor part of the Bay Trail series of low-power SOCs.

The Yoga Tablet 2 830L is very similar to the 830F, 1050F/L, 1380F/L, so this configuration should work on those as well.


## Hardware

### Working
- Intel integrated graphics
- Built-in SD card slot
- Broadcom Wi-Fi (BCM43241B4)
- Broadcom Bluetooth (BCM4324B3)
- Synaptics touchscreen (RMI, I2C-based)
- Backlight controller (LP8557)
- Accelerometer (LSM303DA)
- Ambient light sensor (AL3320A)
- Built-in speakers and microphone (WM5102) (requires recompiling the kernel)
- Battery charge status
- Suspend and wake

### Non-working
- Front and rear cameras

### Untested
- USB OTG support
- LTE modem (likely unsupported)

## Dual-boot setup
Copy the Android bootloader from EFI/Intel/efilinux.efi in the EFI system partition to the XBOOTLDR partition in /boot/EFI/Intel/efilinux.efi
