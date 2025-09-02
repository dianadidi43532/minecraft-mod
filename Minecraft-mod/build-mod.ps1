# Minecraft Fabric Mod Build Script
# This script automatically installs dependencies and compiles the mod to JAR

param(
    [switch]$Clean = $false,
    [switch]$SkipTests = $false
)

Write-Host "=== Minecraft Fabric Mod Build Script ===" -ForegroundColor Cyan
Write-Host "Starting build process..." -ForegroundColor Green

# Function to check if a command exists
function Test-Command {
    param($Command)
    try {
        if (Get-Command $Command -ErrorAction Stop) { return $true }
    } catch {
        return $false
    }
}

# Function to install Chocolatey if not present
function Install-Chocolatey {
    Write-Host "Installing Chocolatey package manager..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    # Refresh environment variables
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
}

# Function to install Java JDK
function Install-Java {
    Write-Host "Installing Java JDK 17..." -ForegroundColor Yellow
    if (!(Test-Command "choco")) {
        Install-Chocolatey
    }
    choco install openjdk17 -y
    
    # Refresh environment variables
    refreshenv
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
}

# Function to install Gradle
function Install-Gradle {
    Write-Host "Installing Gradle..." -ForegroundColor Yellow
    if (!(Test-Command "choco")) {
        Install-Chocolatey
    }
    choco install gradle -y
    
    # Refresh environment variables
    refreshenv
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
}

# Check for Java
Write-Host "Checking for Java..." -ForegroundColor Blue
if (!(Test-Command "java")) {
    Write-Host "Java not found. Installing Java JDK 17..." -ForegroundColor Red
    Install-Java
} else {
    $javaVersion = java -version 2>&1
    Write-Host "Java found: $($javaVersion[0])" -ForegroundColor Green
}

# Check for Gradle
Write-Host "Checking for Gradle..." -ForegroundColor Blue
if (!(Test-Command "gradle")) {
    Write-Host "Gradle not found. Installing Gradle..." -ForegroundColor Red
    Install-Gradle
} else {
    $gradleVersion = gradle --version | Select-String "Gradle"
    Write-Host "Gradle found: $gradleVersion" -ForegroundColor Green
}

# Navigate to project directory
$projectPath = Join-Path $PSScriptRoot "feather-waypoints"
if (Test-Path $projectPath) {
    Set-Location $projectPath
    Write-Host "Changed to project directory: $projectPath" -ForegroundColor Green
} else {
    Write-Host "Project directory 'feather-waypoints' not found in current location." -ForegroundColor Red
    Write-Host "Current location: $PSScriptRoot" -ForegroundColor Red
    Write-Host "Looking for Gradle files in current directory..." -ForegroundColor Yellow
    
    # Look for gradle files in current directory
    if (Test-Path "build.gradle") {
        Write-Host "Found build.gradle in current directory, proceeding..." -ForegroundColor Green
    } else {
        Write-Host "No build.gradle found. Please ensure you're in the correct project directory." -ForegroundColor Red
        exit 1
    }
}

# Clean build if requested
if ($Clean) {
    Write-Host "Cleaning previous build..." -ForegroundColor Yellow
    if (Test-Path "gradlew.bat") {
        .\gradlew.bat clean
    } else {
        gradle clean
    }
}

# Make gradlew executable (if on Unix-like system in Windows)
if (Test-Path "gradlew") {
    Write-Host "Making gradlew executable..." -ForegroundColor Blue
}

# Build the mod
Write-Host "Building Minecraft mod..." -ForegroundColor Blue
try {
    if (Test-Path "gradlew.bat") {
        Write-Host "Using Gradle wrapper..." -ForegroundColor Green
        if ($SkipTests) {
            .\gradlew.bat build -x test
        } else {
            .\gradlew.bat build
        }
    } else {
        Write-Host "Using system Gradle..." -ForegroundColor Green
        if ($SkipTests) {
            gradle build -x test
        } else {
            gradle build
        }
    }
    
    Write-Host "Build completed successfully!" -ForegroundColor Green
    
    # Find and display the built JAR file(s)
    Write-Host "Looking for compiled JAR files..." -ForegroundColor Blue
    $jarFiles = Get-ChildItem -Path "build\libs" -Filter "*.jar" -ErrorAction SilentlyContinue
    
    if ($jarFiles) {
        Write-Host "Built JAR file(s):" -ForegroundColor Green
        foreach ($jar in $jarFiles) {
            $fullPath = $jar.FullName
            $size = [math]::Round($jar.Length / 1MB, 2)
            Write-Host "  - $($jar.Name) (${size} MB)" -ForegroundColor Cyan
            Write-Host "    Location: $fullPath" -ForegroundColor Gray
        }
    } else {
        Write-Host "No JAR files found in build\libs directory." -ForegroundColor Red
    }
    
} catch {
    Write-Host "Build failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "=== Build Process Complete ===" -ForegroundColor Cyan
