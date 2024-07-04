if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop is not installed. Installing Scoop..."
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
} else {
    Write-Host "Scoop is already installed."
}


scoop bucket add main
scoop bucket add versions
scoop install versions/python39
scoop install versions/nodejs20