# ~/.bashrc
#
# hiasystem / bashrc
# Version:
#	2022-05-29.1 alias tmux-='tmux attach || tmux' hinzugefügt.
#	2022-05-29.0 Bug in $PS1 behoben.
#	2024-04-27.0 Alias  tmux-  macht jetzt auch  && exit  .
#	2024-08-24.0 Aliases sind Ausgelagert damit auch zsh die selben benutzen kann.
#	2024-08-24.1 Helferfunktion zum laden von Konfigurationsdateien.
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return


colors() {
	local fgc bgc vals seq0

	printf "Color escapes are %s\n" '\e[${value};...;${value}m'
	printf "Values 30..37 are \e[33mforeground colors\e[m\n"
	printf "Values 40..47 are \e[43mbackground colors\e[m\n"
	printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

	# foreground colors
	for fgc in {30..37}; do
		# background colors
		for bgc in {40..47}; do
			fgc=${fgc#37} # white
			bgc=${bgc#40} # black

			vals="${fgc:+$fgc;}${bgc}"
			vals=${vals%%;}

			seq0="${vals:+\e[${vals}m}"
			printf "  %-9s" "${seq0:-(default)}"
			printf " ${seq0}TEXT\e[m"
			printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
		done
		echo; echo
	done
}

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Change the window title of X terminals
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
esac

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	#echo 'debug: lastlog: >'$(lastlog -u $USER | tail -n 1 | cut -b27-27)'<'
	# Farbe für Hostname festlegen
	# Prüfen ob die Session via SSH oder lokal läuft.
	if [ -n "$SSH_CONNECTION" ] ; then
		#echo Remote       33=Gelb
		host_them='\033[01;33m\]'
	else
		#echo Lokal        32=Grün
		host_them='\033[01;32m\]'
	fi

	# Prüfen ob ich root bin und Prompt setzen.
	if [[ ${EUID} == 0 ]] ; then
		PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
	else
		# Farbe für Hostname festlegen
		# Prüfen ob die Session via SSH oder lokal läuft.
		if [ -n "$SSH_CONNECTION" ] ; then
			#echo Remote       33=Gelb	
			PS1='\[\033[01;32m\][\u@\[\033[01;33m\]\h \[\033[01;00m\]\W\[\033[01;32m\]]\$\[\033[00m\] '
			#    ^^^^^^^^^^^^^^^    ^^^^^^^^^^^^^^^   ^^^^^^^^^^^^^^^  ^^^^^^^^^^^^^^^   ^^^^^^^^^^^^
			#host_them='\033[01;33m\]'
		else
			#echo Lokal        32=Grün
			#----_______________----________
			PS1='\[\033[01;32m\][\u@\[\033[01;32m\]\h \[\033[01;00m\]\W\[\033[01;32m\]]\$\[\033[00m\] '
			#    ^^^^^^^^^^^^^^^    ^^^^^^^^^^^^^^^   ^^^^^^^^^^^^^^^  ^^^^^^^^^^^^^^^   ^^^^^^^^^^^^
			#   '\[\033[01;31m\]                      \W\[\033[01;31m\]]\$\[\033[00m\] '
			#host_them='\033[01;32m\]'
		fi

		#PS1='\[\033[01;32m\][\u@\033[01;32m\]\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
		#Prompt^^^^^^^^^^^^^    ^^^^^^^^^^^^^
		#      User    ||       Host    ||
		#        Color_||_______________||
	fi

		# Helferfunktion zum laden von Konfigurationsdateien.
		loadSource(){
		if [ -r $1 ]; then
			source $1
		fi
		}

		# Aliases laden
		loadSource /opt/hiasystem/config/shellaliases
		loadSource ~/.config/shellaliases

else
	if [[ ${EUID} == 0 ]] ; then
		# show root@ when we don't have colors
		PS1='\u@\h \W \$ '
	else
		PS1='\u@\h \w \$ '
	fi
fi

unset use_color safe_term match_lhs sh
