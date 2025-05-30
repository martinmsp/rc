set -o noclobber
unset -f command_not_found_handle

HISTIGNORE=l:x
IFS=$'\t\n'

PATH="$PATH:$HOME/bin"

prompt()
{
	local pwd=

	if test "${PWD:0:${#HOME}}" = "$HOME"; then
		pwd="家${PWD:${#HOME}}"
	else
		pwd="$PWD"
	fi

	PS1="《\e[94m$pwd\e[39m》"
}

PROMPT_COMMAND[0]=prompt

# --- Abbreviations ---

..()
{
	cd ..
	l
}

but()
{
	local IFS=$' \t\n'
	local cmd=$1

	set -- $(history 2 | head -1)

	if test $# -ne 3; then
		E "I RECKON YOUR WRONG"
		return 1
	fi

	eval "$cmd $3"
}

d()
{
	cd "$@"

	if test $? -eq 0; then
		l
	fi
}

e()
{
	echo "$@"
}

E()
{
	printf "\n\t\e[91m* * * %s * * *\e[39m\n\n" "$@"
}

F()
{
	file "$(type -p $1)"
}

l()
{
	count_files "$@"
}

v()
{
	vim "$@"
}

x()
{
	exit
}

# --- File Handling ---

screenWidth()
{
	local -
	set -f
	local IFS=$'\n'

	local s=$1
	local width=0
	local i=0
	local len

	while test $i -lt ${#s}; do
		printf "%s%n" ${s:$i:1} len >/dev/null

		if test $len -lt 3; then
			let width+=1
		else
			let width+=2
		fi

		let i++
	done

	return $width
}

count_files()
{
	local -
	set -f
	local IFS=$'\n'

	local num=1
	local col=0
	local col_max=2
	local max_spacing=25
	local dir=
	local max_files=105

	if test $# -eq 1; then
		dir="$1/"
	elif test $# -gt 1; then
		E "$# ARGUMENTS? NOT IN MEXICO"
		return 1
	fi

	for file in $(ls -A $dir); do
		local spacing=$max_spacing
		local separator=
		local color=

		if test -d "$dir$file"; then
			separator=/
			color="\e[94m"
		elif test -x "$dir$file"; then
			separator=\*
			color="\e[92m"
		elif test -L "$dir$file"; then
			separator=@
			color="\e[96m"
		fi

		printf "\e[93m[$num]\e[39m$color$file\e[39m$separator"

		if test $num -le $max_files; then
			eval "d$num() { d $(printf "%q" "$dir$file"); }"
		fi

		let spacing-=${#num}
		let spacing-=2
		screenWidth $file
		let spacing-=$?
		let spacing-=${#separator}

		let num++
		let col++

		if test ${#file} -gt $max_spacing || test $col -eq $col_max; then
			printf "\n"
			col=0
			spacing=0
		fi

		while test $spacing -gt 0; do
			printf " "
			let spacing--
		done
	done

	if test $col -gt 0; then
		printf "\n"
	fi

	if test $num -le $max_files; then
		PROMPT_COMMAND[1]="set -- \$(ls -A $dir)"
	else
		PROMPT_COMMAND[1]=
	fi
}

# --- Init ---

l
