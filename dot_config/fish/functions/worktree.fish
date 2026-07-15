#!/usr/bin/env fish

function worktree --argument-names branch
    # Grab the current git repos's main directory
    set -l gitdir (git rev-parse --git-common-dir 2>/dev/null)
    if test -z "$gitdir"
        echo "worktree: not in a git repo" 1>&2
        return 1
    end
    set -l maindir (dirname (realpath $gitdir))

    # If branch not specified, attempt to pull the current branch from git
    set -l name $branch
    if test -z "$name"
        set name (git branch --show-current)
    end

    # If branch is still not found, exit 1
    if test -z "$name"
        echo "worktree: detached HEAD, use -b <branch>" 1>&2
        return 1
    end

    # Choosing a destination directory for the new worktree
    set -l dest $maindir/.worktrees/$name

    # For existing branches, check out that branch to a worktree.
    # For new branches, create a new worktree and branch from the current HEAD.
    # If no branch is specified, create a detached worktree from the current HEAD.
    set -l existing_branch 0
    if test -n "$branch"
        if git show-ref --verify --quiet refs/heads/$branch
            set existing_branch 1
            git worktree add $dest $branch; or return 1
        else
            git worktree add -b $branch $dest; or return 1
        end
    else
        # Hand the current branch off to the new worktree, and leave this
        # worktree on a detached HEAD at the same commit instead -- git won't
        # let the branch be checked out in both places at once.
        git checkout --detach; or return 1
        git worktree add $dest $name; or return 1
    end

    # Carry over uncommitted/untracked work from the current working tree to the new worktree.
    # Note: We only carry over uncommitted/untracked work when the worktree starts from
    # our current HEAD (detached or new branch). An existing branch already
    # has its own history and shouldn't be mixed with our working tree's state.
    if test $existing_branch -eq 0
        for line in (git diff --name-status HEAD)
            set -l parts (string split \t $line)
            set -l f $parts[-1]
            if test "$parts[1]" = D
                rm -f $dest/$f
            else
                mkdir -p (dirname $dest/$f)
                cp $f $dest/$f
                if string match -q 'R*' $parts[1]
                    rm -f $dest/$parts[2]
                end
            end
        end

        for f in (git ls-files --others --exclude-standard)
            mkdir -p (dirname $dest/$f)
            cp $f $dest/$f
        end
    end

    # Open the new worktree in VS Code
    if type -q code
        code $dest
    end
end
