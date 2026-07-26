#!/bin/bash

curl -o /etc/nixos/configuration.nix https://raw.githubusercontent.com/Momi-V/NixOS/refs/heads/main/VPS/configuration.nix
nixos-rebuild switch --upgrade-all --install-bootloader

mkdir /var/dyndns
cd /var/dyndns

wget -O dyndns.bash "https://raw.githubusercontent.com/Momi-V/NixOS/refs/heads/main/VPS/dyndns.bash" && chmod +x ./dyndns.bash

read -p "DynDNS Domain: " ZONE
read -p "Auth Token: " TK

cat <<EOL > .dyndns.env
ZONE=( $ZONE )
TK=$TK
EOL

./dyndns.bash
