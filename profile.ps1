# foreach-object considered harmful

$env:path += ";$home\bin"
$env:path += ";C:\Program Files (x86)\Vim\vim90"
$env:path += ";C:\program files\llvm\bin"
$env:path += ";C:\program files\git\bin"
$env:path += ";C:\program files\cmake\bin"
$env:path += ";C:\Program Files (x86)\GnuWin32\bin"
$env:path += ";C:\Program Files\7-Zip"

set-psreadlineoption -colors @{command="`e[39m";operator="`e[39m";parameter="`e[39m"}

function prompt
{
	$location = $($(get-location) -replace ".+\\.+\\$env:username", '家')

	return "`e[91m那么。我们开始。《`e[93m$location`e[91m》`e[39m"
}

# --- Abbreviations ---

function ..
{
	cd ..
	l
}

function x
{
	exit
}

function E
{
	param ($msg)

	write-host "`n`t`e[91m* * * $msg * * *`n"
}

function 关电脑
{
	stop-computer
}

function hklm
{
	param ($path)

	return "HKLM:\software\microsoft\windows nt\currentversion\$path"
}

function l
{
	param ($path)

	countFiles $path
}

function rc
{
	param ($path)

	remove-item -confirm $path
}

function v
{
	param ($path)

	gvim $path
}

# --- File Handling ---

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

$global:colmax = 2

function countFilesWrite
{
	param ($file, $num, $name, $col)
	$num = "[$num]"
	$filecolor = ""
	$separator = "`e[39m"
	$max_spacing = 31
	$spacing = $max_spacing

	if (test-path $file.fullname -pathtype container) {
		$filecolor = "`e[96m"
		$separator += "\"
		$spacing--
	} elseif ($file.fullname -like "*.exe") {
		$filecolor = "`e[92m"
		$separator += "*"
		$spacing--
	} elseif ((get-item $file.fullname 2>&1 | out-null).linktype -eq "symboliclink") {
		$filecolor = "`e[97m"
		$separator += "->"
		$spacing -= 2
	}

	write-host "`e[39m$num$filecolor$name$separator" -nonewline

	$spacing -= screenWidth($name)

	if ($name.length -gt $max_spacing) {
		write-host
		$col = 0
		return $col
	}

	$spacing -= $num.length

	for (; $spacing -gt 0; $spacing--)
		{ write-host ' ' -nonewline }

	$col++

	if ($col -eq $colmax) {
		write-host
		$col = 0
	}

	return $col
}

function countFiles
{
	param ($path)

	$i = 1
	$max = 105
	$col = 0

	foreach ($file in get-childitem $path -force) {
		if ($file -match "C:\\Users\\$env:username\\ntuser")
			{ continue }

		$name = $file.name
		$col = countFilesWrite $file $i $name $col
		invoke-expression "`$global:$i = `"$name`""
		invoke-expression "function global:d$i { d `"$name`" }"
		$i++

		if ($i -gt $max)
			{ return E "很多文件" }
	}

	if ($col -gt 0)
		{ write-host }
}

function tour
{
	$tour = ".\_tour"

	if (test-path $tour)
		{ $('"' + $(get-content $tour) + '"') | write-host -foregroundcolor "white" }
}

function screenWidth
{
	param ($s)
	$width = 0

	for ($i = 0; $i -lt $s.length; $i++) {
		if ([system.text.encoding]::utf8.getbytecount($s.substring($i, 1)) -lt 3)
			{ $width += 1 }
		else
			{ $width += 2 }
	}

	return $width
}

# --- Init ---

countFiles
