export PATH="/usr/local/sbin:$PATH" # For homebrew

export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it

# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# Show which branch you're on and if the branch is dirty
function parse_git_dirty {
    [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working directory clean" ]] && echo "*"
}
function parse_git_branch {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1$(parse_git_dirty)] /"
}
export PS1="\w \$(parse_git_branch)$ "

# Convenience methods for git
function gsm {
    # sm == sync merge
    _git_update "merge master --no-edit"
}
function grb {
    # rb == rebase
    _git_update "rebase master"
}
function _git_update {
    old_branch=`git branch-name`
    git checkout master && git pull && git checkout $old_branch && git $1
}