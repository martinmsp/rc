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

function d
{
	param ($path)
	$copy = $pwd

	cd $path

	if ($copy.path -ne $pwd.path) {
		tour
		countFiles
	}
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

function x
{
	exit
}

# --- File Handling ---

$global:col_max = 2

function countFilesWrite
{
	param ($file, $num, $name, $col)
	$color = ""
	$separator = ""
	$max_spacing = 31
	$spacing = $max_spacing

	if ($file.psiscontainer) {
		$color = "`e[96m"
		$separator = "\"
	} elseif ($file.extension -eq ".exe") {
		$color = "`e[92m"
		$separator = "*"
	} elseif ($file.linktype -eq "symboliclink") {
		$color = "`e[97m"
		$separator = "@"
	}

	write-host "[$num]$color$name`e[39m$separator" -nonewline

	if ($name.length -gt $max_spacing) {
		write-host
		$col = 0
		return $col
	}

	$spacing -= "$num".length
	$spacing -= 2
	$spacing -= screenWidth($name)
	$spacing -= $separator.length

	for (; $spacing -gt 0; $spacing--)
		{ write-host ' ' -nonewline }

	$col++

	if ($col -eq $col_max) {
		write-host
		$col = 0
	}

	return $col
}

function countFiles
{
	param ($path)

	$num = 1
	$max_files = 105
	$col = 0

	foreach ($file in get-childitem $path -force) {
		if ($file -match "C:\\Users\\$env:username\\ntuser")
			{ continue }

		$name = $file.name
		$col = countFilesWrite $file $num $name $col

		if ($num -le $max_files) {
			invoke-expression "`$global:$num = `"$name`""
			invoke-expression "function global:d$num { d `"$name`" }"
		}

		$num++
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

l
