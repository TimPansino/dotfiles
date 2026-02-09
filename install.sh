#!/bin/sh
set -eu

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

if ! chezmoi="$(command -v chezmoi)"; then
  bin_dir="${HOME}/.local/bin"
  chezmoi="${bin_dir}/chezmoi"
  chezmoi_install_script="${script_dir}/install_chezmoi.sh"
  echo "Installing chezmoi to '${chezmoi}'" >&2
  ${chezmoi_install_script} -b "${bin_dir}"
  unset chezmoi_install_script bin_dir
fi

echo "Initializing chezmoi"
"${chezmoi}" init --source="${script_dir}"
echo "Applying files from chezmoi"
"${chezmoi}" apply
echo "chezmoi succeeded!"