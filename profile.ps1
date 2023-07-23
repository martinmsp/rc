# foreach-object considered harmful

$env:path += ";$home\bin"
$env:path += ";C:\Program Files (x86)\Vim\vim90"
$env:path += ";C:\program files\llvm\bin"
$env:path += ";C:\program files\git\bin"
$env:path += ";C:\program files\cmake\bin"
$env:path += ";C:\Program Files (x86)\GnuWin32\bin"
$env:path += ";C:\Program Files\7-Zip"
$env:path += ";C:\Users\marti\AppData\Local\Android\Sdk\platform-tools"

set-psreadlineoption -colors @{command="`e[39m";operator="`e[39m";parameter="`e[39m"}

function prompt
{
	$location = $($(get-location) -replace ".+\\.+\\$env:username", '家')

	return "`e[91m那么。我们开始。《`e[96m$location`e[91m》`e[39m"
}

# --- Abbreviations ---

function ..
{
	cd ..
	l
}

function but($cmd)
{
	$lastcmd = -split (get-history -count 1).commandline

	if ($lastcmd.count -ne 2) {
		E "I RECKON YOUR WRONG"
		return
	}

	invoke-expression "$cmd $($lastcmd[1])"
}

function d($path)
{
	$copy = $pwd

	cd $path

	if ($copy.path -ne $pwd.path) {
		tour
		countFiles
	}
}

function E($msg)
{
	write-host "`n`t`e[91m* * * $msg * * *`n"
}

function 关电脑
{
	stop-computer
}

function hklm($path)
{
	return "HKLM:\software\microsoft\windows nt\currentversion\$path"
}

function l($path)
{
	countFiles $path @args
}

function rc($path)
{
	remove-item -confirm $path
}

function v($path)
{
	gvim $path
}

function x
{
	exit
}

# --- File Handling ---

$global:col_max = 2

function countFiles($path)
{
	$num = 1
	$col = 0
	$max_spacing = 31
	$max_files = 105

	if ($args.count -gt 0) {
		E "$($args.count+1) ARGUMENTS? NOT IN MEXICO"
		return
	}

	foreach ($file in get-childitem $path -force) {
		$spacing = $max_spacing
		$separator = ""
		$color = ""

		if ($file -match "C:\\Users\\$env:username\\ntuser")
			{ continue }

		$name = $file.name

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

		write-host "`e[93m[$num]`e[39m$color$name`e[39m$separator" -nonewline

		if ($num -le $max_files) {
			invoke-expression "`$global:$num = `"$name`""
			invoke-expression "function global:d$num { d `"$name`" }"
		}

		$spacing -= "$num".length
		$spacing -= 2
		$spacing -= screenWidth($name)
		$spacing -= $separator.length

		$num++
		$col++

		if ($name.length -gt $max_spacing -or $col -eq $col_max) {
			write-host
			$col = 0
			$spacing = 0
		}

		for (; $spacing -gt 0; $spacing--)
			{ write-host ' ' -nonewline }
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

function screenWidth($s)
{
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
