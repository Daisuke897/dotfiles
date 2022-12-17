#!/bin/bash

# emacs
dpkg -s emacs-mozc &> /dev/null
if [ $? -eq 0 ]; then
    ln -s ~/dotfiles/init.el ~/.emacs.d/init.el
else
    echo "emacs-mozc-bin is Not installed!"
    exit 1
fi
