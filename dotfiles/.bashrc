#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias share_one_screen='vlc --no-video-deco --no-embedded-video --screen-fps=20 --screen-top=32 --screen-left=0 --screen-width=1920 --screen-height=1080 screen:// 2>&1 > /dev/null &'
force_color_prompt=yes
#PS1='[\u@\h \W]\$ '
PS1='[\[\033[01;32m\]\u@\h \[\033[00;34m\]\W\[\033[00m\]]\$ '

export TERM="xterm-256color"
