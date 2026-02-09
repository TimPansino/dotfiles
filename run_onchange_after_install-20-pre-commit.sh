#!/usr/bin/env fish

if test -e ./.pre-commit-config.yaml or test -e ./.pre-commit-config.yml
    if type -q pre-commit
        pre-commit install-hooks
    end
else
    echo "No pre-commit config detected, skipping install."
end

if type -q omf 
    # Update OMF
    omf update
else
    # Install OMF
    curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install -o /tmp/omf-install.fish
    fish /tmp/omf-install.fish --noninteractive
    rm /tmp/omf-install.fish
end

