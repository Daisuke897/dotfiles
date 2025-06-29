#!/bin/bash

bash ./install_images_apptainer.sh

# emacs
dpkg -s emacs-mozc &> /dev/null
if [ $? -eq 0 ]; then
    ln -s ~/dotfiles/init.el ~/.emacs.d/init.el
else
    echo "emacs-mozc is Not installed!"
    exit 1
fi
