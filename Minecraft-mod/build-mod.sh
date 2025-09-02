#!/bin/bash
# Minecraft Fabric Mod Build Script
# This script automatically installs dependencies and compiles the mod to JAR

set -e  # Exit on any error

# Parse command line arguments
CLEAN=false
SKIP_TESTS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            CLEAN=true
            shift
            ;;
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--clean] [--skip-tests]"
            exit 1
            ;;
    esac
done

echo "=== Minecraft Fabric Mod Build Script ==="
echo "Starting build process..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists apt-get; then
            echo "ubuntu"
        elif command_exists yum; then
            echo "centos"
        elif command_exists pacman; then
            echo "arch"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Function to install Java on different systems
install_java() {
    echo "Installing Java JDK 17..."
    OS=$(detect_os)
    
    case $OS in
        "ubuntu")
            sudo apt-get update
            sudo apt-get install -y openjdk-17-jdk
            ;;
        "centos")
            sudo yum install -y java-17-openjdk-devel
            ;;
        "arch")
            sudo pacman -S --noconfirm jdk17-openjdk
            ;;
        "macos")
            if command_exists brew; then
                brew install openjdk@17
                echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
                source ~/.zshrc
            else
                echo "Please install Homebrew first: https://brew.sh/"
                exit 1
            fi
            ;;
        *)
            echo "Unsupported OS. Please install Java JDK 17 manually."
            exit 1
            ;;
    esac
}

# Function to install Gradle
install_gradle() {
    echo "Installing Gradle..."
    OS=$(detect_os)
    
    case $OS in
        "ubuntu")
            # Install using SDKMAN
            if ! command_exists sdk; then
                curl -s "https://get.sdkman.io" | bash
                source "$HOME/.sdkman/bin/sdkman-init.sh"
            fi
            sdk install gradle
            ;;
        "centos")
            # Download and install Gradle manually
            GRADLE_VERSION="8.1.1"
            cd /opt
            sudo wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
            sudo unzip gradle-${GRADLE_VERSION}-bin.zip
            sudo ln -s /opt/gradle-${GRADLE_VERSION}/bin/gradle /usr/local/bin/gradle
            rm gradle-${GRADLE_VERSION}-bin.zip
            ;;
        "arch")
            sudo pacman -S --noconfirm gradle
            ;;
        "macos")
            if command_exists brew; then
                brew install gradle
            else
                echo "Please install Homebrew first: https://brew.sh/"
                exit 1
            fi
            ;;
        *)
            echo "Unsupported OS. Please install Gradle manually."
            exit 1
            ;;
    esac
}

# Check for Java
echo "Checking for Java..."
if ! command_exists java; then
    echo "Java not found. Installing Java JDK 17..."
    install_java
else
    JAVA_VERSION=$(java -version 2>&1 | head -n 1)
    echo "Java found: $JAVA_VERSION"
fi

# Check for Gradle
echo "Checking for Gradle..."
if ! command_exists gradle; then
    echo "Gradle not found. Installing Gradle..."
    install_gradle
else
    GRADLE_VERSION=$(gradle --version | grep "Gradle")
    echo "Gradle found: $GRADLE_VERSION"
fi

# Navigate to project directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_PATH="$SCRIPT_DIR/feather-waypoints"

if [ -d "$PROJECT_PATH" ]; then
    cd "$PROJECT_PATH"
    echo "Changed to project directory: $PROJECT_PATH"
else
    echo "Project directory 'feather-waypoints' not found in current location."
    echo "Current location: $SCRIPT_DIR"
    echo "Looking for Gradle files in current directory..."
    
    # Look for gradle files in current directory
    if [ -f "build.gradle" ]; then
        echo "Found build.gradle in current directory, proceeding..."
    else
        echo "No build.gradle found. Please ensure you're in the correct project directory."
        exit 1
    fi
fi

# Clean build if requested
if [ "$CLEAN" = true ]; then
    echo "Cleaning previous build..."
    if [ -f "./gradlew" ]; then
        ./gradlew clean
    else
        gradle clean
    fi
fi

# Make gradlew executable
if [ -f "./gradlew" ]; then
    chmod +x ./gradlew
    echo "Made gradlew executable"
fi

# Build the mod
echo "Building Minecraft mod..."
if [ -f "./gradlew" ]; then
    echo "Using Gradle wrapper..."
    if [ "$SKIP_TESTS" = true ]; then
        ./gradlew build -x test
    else
        ./gradlew build
    fi
else
    echo "Using system Gradle..."
    if [ "$SKIP_TESTS" = true ]; then
        gradle build -x test
    else
        gradle build
    fi
fi

echo "Build completed successfully!"

# Find and display the built JAR file(s)
echo "Looking for compiled JAR files..."
if [ -d "build/libs" ]; then
    JAR_FILES=$(find build/libs -name "*.jar" 2>/dev/null)
    
    if [ -n "$JAR_FILES" ]; then
        echo "Built JAR file(s):"
        for jar in $JAR_FILES; do
            SIZE=$(du -h "$jar" | cut -f1)
            echo "  - $(basename "$jar") ($SIZE)"
            echo "    Location: $(realpath "$jar")"
        done
    else
        echo "No JAR files found in build/libs directory."
    fi
else
    echo "build/libs directory not found."
fi

echo "=== Build Process Complete ==="
