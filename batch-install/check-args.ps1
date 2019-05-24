##### check valid arguments for exe or msi files

# read each line of paths.ini
[string]$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$pathsPath = $scriptPath + "\paths.ini"
if ((Test-Path -Path $pathsPath) -eq $false) {
    Write-Host "Cannot find" $pathsPath
} else {
    $pathsFile = [string[]](Get-Content -Path $pathsPath)
    foreach ($line in $pathsFile) {
        # take comments out of line
        $tempLine = ""
        for ($i = 0; $i -lt $line.Length; $i++) {
            $character = $line.substring($i, 1)
            if ($character -eq "#") {
                break
            }
            $tempLine = $tempLine + $character
        }

        # get path from line
        if ($tempLine -ne "") {
            [string[]]$split = @($tempLine -split " /")
            $path = $split[0]

            # check args
            if ($path -eq "" -or (Test-Path -Path $path) -eq $false) {
                Write-Host "Cannot find" $path
            } else {
                Write-Host "Checking" $path "..."
                # to-fix
                & $path /? -PassThru -Wait
            }
        }
    }
}

Read-Host "Press enter to continue"
