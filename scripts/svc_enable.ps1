Clear-Host
Write-Host @"
 _   _                     _____           
| \ | |                   /  ___|          
|  \| | __ _ _ __ ___ ___ \ `--.__   _____ 
|  . ` |/ _` | '__/ __/ _ \ `--. \ \ / / __|
| |\  | (_| | | | (_| (_) /\__/ /\ V / (__ 
\_| \_/\__,_|_|  \___\___/\____/  \_/ \___|
                                           
                                           
"@ -ForegroundColor Cyan

Write-Host "Made by Carpel for NarcoCity"

$services = @('SysMain', 'PcaSvc', 'DiagTrack')

function Check-Services {
    Write-Output "NarcoCity Service Checker"
    foreach ($service in $services) {
        try {
            $serviceObj = Get-Service -Name $service
            $startType = Get-WmiObject -Class Win32_Service -Filter "Name='$service'" | Select-Object -ExpandProperty StartMode

            $status = $serviceObj.Status
            $isRunning = $status -eq 'Running'
            $startTypeReadable = switch ($startType) {
                'Auto' { 'Automatic' }
                'Manual' { 'Manual' }
                'Disabled' { 'Disabled' }
                default { 'Unknown' }
            }
            Write-Output "- $service - Running: $isRunning StartType: $startTypeReadable"
        } catch {
            Write-Output "- $service - Service not found"
        }
    }
}

function Enable-And-Start-Services {
    foreach ($service in $services) {
        try {
            Set-Service -Name $service -StartupType Automatic
            Start-Service -Name $service -ErrorAction SilentlyContinue
        } catch {
            Write-Output "Failed to enable or start $service"
        }
    }
    Write-Output "All services have been set to start automatically and started if not already running."
}

Check-Services

Write-Output "`nPress 1 to exit and press 2 to enable and start all services"
$input = Read-Host

if ($input -eq '2') {
    Enable-And-Start-Services
} elseif ($input -ne '1') {
    Write-Output "Invalid input. Exiting."
}
