##### install multiple exe or msi files

# install file without arguments
function Install-Without-Arguments {
    param ([string]$FilePath)
    begin {Write-Host "Installing" $FilePath}
    process {
        $install = Start-Process -FilePath $path -PassThru -Wait
        if ($install.exitcode -eq 0) {
            Write-Host "Done"
        } else {
            Write-Host "Error: exit code" + $install.exitcode
        }
    }
}

function Install-With-Arguments {
    param ([string]$FilePath, [string[]]$ArgumentList)
    begin {Write-Host "Installing" $FilePath}
    process {
        $install = Start-Process -FilePath $path -ArgumentList $ArgumentList -PassThru -Wait
        if ($install.exitcode -eq 0) {
            Write-Host "Done"
        } else {
            Write-Host "Error: exit code" $install.exitcode
            $userInput = Read-Host "Attempt install without arguments? (Y/N)"
            if ($userInput.toUpper() -eq "Y") {
                $install = Start-Process -FilePath $path -PassThru -Wait
                if ($install.exitcode -eq 0) {
                    Write-Host "Done"
                } else {
                    Write-Host "Error: exit code" $install.exitcode
                }
            }
        }
    }
}

# read each line of paths.ini
[string]$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$pathsPath = $scriptPath + "\paths.ini"
if ((Test-Path -Path $pathsPath) -eq $false) {
    Write-Host "Cannot find" $pathsPath
} else {
    Write-Host $pathsPath
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

        if ($tempLine -eq "") {
            continue
        }

        # get path and arguments from line
        [string[]]$split = @($tempLine -split " /")
        $path = $split[0]
        [string[]]$arguments = @()
        if ($split.Length -eq 1) {
            [string[]] $arguments = $split[1]
        }
        if ($split.length -gt 1 ) {
            [string[]]$arguments = $split[1..($split.Length-1)]
        }
        foreach ($arg in $arguments) {
            $arg = "/" + $arg
        }

        # install
        if ($path -eq "" -or (Test-Path -Path $path) -eq $false) {
            Write-Host "Cannot find" $path
        } else {
            Write-Host "Installing" $path "..."
            if ($arguments.Length -eq 0) {
                Install-Without-Arguments -FilePath $path
            } else {
                Install-With-Arguments $path $arguments
            }
        }
    }
}

Read-Host "Press enter to continue"
