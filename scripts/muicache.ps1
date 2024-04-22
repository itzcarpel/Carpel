Clear-Host

Write-Host @"
  _   _                     __  __       _ 
 | \ | |                   |  \/  |     (_)
 |  \| | __ _ _ __ ___ ___ | \  / |_   _ _ 
 | . ` |/ _` | '__/ __/ _ \| |\/| | | | | |
 | |\  | (_| | | | (_| (_) | |  | | |_| | |
 |_| \_|\__,_|_|  \___\___/|_|  |_|\__,_|_|
                                           
"@ -ForegroundColor Cyan

Write-Host "Made by Carpel for NarcoCity`n"

$MuicachePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.exe\UserChoice"

Get-ItemProperty -Path $MuicachePath |
    Sort-Object LastWriteTime |
    Out-GridView -PassThru -Title 'Muicache Script by Carpel'
