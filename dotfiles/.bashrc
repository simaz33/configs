#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
force_color_prompt=yes
#PS1='[\u@\h \W]\$ '
PS1='[\033[01;32m\]\u@\h \033[00;34m\]\W\033[00m\]]\$ '
