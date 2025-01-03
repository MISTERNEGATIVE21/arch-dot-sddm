#!/usr/bin/env bash
set -e

if ! pacman -Qs chezmoi >/dev/null 2>&1; then
    sudo pacman -S --noconfirm chezmoi
fi

# some package instllations take place here as well
chezmoi init && chezmoi apply

rm -rf ~/.rebos-base
rebos setup
rebos gen commit "Install sync"
rebos gen current build
rebos gen tidy-up
