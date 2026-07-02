#!/bin/bash

sudo nixos-rebuild build --upgrade-all --keep-going -I nixos-config=./desktop/configuration.nix
