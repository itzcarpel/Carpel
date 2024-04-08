$inputFile = "C:\Windows\appcompat\pca\PcaGeneralDb0.txt"

if (-not (Test-Path $inputFile)) {
    Write-Host "This script is not compatible for this version of Windows"
    exit
}

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

$data = Get-Content $inputFile | ForEach-Object { ParseLine $_ }

$data | Out-GridView
