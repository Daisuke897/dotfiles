#!/usr/bin/env bash

exec apptainer run \
     "$HOME/dotfiles/images/fortran_language_server.sif" "$@"
