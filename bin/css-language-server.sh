#!/usr/bin/env bash

exec apptainer run \
     "$HOME/dotfiles/images/css_language_server.sif" "$@"
