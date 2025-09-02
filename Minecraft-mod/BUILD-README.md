# Minecraft Fabric Mod Build Scripts

This directory contains automated build scripts for compiling your Minecraft Fabric mod into a JAR file. The scripts will automatically detect and install required dependencies if they're not already present.

## Scripts Available

### Windows (PowerShell)
- **File:** `build-mod.ps1`
- **Requirements:** PowerShell 5.1 or later (comes with Windows)

### Unix/Linux/macOS (Bash)
- **File:** `build-mod.sh`
- **Requirements:** Bash shell (comes with most Unix-like systems)

## Dependencies

The scripts will automatically install these dependencies if not found:

1. **Java JDK 17** - Required for Minecraft 1.20.1 mod development
2. **Gradle** - Build automation tool for the project

### Windows Installation Methods
- Uses **Chocolatey** package manager for automatic installation
- If Chocolatey is not installed, the script will install it first

### Unix/Linux/macOS Installation Methods
- **Ubuntu/Debian:** Uses `apt-get` package manager
- **CentOS/RHEL:** Uses `yum` package manager  
- **Arch Linux:** Uses `pacman` package manager
- **macOS:** Uses **Homebrew** (install from https://brew.sh/ if needed)

## Usage

### Windows PowerShell

1. **Run with default settings:**
   ```powershell
   .\build-mod.ps1
   ```

2. **Clean build (removes previous build files):**
   ```powershell
   .\build-mod.ps1 -Clean
   ```

3. **Skip tests (faster build):**
   ```powershell
   .\build-mod.ps1 -SkipTests
   ```

4. **Clean build and skip tests:**
   ```powershell
   .\build-mod.ps1 -Clean -SkipTests
   ```

### Unix/Linux/macOS Bash

1. **Make script executable (first time only):**
   ```bash
   chmod +x build-mod.sh
   ```

2. **Run with default settings:**
   ```bash
   ./build-mod.sh
   ```

3. **Clean build:**
   ```bash
   ./build-mod.sh --clean
   ```

4. **Skip tests:**
   ```bash
   ./build-mod.sh --skip-tests
   ```

5. **Clean build and skip tests:**
   ```bash
   ./build-mod.sh --clean --skip-tests
   ```

## Project Structure

The scripts expect to find either:
- A `feather-waypoints` subdirectory containing the mod project
- Or `build.gradle` file in the current directory

## Output

After a successful build, you'll find the compiled JAR file(s) in:
- `build/libs/` directory within your project
- The script will display the location and size of generated JAR files

## Troubleshooting

### Windows Issues

1. **Execution Policy Error:**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **Administrator Rights:** 
   - Some installations may require administrator privileges
   - Run PowerShell as Administrator if needed

### Unix/Linux/macOS Issues

1. **Permission Denied:**
   ```bash
   chmod +x build-mod.sh
   ```

2. **Missing sudo privileges:**
   - Package installation requires sudo access
   - Run with appropriate permissions or install dependencies manually

### General Issues

1. **Git Repository Issues:**
   - If the project files are missing, restore them from your git repository
   - Check `git status` to see current repository state

2. **Java Version Issues:**
   - Minecraft 1.20.1 requires Java 17 or later
   - The scripts install OpenJDK 17 by default

3. **Build Failures:**
   - Check that all project files are present
   - Ensure proper project structure with `src/` directory
   - Verify `build.gradle` configuration

## Manual Build (Alternative)

If the automated scripts don't work for your system, you can build manually:

```bash
# Navigate to project directory
cd feather-waypoints  # or wherever your build.gradle is located

# Using Gradle wrapper (preferred)
./gradlew build

# Or using system Gradle
gradle build
```

## Support

- Ensure your project follows standard Fabric mod structure
- Check that `fabric.mod.json` exists in `src/main/resources/`
- Verify all dependencies in `build.gradle` are properly configured

---

**Note:** These scripts are designed for the Fabric mod loader. For Forge mods, the process might be different.
