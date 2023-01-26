# Shorthand
alias c="clear"
alias ..="cd .."
alias .="pwd; and ls -h"

# Python Shorthand
alias venv="python -m venv"
alias pipreq="pip install -r requirements.txt" 
set tox_path (which tox)
alias tox="PIP_REQUIRE_VIRTUALENV=false $tox_path"

# Docker Shorthand
alias dk="docker"
alias dc="docker-compose"
alias dr="docker-compose down; and docker-compose up -d"
alias drl="dc down; and dc up -d --build; and dc logs -f"
alias dl="dc logs -f"
alias dkip="docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}'"
alias mr="make down; and make up"
alias mrl="make down; and make up; and make logs"
alias ml="make logs"

# Debian Shorthand
alias update="sudo apt update -y; and sudo apt upgrade -y; and sudo apt full-upgrade -y; and sudo apt autoremove -y"
alias apt="sudo apt"
alias apt-get="sudo apt-get"
alias halt="sudo halt"
alias reboot="sudo reboot"
alias rand_secret="dd if=/dev/urandom bs=1k count=1 2>/dev/null | base64 --wrap=0 | tr -dc 'a-zA-Z0-9' | head -c"

# Other Shorthand
alias curltime="curl -w \"@$HOME/.curl-format.txt\" -o /dev/null -s "

# Settings
set -g theme_nerd_fonts yes
set -g theme_powerline_fonts no
set -g theme_color_scheme terminal2-dark
set -g theme_display_user no
set -g theme_display_hostname no
set -g VIRTUAL_ENV_DISABLE_PROMPT 1
set -g HOMEBREW_NO_ANALYTICS 1

# Path Settings
if type -q thefuck
    thefuck --alias | source
end
if test -d ~/.local/bin 
    set PATH $PATH ~/.local/bin
end

# Source local config
if test -f ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end

# Custom functions
function cd 
    builtin cd $argv; and pwd; and ls -h
end

function srv
  cd /srv
  if test (id -u) -ne 0
    sudo su
  end
end

function pidport -a PID
    lsof -n -i4TCP:$PID | grep LISTEN
end

