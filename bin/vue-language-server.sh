#!/usr/bin/env bash

exec apptainer run \
     "$HOME/dotfiles/images/vue_language_server.sif" "$@"
