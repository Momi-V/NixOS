echo "Wiping Drives"
swapoff -a
umount /dev/vda*
wipefs -a /dev/vda*
sleep 1

echo "Creating Partitions"
cat <<'EOL' | sfdisk /dev/vda
label: gpt
size=512M type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B
size=40G
type=swap
EOL
sleep 1

echo "Formatting Filesystems"
mkfs.fat -F 32 -n NIXBOOT /dev/vda1
mkfs.btrfs /dev/vda2 -L NIXROOT
mkswap /dev/vda3
sleep 1

echo "Mounting Filesystems"
swapon /dev/vda3
mount /dev/disk/by-label/NIXROOT /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/NIXBOOT /mnt/boot
sleep 1

echo "Generating and Fetching config"
nixos-generate-config --root /mnt
curl -o /mnt/etc/nixos/configuration.nix https://raw.githubusercontent.com/Momi-V/NixOS/refs/heads/main/pangolin/configuration.nix
sleep 1

echo "Patching Config (no envfs during install)"
cp /mnt/etc/nixos/configuration.nix /mnt/etc/nixos/configuration.nix.envfs
sed -i 's+services.envfs.enable+#services.envfs.enable+g' /mnt/etc/nixos/configuration.nix
sed -i 's+programs.nix-ld.enable+#programs.nix-ld.enable+g' /mnt/etc/nixos/configuration.nix
sleep 1

echo "Installing NixOS"
cd /mnt
nix-channel --update
nixos-install
sleep 1

echo "Copying root SSH keys and restoring config"
cp -r /root/.ssh/ /mnt/root/
mv /mnt/etc/nixos/configuration.nix.envfs /mnt/etc/nixos/configuration.nix
sleep 1
