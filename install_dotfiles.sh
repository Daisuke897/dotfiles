#!/bin/bash

mkdir -p def_files/

apptainer build \
	  images/julia_language_server.sif \
	  def_files/julia_language_server.def

apptainer build \
	  images/fortran_language_server.sif \
	  def_files/fortran_language_server.def

# emacs
dpkg -s emacs-mozc &> /dev/null
if [ $? -eq 0 ]; then
    ln -s ~/dotfiles/init.el ~/.emacs.d/init.el
else
    echo "emacs-mozc is Not installed!"
    exit 1
fi