function zipit -a folder
    zip -r $folder.zip $folder/*
end

# Create venv
function venvi -a PYTHON_VERSION
    # Deactivate existing venv
    if type -q deactivate
        deactivate
    end

    # Remove existing venv folder
    if test -e .venv
        rm -rf .venv
    end

    # Set python executable
    if test -n "$PYTHON_VERSION"
        if string match -qr '^\d' "$PYTHON_VERSION"
            # string starts with a digit
            set PYTHON "python$PYTHON_VERSION"
        else
            set PYTHON "$PYTHON_VERSION"
        end
    else
        set PYTHON "python"
    end

    if ! type -q "$PYTHON"
        echo "Executable not found: $PYTHON" >&2
        return 1
    end

    # Create venv
    begin
        $PYTHON -m venv .venv
        or $PYTHON -m virtualenv .venv
    end
    and venva
end

# Activate venv
function venva -a VENV_DIR
    if test -z $VENV_DIR
        if test -d venv
            source ./venv/bin/activate.fish
        else if test -d .venv
            source ./.venv/bin/activate.fish
        else
            echo "Cannot find virtual environment directory."
            return 1
        end
    else
        source $VENV_DIR/bin/activate.fish
    end
end

# Create and activate tox venv
function toxeva -a TOX_ENV
    if test -z $TOX_ENV
        echo "Usage: toxva <environment>" 1>&2
        tox -l
        return 1
    else
        tox -e $TOX_ENV --notest --develop
        source ./.tox/$TOX_ENV/bin/activate.fish
        set -gx PYTHONPATH tests/
        set -u NEW_RELIC_CONFIG_FILE
        pip install -e .
    end
end

# Activate tox venv
function toxva -a TOX_VENV_DIR
    if test ! -d ./.tox
        echo "No .tox directory found." 1>&2
        return 1
    else if test -z $TOX_VENV_DIR
        echo "Usage: toxva <environment>" 1>&2
        tox -l
        return 1
    else if test ! -d ./.tox/$TOX_VENV_DIR
        echo "Environment $TOX_VENV_DIR not found. Has it been created yet?" 1>&2
        ls ./.tox/
        return 1
    else
        source ./.tox/$TOX_VENV_DIR/bin/activate.fish
        set -gx PYTHONPATH tests/
        set -u NEW_RELIC_CONFIG_FILE
        pip install -e .
    end
end

# Run tox and view coverage
function toxcov -a TOX_ENV -a PORT
    if test -z $TOX_ENV
        echo "Usage: toxcov [environment] [port]"
    else
        tox -e $TOX_ENV
        set TOX_COVERAGE_DIR "./.tox/$TOX_ENV/htmlcov"
        if test -d $TOX_COVERAGE_DIR
            python -m http.server --bind=localhost -d $TOX_COVERAGE_DIR $PORT
        end
    end
end

# Run tox and diff coverage
function toxcovdiff -a TOX_ENV1 -a TOX_ENV2 -a PORT
    set COV_DIR "./cov"
    set COV_FILE1 ".tox/$TOX_ENV1/coverage.xml"
    set COV_FILE2 ".tox/$TOX_ENV2/coverage.xml"
    test -z "$PORT"; and set PORT 8000 
    test "$PORT" -gt 0; or echo "Port not set."

    # Check for proper usage
    if test -z $TOX_ENV2
        echo "Usage: toxcovdiff <enviornment1> <environment2>" 
        return 1
    end

    # Run tox for any missing environments
    echo "Running coverage..."
    if test ! -f $COV_FILE1
        tox -e $TOX_ENV1; or return
    end
    if test ! -f $COV_FILE2
        tox -e $TOX_ENV2; or return
    end

    # Clean out old coverage dir
    if test -d $COV_DIR
        rm -rf $COV_DIR
    end

    # Copy all coverage files into new coverage dir
    echo "Copying coverage files..."
    mkdir -p $COV_DIR
    echo "*" > $COV_DIR/.gitignore
    cp -r ".tox/$TOX_ENV1/htmlcov" "$COV_DIR/htmlcov_$TOX_ENV1"; or return
    cp -r ".tox/$TOX_ENV2/htmlcov" "$COV_DIR/htmlcov_$TOX_ENV2"; or return
    cp "$COV_FILE1" "$COV_DIR/$TOX_ENV1.xml"; or return
    cp "$COV_FILE2" "$COV_DIR/$TOX_ENV2.xml"; or return

    # Resetting variables
    set COV_FILE1 "$COV_DIR/$TOX_ENV1.xml"
    set COV_FILE2 "$COV_DIR/$TOX_ENV2.xml"

    # Sedding coverage files to rename source files
    echo "Sedding coverage files..."
    sed -i ".b" "s/\.tox.*site-packages.//g" $COV_FILE1
    sed -i ".b" "s/\.tox.*site-packages.//g" $COV_FILE2
    rm $COV_DIR/*.b

    # Run diff on files
    echo "Running diff..."
    echo "$COV_FILE1 $COV_FILE2"
    set DIFF_LINE_CT (diff -y --suppress-common-lines $COV_FILE1 $COV_FILE2 | wc -l)
    if test "$DIFF_LINE_CT" -le 1
        echo "Coverage is identical. Skipping server."
        return 0
    else if test "$PORT" -gt 0
        pycobertura diff \
            -s1 ".tox/$TOX_ENV1/" \
            -s2 ../../ \
            $COV_FILE1 $COV_FILE2 \
            -f html --output "$COV_DIR/diff.html"

        # Start http server
        echo "Starting http server..."
        python -m http.server --bind=localhost -d "$COV_DIR" "$PORT"
        return 0
    else
        echo "Coverage differs and server disabled. Exiting."
        return 1
    end
    return 0  # catch all
end

function mega-linter
    set BRANCH (git rev-parse --abbrev-ref HEAD)
    if test -e report/mega-linter.log
        rm -rf report
    end
    /usr/local/bin/mega-linter-runner $argv
    git checkout -m $BRANCH
end

function sdist
    set tarball (python setup.py --fullname)".tar.gz"
    python setup.py sdist
    openssl md5 -binary dist/$tarball | xxd -p | tr -d '\n' > dist/$tarball.md5
end

# Source local config file
if test -f ~/.config.local.fish
    source ~/.config.local.fish
end

