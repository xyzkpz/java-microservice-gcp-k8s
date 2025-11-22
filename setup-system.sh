#!/bin/bash

# System Detection and Docker Desktop Setup Script for Git Bash
# This script detects your system and helps with Docker Desktop installation

echo "========================================"
echo "System Detection & Docker Setup"
echo "========================================"
echo ""

# Step 1: Detect System Information
echo "Step 1: Detecting your system..."
echo ""

# Get Windows version
os_name=$(wmic os get Caption | grep -v Caption | tr -d '\r')
os_version=$(wmic os get Version | grep -v Version | tr -d '\r')
os_arch=$(wmic os get OSArchitecture | grep -v OSArchitecture | tr -d '\r')

# Get RAM in GB
ram_bytes=$(wmic computersystem get TotalPhysicalMemory | grep -v TotalPhysicalMemory | tr -d '\r')
ram_gb=$(echo "scale=2; $ram_bytes / 1073741824" | bc 2>/dev/null || echo "Unable to calculate")

echo "System Information:"
echo "  OS: $os_name"
echo "  Version: $os_version"
echo "  Architecture: $os_arch"
echo "  RAM: ${ram_gb} GB"
echo ""

# Step 2: Check if Docker is already installed
echo "Step 2: Checking for Docker..."

if command -v docker &> /dev/null; then
    docker_version=$(docker --version)
    echo "✓ Docker is already installed: $docker_version"
    docker_installed=true
else
    echo "✗ Docker is not installed"
    docker_installed=false
fi
echo ""

# Step 3: Determine correct Docker version
echo "Step 3: Determining correct Docker Desktop version..."

if [[ "$os_arch" == *"64-bit"* ]]; then
    docker_url="https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
    docker_file="DockerDesktopInstaller.exe"
    echo "✓ Suitable version: Docker Desktop for Windows (64-bit)"
else
    echo "✗ Your system is 32-bit. Docker Desktop requires 64-bit Windows."
    echo "Please upgrade to 64-bit Windows to use Docker Desktop."
    exit 1
fi

echo "  Download URL: $docker_url"
echo ""

# Step 4: Download Docker Desktop (if not installed)
if [ "$docker_installed" = false ]; then
    echo "Step 4: Preparing to download Docker Desktop..."
    echo ""
    
    download_path="$HOME/Downloads/$docker_file"
    
    echo "Download Options:"
    echo ""
    echo "Option 1: Manual Download (Recommended)"
    echo "  1. Open your browser"
    echo "  2. Go to: $docker_url"
    echo "  3. Save the file to Downloads folder"
    echo "  4. Run the installer"
    echo ""
    echo "Option 2: Download with curl (if available)"
    echo "  Run this command:"
    echo "  curl -L -o \"$download_path\" \"$docker_url\""
    echo ""
    
    read -p "Do you want to download now with curl? (y/n): " download_choice
    
    if [[ "$download_choice" == "y" || "$download_choice" == "Y" ]]; then
        echo ""
        echo "Downloading Docker Desktop..."
        echo "This may take 5-10 minutes depending on your internet speed."
        echo ""
        
        if curl -L -o "$download_path" "$docker_url"; then
            echo "✓ Download complete!"
            echo "  Saved to: $download_path"
            echo ""
            echo "Now run the installer:"
            echo "  start \"$download_path\""
            echo ""
            
            read -p "Start installer now? (y/n): " install_choice
            if [[ "$install_choice" == "y" || "$install_choice" == "Y" ]]; then
                start "$download_path"
                echo ""
                echo "Follow the installation wizard."
                echo "Remember to:"
                echo "  1. Check 'Install required Windows components for WSL 2'"
                echo "  2. Restart your computer when prompted"
                echo "  3. After restart, enable Kubernetes in Docker Desktop Settings"
                echo ""
            fi
        else
            echo "✗ Download failed."
            echo ""
            echo "Please download manually from:"
            echo "  $docker_url"
            echo ""
        fi
    else
        echo ""
        echo "Manual download instructions:"
        echo "  1. Open browser and visit: $docker_url"
        echo "  2. Download and run the installer"
        echo "  3. Follow installation wizard"
        echo "  4. Restart computer when prompted"
        echo ""
    fi
else
    # Docker is installed, check if it's running
    echo "Step 4: Checking Docker status..."
    
    if docker ps &> /dev/null; then
        echo "✓ Docker is running!"
        
        # Check Kubernetes
        echo ""
        echo "Step 5: Checking Kubernetes..."
        
        if command -v kubectl &> /dev/null; then
            echo "✓ kubectl is installed"
            
            if kubectl get nodes &> /dev/null; then
                echo "✓ Kubernetes is running!"
                echo ""
                echo "========================================"
                echo "✓ ALL REQUIREMENTS MET!"
                echo "========================================"
                echo ""
                echo "You're ready to deploy! Run:"
                echo "  ./deploy-local.sh"
                echo ""
            else
                echo "✗ Kubernetes is not running"
                echo ""
                echo "To enable Kubernetes:"
                echo "  1. Open Docker Desktop"
                echo "  2. Click Settings (gear icon)"
                echo "  3. Go to Kubernetes tab"
                echo "  4. Check 'Enable Kubernetes'"
                echo "  5. Click 'Apply & Restart'"
                echo ""
            fi
        else
            echo "✗ kubectl not found"
            echo ""
            echo "Kubernetes may not be enabled."
            echo "Enable it in Docker Desktop Settings > Kubernetes"
            echo ""
        fi
    else
        echo "✗ Docker is not running"
        echo ""
        echo "Please start Docker Desktop from the Start Menu"
        echo ""
    fi
fi

# Summary
echo "========================================"
echo "Summary"
echo "========================================"
echo ""

if [ "$docker_installed" = true ]; then
    echo "Docker: Installed ✓"
    if docker ps &> /dev/null; then
        echo "Docker Running: Yes ✓"
    else
        echo "Docker Running: No ✗ (Start Docker Desktop)"
    fi
else
    echo "Docker: Not Installed ✗"
    echo ""
    echo "Next Steps:"
    echo "  1. Download Docker Desktop from:"
    echo "     $docker_url"
    echo "  2. Run the installer"
    echo "  3. Restart computer"
    echo "  4. Enable Kubernetes in Docker Desktop"
    echo "  5. Run: ./deploy-local.sh"
fi

echo ""
echo "Documentation:"
echo "  - Quick Start: LOCAL_QUICKSTART.md"
echo "  - Full Guide: LOCAL_DEPLOYMENT_WINDOWS.md"
echo "  - System Setup: YOUR_SYSTEM_SETUP.md"
echo ""
