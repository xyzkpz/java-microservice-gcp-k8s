# System Detection and Docker Desktop Setup Script with WSL Support
# This script detects your system and guides you through WSL and Docker Desktop installation

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "System Detection & Docker Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Detect System Information
Write-Host "Step 1: Detecting your system..." -ForegroundColor Yellow
Write-Host ""

$os = Get-WmiObject -Class Win32_OperatingSystem
$computer = Get-WmiObject -Class Win32_ComputerSystem
$processor = Get-WmiObject -Class Win32_Processor

$osName = $os.Caption
$osVersion = $os.Version
$osArch = $os.OSArchitecture
$ramGB = [math]::Round($computer.TotalPhysicalMemory / 1GB, 2)
$processorName = $processor.Name

Write-Host "System Information:" -ForegroundColor Green
Write-Host "  OS: $osName" -ForegroundColor White
Write-Host "  Version: $osVersion" -ForegroundColor White
Write-Host "  Architecture: $osArch" -ForegroundColor White
Write-Host "  RAM: $ramGB GB" -ForegroundColor White
Write-Host "  Processor: $processorName" -ForegroundColor White
Write-Host ""

# Step 2: Check WSL (Windows Subsystem for Linux)
Write-Host "Step 2: Checking WSL (Windows Subsystem for Linux)..." -ForegroundColor Yellow

# Define WSL paths
$wslExePath = "C:\Program Files\WSL\wsl.exe"
$wslSystemPath = "wsl.exe"

# Check if WSL is installed
$wslInstalled = $false
$wslCommand = $null

