# Pangolin quickinstall

## NixOS LiveBoot
```
curl -L https://github.com/nix-community/nixos-images/releases/latest/download/nixos-kexec-installer-x86_64-linux.tar.gz | tar -xzf- -C /root
/root/kexec/run
```

## Install NixOS
```
curl -O https://raw.githubusercontent.com/Momi-V/NixOS/refs/heads/main/VPS/setup.bash
bash setup.bash
```

## Setup Pangolin with autoupdate on reboot
```
wget https://raw.githubusercontent.com/Momi-V/NixOS/refs/heads/main/VPS/install.bash
bash install.bash
```
