#!/bin/bash

sudo nixos-rebuild build --upgrade-all -I nixos-config=./desktop/configuration.nix
