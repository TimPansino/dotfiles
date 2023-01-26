set -g theme_color_scheme user

# Base16-Monokai
# based on base16-dark section of bobthefish themes: https://github.com/oh-my-fish/theme-bobthefish/blob/0b3b522/fish_prompt.fish#L1113
# color values from https://github.com/chriskempson/base16-vim/blob/037f328/colors/base16-monokai.vim
set -l base00 272822
set -l base01 383830
set -l base02 49483e
set -l base03 75715e
set -l base04 a59f85
set -l base05 f8f8f2
set -l base06 f5f4f1
set -l base07 f9f8f5
set -l base08 f92672 # red
set -l base09 fd971f # orange
set -l base0A f4bf75 # yellow
set -l base0B a6e22e # green
set -l base0C a1efe4 # cyan
set -l base0D 66d9ef # blue
set -l base0E ae81ff # violet
set -l base0F cc6633 # brown

set -l colorfg $base02

set __color_initial_segment_exit     $base05 $base08 --bold
set __color_initial_segment_su       $base05 $base0B --bold
set __color_initial_segment_jobs     $base05 $base0D --bold

set __color_path                     $base02 $base05
set __color_path_basename            $base02 $base06 --bold
set __color_path_nowrite             $base02 $base08
set __color_path_nowrite_basename    $base02 $base08 --bold

set __color_repo                     $base0B $colorfg
set __color_repo_work_tree           $base02 $colorfg --bold
set __color_repo_dirty               $base08 $colorfg
set __color_repo_staged              $base09 $colorfg

set __color_vi_mode_default          $base03 $colorfg --bold
set __color_vi_mode_insert           $base0B $colorfg --bold
set __color_vi_mode_visual           $base09 $colorfg --bold

set __color_vagrant                  $base0C $colorfg --bold
set __color_username                 $base02 $base0D
set __color_rvm                      $base08 $colorfg --bold
set __color_virtualfish              $base0D $colorfg --bold
