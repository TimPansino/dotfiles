
function cd 
    builtin cd $argv && pwd && ls -h
end


function grep_sed
    if [[ -z ${1+x} ]] || [[ -z ${2+x} ]]; then
        echo "Usage: grep_sed \"<grep_pattern>\" \"s/find_pattern/replace_pattern/g\""
        return -1
    end
    for f in $(grep -rl "$1" .); do 
        sed -i.bak "$2" "$f"
    end
end

function file_search
    if [[ $# -lt 1 ]]; then
        echo "Usage: file_search <some_file>"
        return -1
    end

    find . -name "*$1*" \
        -and ! -regex ".*/\.git/.*" \
        -and ! -regex ".*/\.mypy_cache/.*" \
        -and ! -regex ".*/__pycache__/.*"
end
