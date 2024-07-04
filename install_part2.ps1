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


Write-Host "Setting up WSL environment..."


wsl -d Ubuntu -e bash -c "sudo apt update && sudo apt install -y clang libicu-dev libssl-dev libcurl4-openssl-dev"

wsl -d Ubuntu -e bash -c 'sudo curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && sudo apt-get install -y nodejs && sudo apt install -y lua5.1'
wsl -d Ubuntu -e bash -c 'wget -O /tmp/openresty_pubkey.gpg https://openresty.org/package/pubkey.gpg'
wsl -d Ubuntu -e bash -c 'sudo gpg --dearmor -o /usr/share/keyrings/openresty.gpg /tmp/openresty_pubkey.gpg'
wsl -d Ubuntu -e bash -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openresty.gpg] http://openresty.org/package/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/openresty.list > /dev/null'
wsl -d Ubuntu -e bash -c 'sudo apt-get update && sudo apt-get -y install openresty luarocks libssl-dev libbson-dev libmongoc-dev && sudo luarocks install lapis && sudo luarocks install lua-resty-rsa && sudo luarocks install lua-mongo && lua5.1 --v'

#wsl -d Ubuntu -e bash -c 'sudo apt-get update && sudo apt-get -y install openresty luarocks libssl-dev libbson-dev libmongoc-dev && sudo luarocks install lapis && sudo luarocks install lua-resty-rsa && sudo luarocks install lua-mongo && lua5.1 --help'
#wsl -d Ubuntu -e bash -c "sudo apt-get install -y nodejs"

#wsl -d Ubuntu -e bash -c "sudo apt install lua5.1"
#wsl -d Ubuntu -e bash -c "wget -O - https://openresty.org/package/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/openresty.gpg"
#wsl -d Ubuntu -e bash -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openresty.gpg] http://openresty.org/package/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/openresty.list > /dev/null'

#wsl -d Ubuntu -e bash -c "sudo apt-get update"
#wsl -d Ubuntu -e bash -c "sudo apt-get -y install openresty"
#wsl -d Ubuntu -e bash -c "sudo apt-get install luarocks"
#wsl -d Ubuntu -e bash -c "sudo apt-get install libssl-dev"
#wsl -d Ubuntu -e bash -c "sudo luarocks install lapis"
#wsl -d Ubuntu -e bash -c "sudo luarocks install lua-resty-rsa"
#wsl -d Ubuntu -e bash -c "sudo apt-get install libbson-dev"
#wsl -d Ubuntu -e bash -c "sudo apt-get install libmongoc-dev"


#wsl -d Ubuntu -e bash -c "sudo luarocks install lua-mongo"


#wsl -d Ubuntu -e bash -c "Lua --help"

Write-Host "WSL environment and Lua setup completed."