if (Test-Path $wslExePath) {
    $wslCommand = $wslExePath
    $wslInstalled = $true
    Write-Host "✓ WSL is installed at: $wslExePath" -ForegroundColor Green
    
    try {
        $wslVersion = & $wslCommand --version 2>$null
        if ($wslVersion) {
            Write-Host "✓ WSL Version: $($wslVersion[0])" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "⚠ Could not get WSL version" -ForegroundColor Yellow
    }
    
    # Check for installed distributions
    try {
        $distros = & $wslCommand --list --quiet 2>$null
        if ($distros -and $distros.Count -gt 0) {
            $hasDistro = $false
            Write-Host "✓ WSL Distributions installed:" -ForegroundColor Green
            foreach ($distro in $distros) {
                if ($distro.Trim()) {
                    Write-Host "    - $($distro.Trim())" -ForegroundColor White
                    $hasDistro = $true
                }
            }
            if (!$hasDistro) {
                Write-Host "⚠ WSL is installed but no Linux distribution found" -ForegroundColor Yellow
                Write-Host "  Run: & '$wslCommand' --install Ubuntu-24.04" -ForegroundColor Gray
            }
        }
        else {
            Write-Host "⚠ WSL is installed but no Linux distribution found" -ForegroundColor Yellow
            Write-Host "  Run: & '$wslCommand' --install Ubuntu-24.04" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "⚠ No WSL distributions installed yet" -ForegroundColor Yellow
        Write-Host "  To install Ubuntu: & '$wslCommand' --install Ubuntu-24.04" -ForegroundColor Gray
    }
}
else {
    # Try system PATH
    try {
        $null = & $wslSystemPath --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            $wslCommand = $wslSystemPath
            $wslInstalled = $true
            Write-Host "✓ WSL is installed (in system PATH)" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "✗ WSL is not installed" -ForegroundColor Red
        Write-Host "  Download WSL from: https://github.com/microsoft/WSL/releases" -ForegroundColor Yellow
        Write-Host "  Or run: winget install Microsoft.WSL" -ForegroundColor Gray
    }
}

Write-Host ""

# Step 3: Check if Docker is already installed
Write-Host "Step 3: Checking for Docker..." -ForegroundColor Yellow

try {
    $dockerVersion = docker --version 2>$null
    Write-Host "✓ Docker is already installed: $dockerVersion" -ForegroundColor Green
    $dockerInstalled = $true
}
catch {
    Write-Host "✗ Docker is not installed" -ForegroundColor Red
    $dockerInstalled = $false
}
Write-Host ""

# Step 4: Determine correct Docker version
Write-Host "Step 4: Determining correct Docker Desktop version..." -ForegroundColor Yellow

$dockerDownloadUrl = ""
$dockerFileName = ""

if ($osArch -eq "64-bit") {
    # Windows 10/11 64-bit
    $dockerDownloadUrl = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
    $dockerFileName = "DockerDesktopInstaller.exe"
    Write-Host "✓ Suitable version: Docker Desktop for Windows (64-bit)" -ForegroundColor Green
}
else {
    Write-Host "✗ Your system is 32-bit. Docker Desktop requires 64-bit Windows." -ForegroundColor Red
    Write-Host "Please upgrade to 64-bit Windows to use Docker Desktop." -ForegroundColor Yellow
    exit 1
}

Write-Host "  Download URL: $dockerDownloadUrl" -ForegroundColor White
Write-Host ""

# Step 5: Check system requirements
Write-Host "Step 5: Checking system requirements..." -ForegroundColor Yellow

$meetsRequirements = $true

# Check RAM (minimum 4GB recommended, 8GB+ ideal)
if ($ramGB -lt 4) {
    Write-Host "⚠ Warning: You have $ramGB GB RAM. Docker Desktop recommends at least 4GB." -ForegroundColor Yellow
    $meetsRequirements = $false
}
elseif ($ramGB -lt 8) {
    Write-Host "⚠ You have $ramGB GB RAM. 8GB+ is recommended for optimal performance." -ForegroundColor Yellow
}
else {
    Write-Host "✓ RAM: $ramGB GB (Sufficient)" -ForegroundColor Green
}

# Check Windows version (requires Windows 10 build 19041+ or Windows 11)
$buildNumber = $os.BuildNumber
if ($buildNumber -lt 19041) {
    Write-Host "⚠ Warning: Windows build $buildNumber detected. Docker Desktop requires build 19041 or higher." -ForegroundColor Yellow
    Write-Host "  Please update Windows to the latest version." -ForegroundColor Yellow
    $meetsRequirements = $false
}
else {
    Write-Host "✓ Windows version: Build $buildNumber (Compatible)" -ForegroundColor Green
}

# Check virtualization
try {
    $hyperv = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -ErrorAction SilentlyContinue
    if ($hyperv.State -eq "Enabled") {
        Write-Host "✓ Hyper-V: Enabled" -ForegroundColor Green
    }
    else {
        Write-Host "⚠ Hyper-V: Not enabled (will be enabled during Docker installation)" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "⚠ Could not check Hyper-V status" -ForegroundColor Yellow
}

Write-Host ""

if (!$meetsRequirements) {
    Write-Host "⚠ Your system may not meet all requirements. Installation may fail." -ForegroundColor Yellow
    Write-Host ""
}

# Step 6: Download Docker Desktop (if not installed)
if (!$dockerInstalled) {
    Write-Host "Step 6: Downloading Docker Desktop..." -ForegroundColor Yellow
    Write-Host "  This may take 5-10 minutes depending on your internet speed." -ForegroundColor Gray
    Write-Host ""
    
    $downloadPath = "$env:USERPROFILE\Downloads\$dockerFileName"
    
    try {
        # Download Docker Desktop
        Write-Host "Downloading from: $dockerDownloadUrl" -ForegroundColor Gray
        Write-Host "Saving to: $downloadPath" -ForegroundColor Gray
        
        Invoke-WebRequest -Uri $dockerDownloadUrl -OutFile $downloadPath -UseBasicParsing
        
        Write-Host "✓ Download complete!" -ForegroundColor Green
        Write-Host ""
        
        # Step 7: Install Docker Desktop
        Write-Host "Step 7: Installing Docker Desktop..." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "IMPORTANT:" -ForegroundColor Red
        Write-Host "  1. The installer will open in a new window" -ForegroundColor Yellow
        Write-Host "  2. Follow the installation wizard" -ForegroundColor Yellow
        Write-Host "  3. When prompted, check 'Install required Windows components for WSL 2'" -ForegroundColor Yellow
        Write-Host "  4. After installation, you MUST restart your computer" -ForegroundColor Yellow
        Write-Host ""
        
        $install = Read-Host "Ready to start installation? (Y/N)"
        
        if ($install -eq "Y" -or $install -eq "y") {
            Write-Host "Starting Docker Desktop installer..." -ForegroundColor Green
            Start-Process -FilePath $downloadPath -Wait
            
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host "Installation Complete!" -ForegroundColor Cyan
            Write-Host "========================================" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "NEXT STEPS:" -ForegroundColor Yellow
            Write-Host "  1. Restart your computer" -ForegroundColor White
            Write-Host "  2. After restart, open Docker Desktop from Start Menu" -ForegroundColor White
            Write-Host "  3. Go to Settings (gear icon) > Kubernetes" -ForegroundColor White
            Write-Host "  4. Check 'Enable Kubernetes' and click 'Apply & Restart'" -ForegroundColor White
            Write-Host "  5. Wait for Kubernetes to start (green indicator)" -ForegroundColor White
            Write-Host "  6. Run this script again to verify installation" -ForegroundColor White
            Write-Host ""
        }
        else {
            Write-Host "Installation cancelled. You can install manually from:" -ForegroundColor Yellow
            Write-Host "  $downloadPath" -ForegroundColor White
            Write-Host ""
        }
        
    }
    catch {
        Write-Host "✗ Download failed: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Manual download option:" -ForegroundColor Yellow
        Write-Host "  1. Open browser and go to: $dockerDownloadUrl" -ForegroundColor White
        Write-Host "  2. Download and run the installer" -ForegroundColor White
        Write-Host "  3. Follow installation instructions" -ForegroundColor White
        Write-Host ""
    }
}
else {
    # Docker is installed, check if it's running
    Write-Host "Step 6: Checking Docker status..." -ForegroundColor Yellow
    
    try {
        docker ps 2>$null | Out-Null
        Write-Host "✓ Docker is running!" -ForegroundColor Green
        
        # Check Kubernetes
        Write-Host ""
        Write-Host "Step 7: Checking Kubernetes..." -ForegroundColor Yellow
        
        try {
            kubectl version --client 2>$null | Out-Null
            Write-Host "✓ kubectl is installed" -ForegroundColor Green
            
            try {
                kubectl get nodes 2>$null | Out-Null
                Write-Host "✓ Kubernetes is running!" -ForegroundColor Green
                Write-Host ""
                Write-Host "========================================" -ForegroundColor Cyan
                Write-Host "✓ ALL REQUIREMENTS MET!" -ForegroundColor Green
                Write-Host "========================================" -ForegroundColor Cyan
                Write-Host ""
                Write-Host "You're ready to deploy! Run:" -ForegroundColor Green
                Write-Host "  .\deploy-local.ps1" -ForegroundColor White
                Write-Host ""
            }
            catch {
                Write-Host "✗ Kubernetes is not running" -ForegroundColor Red
                Write-Host ""
                Write-Host "To enable Kubernetes:" -ForegroundColor Yellow
                Write-Host "  1. Open Docker Desktop" -ForegroundColor White
                Write-Host "  2. Click Settings (gear icon)" -ForegroundColor White
                Write-Host "  3. Go to Kubernetes tab" -ForegroundColor White
                Write-Host "  4. Check 'Enable Kubernetes'" -ForegroundColor White
                Write-Host "  5. Click 'Apply & Restart'" -ForegroundColor White
                Write-Host "  6. Wait 2-3 minutes for Kubernetes to start" -ForegroundColor White
                Write-Host ""
            }
        }
        catch {
            Write-Host "✗ kubectl not found" -ForegroundColor Red
            Write-Host ""
            Write-Host "Kubernetes may not be enabled. Follow steps above to enable it." -ForegroundColor Yellow
            Write-Host ""
        }
        
    }
    catch {
        Write-Host "✗ Docker is not running" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please start Docker Desktop from the Start Menu" -ForegroundColor Yellow
        Write-Host ""
    }
}

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "System Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your System:" -ForegroundColor Yellow
Write-Host "  OS: $osName ($osArch)" -ForegroundColor White
Write-Host "  RAM: $ramGB GB" -ForegroundColor White
Write-Host "  Build: $buildNumber" -ForegroundColor White

if ($wslInstalled) {
    Write-Host "  WSL: ✓ Installed" -ForegroundColor Green
}
else {
    Write-Host "  WSL: ✗ Not installed" -ForegroundColor Red
}

Write-Host ""

if ($dockerInstalled) {
    Write-Host "Docker Status:" -ForegroundColor Yellow
    Write-Host "  Installed: ✓ Yes" -ForegroundColor Green
    try {
        docker ps 2>$null | Out-Null
        Write-Host "  Running: ✓ Yes" -ForegroundColor Green
    }
    catch {
        Write-Host "  Running: ✗ No (Start Docker Desktop)" -ForegroundColor Red
    }
}
else {
    Write-Host "Docker Status:" -ForegroundColor Yellow
    Write-Host "  Installed: ✗ No" -ForegroundColor Red
    if (Test-Path "$env:USERPROFILE\Downloads\$dockerFileName") {
        Write-Host "  Download: Ready at $env:USERPROFILE\Downloads\$dockerFileName" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow

if (!$wslInstalled) {
    Write-Host "  1. Install WSL first (install it from Microsoft Store or download from GitHub)" -ForegroundColor White
    Write-Host "  2. Then install Docker Desktop" -ForegroundColor White
}
elseif (!$dockerInstalled) {
    Write-Host "  1. Install Docker Desktop from Downloads folder" -ForegroundColor White
    Write-Host "  2. Restart computer" -ForegroundColor White
    Write-Host "  3. Enable Kubernetes in Docker Desktop" -ForegroundColor White
    Write-Host "  4. Run: .\deploy-local.ps1" -ForegroundColor White
}
else {
    try {
        docker ps 2>$null | Out-Null
        try {
            kubectl get nodes 2>$null | Out-Null
            Write-Host "  Run: .\deploy-local.ps1" -ForegroundColor White
        }
        catch {
            Write-Host "  Enable Kubernetes in Docker Desktop Settings" -ForegroundColor White
        }
    }
    catch {
        Write-Host "  Start Docker Desktop" -ForegroundColor White
    }
}

Write-Host ""
