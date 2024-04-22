Write-Host @"
  _   _                     _____ _       
 | \ | |                   / ____(_)      
 |  \| | __ _ _ __ ___ ___| (___  _  __ _ 
 | . ` |/ _` | '__/ __/ _ \\___ \| |/ _` |
 | |\  | (_| | | | (_| (_) |___) | | (_| |
 |_| \_|\__,_|_|  \___\___/_____/|_|\__, |
                                     __/ |
                                    |___/ 
"@ -ForegroundColor Magenta

Write-Host "Made by Carpel for NarcoCity`n"

# Define the path to the paths.txt file
$pathsFile = "paths.txt"

# Check if the paths.txt file exists
if (Test-Path $pathsFile -PathType Leaf) {
    # Read paths from the file
    $paths = Get-Content $pathsFile

    $unsignedFiles = @()

    foreach ($path in $paths) {
        # Check if the file exists
        if (Test-Path $path -PathType Leaf) {
            # Check if the file is an executable
            if ((Get-Item $path).Extension -eq ".exe") {
                # Check if the file has a digital signature
                $signature = $null
                try {
                    $signature = (Get-AuthenticodeSignature $path).Status
                } catch {
                    # Ignore errors caused by unsigned files
                }

                if ($signature -ne "Valid") {
                    $fileInfo = Get-Item $path
                    $fileProperties = @{
                        Name = $fileInfo.Name
                        Path = $fileInfo.FullName
                        Description = $fileInfo.VersionInfo.FileDescription
                        ProductName = $fileInfo.VersionInfo.ProductName
                        Company = $fileInfo.VersionInfo.CompanyName
                    }
                    $unsignedFiles += New-Object PSObject -Property $fileProperties
                }
            }
        } else {
            Write-Host "File not found: $path"
        }
    }

    # Display unsigned files in a grid view
    if ($unsignedFiles.Count -gt 0) {
        $unsignedFiles | Out-GridView -PassThru -Title 'UnSign Script by Carpel'
    } else {
        Write-Host "No unsigned files found."
    }
} else {
    Write-Host "Error: paths.txt file not found."
}
