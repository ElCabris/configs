#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias tree='tree -C'
PS1='[\u@\h \W]\$ '

# Habilitar bash-completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm


# Created by `pipx` on 2024-10-22 05:44:09
export PATH="$PATH:/home/elcabris/.local/bin"

# Vina
export PATH="$PATH:/home/elcabris/Documents/scientific-computing/period-3/biologia/autodock_vina_1_1_2_linux_x86/bin"


# Load Angular CLI autocompletion.
source <(ng completion script)
export PATH="/opt/jdt/bin:$PATH"

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# gopls PATH
export PATH="$PATH:$HOME/go/bin/"


# delete
export PATH="$PATH:/home/elcabris/Documents/scientific-computing/period-4/chemistry_2/Multiwfn_3.8_dev_bin_Linux"
export Multiwfnpath="/home/elcabris/Documents/scientific-computing/period-4/chemistry_2/Multiwfn_3.8_dev_bin_Linux"
export KMP_STACKSIZE=200M
ulimit -s unlimited

alias luamake="/home/elcabris/lua-language-server/3rd/luamake/luamake"
alias vimdiff="nvim -d"


alias pmv='/home/elcabris/Documents/scientific-computing/period-3/biologia/mgltools_x86_64Linux2_1.5.7/bin/pmv'
alias adt='/home/elcabris/Documents/scientific-computing/period-3/biologia/mgltools_x86_64Linux2_1.5.7/bin/adt'
alias vision='/home/elcabris/Documents/scientific-computing/period-3/biologia/mgltools_x86_64Linux2_1.5.7/bin/vision'
alias pythonsh='/home/elcabris/Documents/scientific-computing/period-3/biologia/mgltools_x86_64Linux2_1.5.7/bin/pythonsh'

export PATH="$PATH:$HOME/flutter/bin"
