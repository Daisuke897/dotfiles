#!/usr/bin/env bash

exec apptainer run \
     "$HOME/dotfiles/images/marksman_x64.sif" "$@"
