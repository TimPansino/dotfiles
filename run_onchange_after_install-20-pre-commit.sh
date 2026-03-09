#!/usr/bin/env fish

if test -e ./.pre-commit-config.yaml; or test -e ./.pre-commit-config.yml
    if type -q pre-commit
        pre-commit install-hooks
    end
else
    echo "No pre-commit config detected, skipping install."
end

