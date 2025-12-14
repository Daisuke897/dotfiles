#!/usr/bin/env bash

exec apptainer run \
     "$HOME/dotfiles/images/python_pyright.sif" "$@"
