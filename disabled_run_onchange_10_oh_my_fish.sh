#!/bin/sh

# Uninstall existing installation



# Install OMF

SCRIPT_TMP=/tmp/omf_install.fish

curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install -o $SCRIPT_TMP
chmod +x $SCRIPT_TMP
fish $SCRIPT_TMP --noninteractive
rm $SCRIPT_TMP

