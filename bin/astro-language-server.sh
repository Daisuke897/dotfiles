#!/usr/bin/env bash

exec apptainer run \
     "$HOME/dotfiles/images/astro_language_server.sif" "$@"
