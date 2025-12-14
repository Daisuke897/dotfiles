#!/usr/bin/env bash

exec apptainer run \
     "$HOME/dotfiles/images/eslint_language_server.sif" "$@"
