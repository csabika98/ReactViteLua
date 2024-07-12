function Test-IsAdministrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}


if (-not (Test-IsAdministrator)) {
    Write-Host "This script requires administrator privileges for some operations. Please run the script as an administrator."
    exit
}


Write-Host "Running administrative operations..."
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
Start-Sleep -Seconds 5

$wslInstalled = (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq 'Enabled'

function IsWSLDistributionInstalled {
    param (
        [string]$distributionName
    )

    
    $wslListAll = wsl --list --all

    
    $isInstalled = $wslListAll -contains $distributionName

    return $isInstalled
}


$wslInstalled = $null -ne (wsl --list --all)

if (-not $wslInstalled) {
    Write-Host "Installing WSL..."
    wsl --install
    Write-Host "WSL installed. Please restart your computer and re-run this script."
    exit
}


$distributionName = "Ubuntu (Default)"
$ubuntuInstalled = IsWSLDistributionInstalled -distributionName $distributionName

if (-not $ubuntuInstalled) {
    Write-Host "Installing Ubuntu..."
    wsl --install -d Ubuntu
    Write-Host "Ubuntu installed. Please restart your computer and re-run this script."
    exit
} else {
    Write-Host "Ubuntu is already installed."
}




