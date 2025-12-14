#!/usr/bin/env bash

exec apptainer run \
     "$HOME/dotfiles/images/julia_language_server.sif" "$@"
