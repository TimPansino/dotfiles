#!/usr/bin/env fish

if type -q omf 
    # Update OMF
    omf update
else
    # Install OMF
    curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
end
