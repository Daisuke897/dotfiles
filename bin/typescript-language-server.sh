#!/usr/bin/env bash

exec apptainer run \
     "$HOME/dotfiles/images/typescript_language_server.sif" "$@"
