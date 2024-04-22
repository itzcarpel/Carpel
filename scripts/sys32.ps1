Write-Host @"
  _   _                     _____ ____ ___  
 | \ | |                   / ____|___ \__ \ 
 |  \| | __ _ _ __ ___ ___| (___   __) | ) |
 | . ` |/ _` | '__/ __/ _ \\___ \ |__ < / / 
 | |\  | (_| | | | (_| (_) |___) |___) / /_ 
 |_| \_|\__,_|_|  \___\___/_____/|____/____|
                                            
                                            

"@ -ForegroundColor Green

Write-Host "Made by Carpel for NarcoCity`n"

$system32Path = "$env:SystemRoot\System32"

# Get all files in System32 directory
$files = Get-ChildItem -Path $system32Path -File -Recurse

foreach ($file in $files) {
    # Check if the file is an executable
    if ($file.Extension -eq ".exe") {
        # Check if the file is signed
        $signature = Get-AuthenticodeSignature $file.FullName -ErrorAction SilentlyContinue
        if (-not $signature) {
            Write-Host "Unsigned: $($file.FullName)"
        }
    }
}
