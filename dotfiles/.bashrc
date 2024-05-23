#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export TERM="xterm-256color"
export EDITOR=/usr/bin/vim
export HISTCONTROL=ignoreboth:erasedups

alias ls='ls --color=auto'
alias grep='grep --color=auto'

source <(kubectl completion bash)
#source <(hcloud completion bash)

# The same prompt but without colors
#PS1='[\u@\h \W]\$ '
PS1='[\[\033[01;32m\]\u@\h \[\033[00;34m\]\W\[\033[00m\]]\$ '

complete -C /usr/bin/terraform terraform
