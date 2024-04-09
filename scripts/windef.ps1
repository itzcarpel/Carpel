Clear-Host


Write-Host "";
Write-Host "";
Write-Host -ForegroundColor Red "  _   _                 __          ___       _____        __ ";
Write-Host -ForegroundColor Red " | \ | |                \ \        / (_)     |  __ \      / _|";
Write-Host -ForegroundColor Red " |  \| | __ _ _ __ ___ __\ \  /\  / / _ _ __ | |  | | ___| |_ ";
Write-Host -ForegroundColor Red " | . ` |/ _` | '__/ __/ _ \ \/  \/ / | | '_ \| |  | |/ _ \  _|";
Write-Host -ForegroundColor Red " | |\  | (_| | | | (_| (_) \  /\  /  | | | | | |__| |  __/ |  ";
Write-Host -ForegroundColor Red " |_| \_|\__,_|_|  \___\___/ \/  \/   |_|_| |_|_____/ \___|_|  ";
Write-Host "";
Write-Host -ForegroundColor Blue "   Made By Carpel For NarcoCity - " -NoNewLine
Write-Host -ForegroundColor Red "discord.gg/narcocity";
Write-Host "";


# Get threat detection information and select desired fields
$threats = Get-MpThreatDetection | Select-Object InitialDetectionTime, LastThreatStatusChangeTime, ProcessName, Resources

# Display the information in a grid view
$threats | Out-GridView -PassThru -Title 'Windows Security Script by Carpel'
