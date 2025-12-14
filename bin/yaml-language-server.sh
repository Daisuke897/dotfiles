#!/usr/bin/env bash

exec apptainer run \
     "$HOME/dotfiles/images/yaml_language_server,sif" "$@"
