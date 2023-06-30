# foreach-object considered harmful

$env:path += ";$home\bin"
$env:path += ";C:\Program Files (x86)\Vim\vim90"
$env:path += ";C:\program files\llvm\bin"
$env:path += ";C:\program files\git\bin"
$env:path += ";C:\program files\cmake\bin"
$env:path += ";C:\Program Files (x86)\GnuWin32\bin"
$env:path += ";C:\Program Files\7-Zip"

set-psreadlineoption -colors @{command="`e[39m";operator="`e[39m";parameter="`e[39m"}

function ..
{
	cd ..
	l
}

### C ###

function x
{
	exit
}

### D ###

function d
{
	param ($path)

	switch -regex ($path) {
		'^[-+]$' {
			set-location $path
			break
		}
		default {
			$path = $path ? $path : $home
			if (test-path $path -pathtype container) {
				set-location $path
			}
			else {
				return E "you dumb motherfucker"
			}
		}
	}
	tour
	countFiles
}

function dh
{
	param ($path)

	d "$home\$path"
}

### E ###

function E
{
	param ($msg)

	write-host "`n`t`e[91m* * * $msg * * *`n"
}

### G ###

function 关电脑
{
	stop-computer
}

### H ###

function hklm
{
	param ($path)

	return "HKLM:\software\microsoft\windows nt\currentversion\$path"
}

### L ###

function l
{
	countFiles
}

function ll
{
	clear
	d .
}

### P ###

function prompt
{
	$location = $($(get-location) -replace ".+\\.+\\$env:username", '家')

	return "`e[91m那么。我们开始。《`e[93m$location`e[91m》`e[39m"
}

### R ###

function rc
{
	param ($path)

	remove-item -confirm $path
}

### S ###

$global:colmax = 2

function countFilesWrite
{
	param ($num, $name, $col)
	$num = "[$num]"
	$filecolor = ""
	$separator = ""
	$spacing = 31

	if (test-path $name -pathtype container) {
		$filecolor = "`e[96m"
		$separator = "`e[39m\"
	}
	elseif ($name -like "*.exe") {
		$filecolor = "`e[92m"
	}

	write-host "`e[39m$num$filecolor$name$separator" -nonewline

	#
	# actually you have to go through the entire string to determine the proper length
	#
	if (stringWide $name)
		{ $spacing = $spacing -gt $name.length ? $spacing - $name.length : $spacing }

	if ($separator)
		{ $spacing-- }

	if ($name.length -gt $spacing) {
		write-host
		$col = 0
		return $col
	}

	$spacing -= $num.length
	$spacing -= $name.length

	while ($spacing -gt 0) {
		write-host ' ' -nonewline
		$spacing--
	}
	$col++
	if ($col -eq $colmax) {
		write-host
		$col = 0
	}
	return $col
}

function countFiles
{
	$i = 1
	$max = 105
	$col = 0
	$force = ""

	if ((get-location).path -ne $home)
		{ $force = "-force" }

	foreach ($file in invoke-expression "get-childitem $force") {
		$file = $file.name
		$col = countFilesWrite $i $file $col
		invoke-expression "`$global:$i = `"$file`""
		invoke-expression "function global:d$i { d `"$file`" }"
		$i++
		if ($i -gt $max)
			{ return E "很多文件" }
	}

	if ($col -gt 0)
		{ write-host }
}

### T ###

function tour
{
	$tour = ".\_tour"

	if (test-path $tour)
		{ $('"' + $(get-content $tour) + '"') | write-host -foregroundcolor "white" }
}

### W ###

function wfunction
{
	param ($f)

	get-content "function:\$f"
}

### V ###

function v
{
	param ($path)

	gvim $path
}

### Z ###

function stringWide
{
	param ($s)

	return ($s.length * 3 -eq [system.text.encoding]::utf8.getbytecount($s))
}

#
# --- Init ---
#

countFiles
