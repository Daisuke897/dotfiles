#!/usr/bin/env bash

exec apptainer run \
     "$HOME/dotfiles/images/json_language_server.sif" "$@"
