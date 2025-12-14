#!/usr/bin/env bash

exec apptainer run \
     "$HOME/dotfiles/images/rust_language_server.sif" "$@"
