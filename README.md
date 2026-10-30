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

## Setup

### Requirements
- A Linux or macOS computer with [Nix](https://nixos.org/download/) and [adb](https://developer.android.com/tools/releases/platform-tools) installed, and capable of building the Linux kernel (required for sound support)
- An SD card with at least 16GB of free space

### Initial setup
> [!NOTE]
> You might want to first create a backup of the ESP partition in case you want to return to Android, or to dual-boot.  
> I also recommend backing up the factory partition. It won't be wiped, but it will be modified as it's used as the XBOOTLDR partition for systemd-boot.

- Put your SSH public key in [services.nix](services.nix), and configure Wi-Fi networks if needed (you can also do this graphically from GDM/GNOME)
- Create a new ESP of the same size containing the UKI:
```sh
# Create a 33 MiB image
$ truncate -s 33M ESP.img

# Create a FAT32 filesystem
$ mkfs.vfat -F32 -n ESP ESP.img
mkfs.fat 4.2 (2021-01-31)

# Mount the image
$ udisksctl loop-setup -f ESP.img
Mapped file ESP.img as /dev/loopX.
$ udisksctl mount -b /dev/loopX
Mounted /dev/loopX at /run/media/xxx/ESP

# Copy the UKI to the ESP
$ mkdir -p /run/media/xxx/ESP/EFI/BOOT
$ cp $(nix build .#initialUki --print-out-paths)/nixos.efi /run/media/xxx/ESP/EFI/BOOT/bootx64.efi

# Unmount the image
$ udisksctl unmount -b /dev/loopX
Unmounted /dev/loopX.
$ udisksctl loop-delete -b /dev/loopX
```

- Write the rootfs image to the SD card.

> [!NOTE]
> You can either write the image to a partition or to the entire SD card.

> [!CAUTION]
> This will wipe the target partition. Make sure to specify the correct target.

```sh
sudo e2image -ra -p "$(find $(nix build .#initialRootfs --print-out-paths) -name '*.img')" /dev/sdX
```

### Flashing
- Insert the SD card into the tablet
- Reboot it into fastboot mode:
```sh
adb reboot fastboot
```
- Flash the ESP image you created earlier, and reboot:
```sh
fastboot flash ESP ESP.img
fastboot reboot
```
The tablet will now reboot into NixOS.

### Final setup
Once the tablet has booted into the login screen, you must connect to Wi-Fi if you haven't done so in the configuration.
> [!NOTE]
> You can find the tablet's LAN address from your router panel, or by going into the GNOME Wi-Fi settings on the tablet.  
You should also be able to access it using yoganix.local as Avahi is enabled.

- Run nixos-rebuild remotely to switch to the final configuration:
```sh
nix shell nixpkgs#nixos-rebuild-ng -c nixos-rebuild switch --install-bootloader --flake .#yoganix --target-host root@192.168.XXX.XXX
```
This will rebuild the initramfs with microcode updates enabled, and setup systemd-boot as a bootloader instead of the initial UKI.

### Dual-boot setup
systemd-boot will can chainload the Android bootloader: 
copy ``EFI/Intel/efilinux.efi`` from the original ESP to ``/boot/EFI/Intel/efilinux.efi``
> [!NOTE]
> You can also find efilinux.efi in some OTA packages.

systemd-boot does not detect the power button, so you can't boot into anything from its menu.  
However, you can tell it to boot into a specific entry using bootctl, or with systemctl reboot:
```sh
# Boot into Android at the next boot
sudo bootctl set-oneshot android.conf

# Immediately reboot into Android
sudo systemctl reboot --boot-loader-entry=android.conf
```
