Clear-Host
Write-Host @"
  _   _                                         _____         _   _     
 | \ | |                      /\               / ____|       | | | |    
 |  \| | __ _ _ __ ___ ___   /  \   _ __  _ __| (_____      _| |_| |__  
 | . ` |/ _` | '__/ __/ _ \ / /\ \ | '_ \| '_ \\___ \ \ /\ / / __| '_ \ 
 | |\  | (_| | | | (_| (_) / ____ \| |_) | |_) |___) \ V  V /| |_| | | |
 |_| \_|\__,_|_|  \___\___/_/    \_\ .__/| .__/_____/ \_/\_/  \__|_| |_|
                                   | |   | |                            
                                   |_|   |_|                            
"@ -ForegroundColor Cyan

Write-Host "Made by Carpel for NarcoCity`n"


$AppSwitchedPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppSwitched"

Get-ItemProperty -Path $AppSwitchedPath |
    findstr /i /C:":\" |
    Sort-Object LastWriteTime |
    Out-GridView -PassThru -Title 'Appswitch Script by Carpel'
