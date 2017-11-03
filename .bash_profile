source ~/.alias

export PATH="/usr/local/sbin:$PATH" # For homebrew

export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it

# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

# virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
source /usr/local/bin/virtualenvwrapper.sh

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

# Install/update Python requirements
function venvup {
    if [ -z $WORKON_HOME ]
    then
        >&2 echo "WORKON_HOME must be set"
        return
    fi

    type virtualenvwrapper &> /dev/null
    if [ $? -ne 0 ]
    then
        >&2 echo "virtualenvwrapper must be installed"
        return
    fi

    venv_name=$(basename $(pwd))
    venv_path=$WORKON_HOME/$venv_name

    if [ ! -e $venv_path ]
    then
        mkvirtualenv $venv_name
    fi

    if [ "$VIRTUAL_ENV" != "$venv_path" ]
    then
        workon $venv_name
    fi

    if [ -e tests/integration/requirements.txt ]
    then
        requirements_file="tests/integration/requirements.txt"
    else
        requirements_file="requirements.txt"
    fi

    pip install --upgrade pip
    pip install -r $requirements_file
}
