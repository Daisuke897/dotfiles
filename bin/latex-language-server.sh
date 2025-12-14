#!/usr/bin/env bash

exec apptainer run \
     "$HOME/dotfiles/images/latex_language_server.sif" "$@"
