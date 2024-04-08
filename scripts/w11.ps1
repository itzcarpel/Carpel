# Define input file path
$inputFile = "C:\Windows\appcompat\pca\PcaGeneralDb0.txt"

# Define a function to check if a line is suspicious
function IsSuspicious($productname, $publisher, $productversion) {
    return [string]::IsNullOrEmpty($productname) -and [string]::IsNullOrEmpty($publisher) -and [string]::IsNullOrEmpty($productversion)
}

# Define a function to parse each line of the input file
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

# Read the input file line by line with UTF-16 LE encoding, parse each line, and store the parsed data in an array
$data = Get-Content -Path $inputFile -Encoding Unicode | ForEach-Object { ParseLine $_ }

# Display the parsed data in Out-GridView
$data | Out-GridView
