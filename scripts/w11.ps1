$inputFile = "C:\Windows\appcompat\pca\PcaGeneralDb0.txt"

function IsSuspicious($productname, $publisher, $productversion) {
    return [string]::IsNullOrEmpty($productname) -and [string]::IsNullOrEmpty($publisher) -and [string]::IsNullOrEmpty($productversion)
}

function ParseLine($line) {
    $fields = $line -split '\|'
    $productname = if ($fields[3] -eq '') { $null } else { $fields[3] }
    $publisher = if ($fields[4] -eq '') { $null } else { $fields[4] }
    $productversion = if ($fields[5] -eq '') { $null } else { $fields[5] }
    $suspicious = IsSuspicious $productname $publisher $productversion
    return [PSCustomObject]@{
        Time = $fields[0]
        Runcount = $fields[1]
        Path = $fields[2]
        Productname = $productname
        Publisher = $publisher
        Productversion = $productversion
        Programid = $fields[6]
        Exitcode = $fields[7]
        Suspicious = $suspicious
    }
}

Clear-Host

Write-Host "";
Write-Host "";
Write-Host -ForegroundColor Red "  _   _                 __          ____ __ ";
Write-Host -ForegroundColor Red " | \ | |                \ \        / /_ /_ |";
Write-Host -ForegroundColor Red " |  \| | __ _ _ __ ___ __\ \  /\  / / | || |";
Write-Host -ForegroundColor Red " | . ` |/ _` | '__/ __/ _ \ \/  \/ /  | || |";
Write-Host -ForegroundColor Red " | |\  | (_| | | | (_| (_) \  /\  /   | || |";
Write-Host -ForegroundColor Red " |_| \_|\__,_|_|  \___\___/ \/  \/    |_||_|";
Write-Host "";
Write-Host -ForegroundColor Blue "   Made By Carpel (Shitty ScreenSharer) For NarcoCity - " -NoNewLine
Write-Host -ForegroundColor Red "discord.gg/narcocity";
Write-Host "";

$data = Get-Content $inputFile | ForEach-Object { ParseLine $_ }

$data | Out-GridView

Read-Host "Press Enter to close this window"
