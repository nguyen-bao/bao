# get files in FilePath matching FileType recursively
function Get-Files {
    param([string]$FilePath, [string]$FileType)
    begin {Write-Host "Finding Files..."}
    process {
        Get-ChildItem -File -Path $FilePath -Recurse -Filter $FileType | ForEach-Object {
            Write-Host $_.FullName
            $_.FullName
        }
    }
    end {Write-Host "Done"}
}

# # backup files in ListOfFiles into Destination
function Backup-Files {
    param([string]$StartPath, [string[]]$ListOfFiles, [string]$BackupPath)
    begin {Write-Host "Backing up Files..."}
    process{
        if ((Test-Path $BackupPath) -eq $true) {
            $count = 1
            $NewBackupPath = $BackupPath + " (" + [string]$count + ")"

            while ((Test-Path $NewBackupPath) -eq $true) {
                $count = $count + 1
                $NewBackupPath = $BackupPath + " (" + [string]$count + ")"
            }
            $BackupPath = $NewBackupPath
        }

        foreach($file in $ListOfFiles) {
            $destinationPath = $BackupPath + $file.Substring($StartPath.length)
            Write-Host $file " ---> " $destinationPath

            New-Item -Path $destinationPath -Force
            Copy-Item -Path $file -Destination $destinationPath
        }
    }

    end{Write-Host "Done"}
}

function ReplaceLines {
    param([string[]]$ListOfFiles, [string]$replaceWhat, [string]$replaceWith)
    begin {Write-Host "Replacing Lines..."}
    process {
        foreach($file in $ListOfFiles) {
            Write-Host $file

            (Get-Content $file) -replace $replaceWhat, $replaceWith | Set-Content $file
        }
    }
    end {Write-Host "Done"}
}

# ShowDialog - show dialog to get file path and file type
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Change Passwords'
$form.Size = New-Object System.Drawing.Size(300,275);
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKBUtton.Location = New-Object System.Drawing.Point(75,205)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKBUtton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,205)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$pathLabel = New-Object System.Windows.Forms.Label
$pathLabel.Location = New-Object System.Drawing.Point(10,20)
$pathLabel.Size = New-Object System.Drawing.Size(280,20)
$pathLabel.Text = 'File Path (recursive)'
$form.Controls.Add($pathLabel)

$pathText = New-Object System.Windows.Forms.TextBox
$pathText.Location = New-Object System.Drawing.Point(10,40)
$pathText.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($pathText)

$typeLabel = New-Object System.Windows.Forms.Label
$typeLabel.Location = New-Object System.Drawing.Point(10,65)
$typeLabel.Size = New-Object System.Drawing.Size(280,20)
$typeLabel.Text = 'File Type (regex)'
$form.Controls.Add($typeLabel)

$typeText = New-Object System.Windows.Forms.TextBox
$typeText.Location = New-Object System.Drawing.Point(10,85)
$typeText.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($typeText)

$whatLabel = New-Object System.Windows.Forms.Label
$whatLabel.Location = New-Object System.Drawing.Point(10,110)
$whatLabel.Size = New-Object System.Drawing.Size(280,20)
$whatLabel.Text = 'Replace What (regex)'
$form.Controls.Add($whatLabel)

$whatText = New-Object System.Windows.Forms.TextBox
$whatText.Location = New-Object System.Drawing.Point(10,130)
$whatText.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($whatText)

$withLabel = New-Object System.Windows.Forms.Label
$withLabel.Location = New-Object System.Drawing.Point(10,155)
$withLabel.Size = New-Object System.Drawing.Size(280,20)
$withLabel.Text = 'Replace With (regex)'
$form.Controls.Add($withLabel)

$withText = New-Object System.Windows.Forms.TextBox
$withText.Location = New-Object System.Drawing.Point(10,175)
$withText.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($withText)

$form.TopMost = $true

$form.Add_Shown({$pathText.Select()})
$result = $form.ShowDialog()
# end ShowDialog

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $filePath = $pathText.Text
    $fileType = $typeText.Text
    $replaceWhat = $whatText.Text
    $replaceWith = $withText.Text

    if ($filePath.Length -eq 0 -or $fileType -eq 0 -or $replaceWhat -eq 0 -or $replaceWith -eq 0) {
        Write-Host "Please fill every field"
    } else {
        $listOfFiles = [string[]](Get-Files -FilePath $filePath -FileType $fileType)

        [string]$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
        $backupPath = $scriptPath + "\backup"
        Backup-Files -StartPath $filePath -ListOfFiles $listOfFiles -BackupPath $backupPath

        ReplaceLines -ListOfFiles $listOfFiles -ReplaceWhat $replaceWhat -ReplaceWith $replaceWith

        Write-Host "Complete"
    }
}

Read-Host "Press enter to continue"
