#!/bin/bash

# System Setup Script for Windows VPS
# Handles dependency installation, health checks, and GitHub configuration
# Version: 2.0.0

set -euo pipefail

# Script configuration
SCRIPT_VERSION="2.0.0"
SCRIPT_NAME="setup.sh"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_FILE="$PROJECT_ROOT/logs/vps-setup.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Create log directory if it doesn't exist
    mkdir -p "$(dirname "$LOG_FILE")"
    
    # Log to file
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    # Also output to console with colors
    case "$level" in
        "ERROR")   echo -e "${RED}❌ ERROR: $message${NC}" ;;
        "WARNING") echo -e "${YELLOW}⚠️  WARNING: $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}✅ SUCCESS: $message${NC}" ;;
        "INFO")    echo -e "${BLUE}ℹ️  INFO: $message${NC}" ;;
        "DEBUG")   echo -e "${PURPLE}🐛 DEBUG: $message${NC}" ;;
        *)         echo -e "${CYAN}📝 $message${NC}" ;;
    esac
}

# Error handling
error_exit() {
    log "ERROR" "$1"
    exit 1
}

# Success message
success_msg() {
    log "SUCCESS" "$1"
}

# Warning message
warn_msg() {
    log "WARNING" "$1"
}

# Info message
info_msg() {
    log "INFO" "$1"
}

# Print banner
print_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════╗
║                     Windows VPS Setup Script                        ║
║                          Version 2.0.0                              ║
║                                                                      ║
║  🖥️  Setting up your Windows VPS environment for learning           ║
║  📚 Perfect for school projects and development work                 ║
╚══════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Check if running in GitHub Actions
is_github_actions() {
    [[ -n "${GITHUB_ACTIONS:-}" ]]
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install package based on OS
install_package() {
    local package="$1"
    local os="$2"
    
    info_msg "Installing $package for $os..."
    
    case "$os" in
        "linux")
            if command_exists apt-get; then
                sudo apt-get update && sudo apt-get install -y "$package"
            elif command_exists yum; then
                sudo yum install -y "$package"
            elif command_exists dnf; then
                sudo dnf install -y "$package"
            elif command_exists pacman; then
                sudo pacman -S --noconfirm "$package"
            else
                warn_msg "Unknown package manager for Linux"
                return 1
            fi
            ;;
        "macos")
            if command_exists brew; then
                brew install "$package"
            else
                warn_msg "Homebrew not found. Please install Homebrew first."
                return 1
            fi
            ;;
        "windows")
            if command_exists choco; then
                choco install -y "$package"
            elif command_exists winget; then
                winget install "$package"
            else
                warn_msg "No package manager found for Windows. Please install Chocolatey or use winget."
                return 1
            fi
            ;;
        *)
            warn_msg "Unsupported operating system: $os"
            return 1
            ;;
    esac
}

# Check and install dependencies
install_dependencies() {
    local os
    os=$(detect_os)
    
    info_msg "Detected operating system: $os"
    info_msg "Installing required dependencies..."
    
    local deps=()
    local optional_deps=()
    
    # Core dependencies
    deps+=("curl" "jq" "git")
    
    # OS-specific dependencies
    case "$os" in
        "linux"|"macos")
            deps+=("tar" "gzip" "bash")
            optional_deps+=("yq" "wget" "zip" "unzip")
            ;;
        "windows")
            # Most tools are available in Git Bash or WSL
            optional_deps+=("wget" "zip" "unzip")
            ;;
    esac
    
    # Check and install core dependencies
    local missing_deps=()
    for dep in "${deps[@]}"; do
        if ! command_exists "$dep"; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        info_msg "Installing missing dependencies: ${missing_deps[*]}"
        
        for dep in "${missing_deps[@]}"; do
            if ! install_package "$dep" "$os"; then
                error_exit "Failed to install dependency: $dep"
            fi
        done
    else
        success_msg "All core dependencies are already installed"
    fi
    
    # Check optional dependencies
    info_msg "Checking optional dependencies..."
    for dep in "${optional_deps[@]}"; do
        if command_exists "$dep"; then
            success_msg "Optional dependency available: $dep"
        else
            info_msg "Optional dependency not found: $dep (will install if needed)"
        fi
    done
    
    success_msg "Dependency installation completed"
}

# Setup project directories
setup_directories() {
    info_msg "Setting up project directories..."
    
    local dirs=(
        "$PROJECT_ROOT/logs"
        "$PROJECT_ROOT/backups"
        "$PROJECT_ROOT/templates"
        "$PROJECT_ROOT/TASTRVPS/scripts"
        "$PROJECT_ROOT/docs"
    )
    
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            success_msg "Created directory: $(basename "$dir")"
        else
            info_msg "Directory already exists: $(basename "$dir")"
        fi
    done
    
    # Set permissions for scripts
    if [[ -f "$PROJECT_ROOT/TASTRVPS/backupre-store.sh" ]]; then
        chmod +x "$PROJECT_ROOT/TASTRVPS/backupre-store.sh"
        success_msg "Set execute permissions for backupre-store.sh"
    fi
    
    success_msg "Directory setup completed"
}

# Configure Git (if needed)
setup_git_config() {
    info_msg "Configuring Git settings..."
    
    # Check if Git is configured
    local git_name
    local git_email
    
    git_name=$(git config --global user.name 2>/dev/null || echo "")
    git_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -z "$git_name" ]]; then
        if is_github_actions; then
            git config --global user.name "VPS Auto Setup"
            git config --global user.email "vps@github.actions"
            success_msg "Configured Git for GitHub Actions"
        else
            warn_msg "Git user.name not configured. Please run: git config --global user.name 'Your Name'"
        fi
    else
        success_msg "Git user.name already configured: $git_name"
    fi
    
    if [[ -z "$git_email" ]]; then
        if is_github_actions; then
            # Already set above
            success_msg "Git email configured for GitHub Actions"
        else
            warn_msg "Git user.email not configured. Please run: git config --global user.email 'your@email.com'"
        fi
    else
        success_msg "Git user.email already configured: $git_email"
    fi
    
    # Set up Git to handle line endings properly
    git config --global core.autocrlf input
    git config --global core.safecrlf false
    
    success_msg "Git configuration completed"
}

# Setup GitHub Actions environment
setup_github_actions() {
    if is_github_actions; then
        info_msg "Configuring GitHub Actions environment..."
        
        # Set environment variables
        echo "VPS_SETUP_VERSION=$SCRIPT_VERSION" >> "$GITHUB_ENV"
        echo "VPS_SETUP_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')" >> "$GITHUB_ENV"
        
        # Create GitHub Actions summary
        {
            echo "# 🖥️ Windows VPS Setup Complete"
            echo ""
            echo "## ✅ Setup Summary"
            echo "- **Version:** $SCRIPT_VERSION"
            echo "- **Timestamp:** $(date '+%Y-%m-%d %H:%M:%S')"
            echo "- **OS:** $(detect_os)"
            echo "- **Project Root:** $PROJECT_ROOT"
            echo ""
            echo "## 📁 Created Directories"
            echo "- logs/ - System and application logs"
            echo "- backups/ - Backup storage"
            echo "- templates/ - Configuration templates"
            echo "- docs/ - Documentation"
            echo ""
            echo "## 🛠️ Installed Dependencies"
            echo "- curl - HTTP client"
            echo "- jq - JSON processor"
            echo "- git - Version control"
            echo "- bash - Shell scripting"
            echo ""
            echo "## 🎯 Next Steps"
            echo "1. Your VPS environment is ready!"
            echo "2. Remote desktop connection will be available shortly"
            echo "3. Check the workflow logs for connection details"
            echo ""
            echo "---"
            echo "*Setup completed by $SCRIPT_NAME v$SCRIPT_VERSION*"
        } >> "$GITHUB_STEP_SUMMARY"
        
        success_msg "GitHub Actions environment configured"
    fi
}

# Perform health checks
perform_health_checks() {
    info_msg "Performing system health checks..."
    
    local health_issues=0
    
    # Check disk space
    local disk_usage
    disk_usage=$(df "$PROJECT_ROOT" | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [[ $disk_usage -gt 90 ]]; then
        warn_msg "High disk usage: ${disk_usage}%"
        ((health_issues++))
    else
        success_msg "Disk usage OK: ${disk_usage}%"
    fi
    
    # Check memory (if available)
    if command_exists free; then
        local mem_usage
        mem_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
        
        if [[ $mem_usage -gt 85 ]]; then
            warn_msg "High memory usage: ${mem_usage}%"
            ((health_issues++))
        else
            success_msg "Memory usage OK: ${mem_usage}%"
        fi
    fi
    
    # Check required files
    local required_files=(
        "$PROJECT_ROOT/TASTRVPS/config.yml"
        "$PROJECT_ROOT/TASTRVPS/backup.conf"
        "$PROJECT_ROOT/TASTRVPS/backupre-store.sh"
    )
    
    for file in "${required_files[@]}"; do
        if [[ -f "$file" ]]; then
            success_msg "Required file found: $(basename "$file")"
        else
            warn_msg "Required file missing: $(basename "$file")"
            ((health_issues++))
        fi
    done
    
    # Check dependencies
    local deps=("curl" "jq" "git" "bash")
    for dep in "${deps[@]}"; do
        if command_exists "$dep"; then
            success_msg "Dependency available: $dep"
        else
            warn_msg "Dependency missing: $dep"
            ((health_issues++))
        fi
    done
    
    # Summary
    if [[ $health_issues -eq 0 ]]; then
        success_msg "All health checks passed! 🎉"
        return 0
    else
        warn_msg "Found $health_issues health issue(s)"
        return 1
    fi
}

# Create initial templates
create_templates() {
    info_msg "Creating configuration templates..."
    
    local template_dir="$PROJECT_ROOT/templates"
    
    # Create example workflow dispatch payload
    cat > "$template_dir/workflow-dispatch.json" << 'EOF'
{
    "ref": "main",
    "inputs": {
        "vps_name": "StudyVPS",
        "backup": false,
        "timeout_minutes": 360,
        "windows_password": "",
        "ngrok_token": ""
    }
}
EOF
    
    # Create example repository dispatch payload
    cat > "$template_dir/repository-dispatch.json" << 'EOF'
{
    "event_type": "restart-vps",
    "client_payload": {
        "vps_name": "StudyVPS",
        "backup": true,
        "timeout_minutes": 360,
        "restart_count": 1
    }
}
EOF
    
    # Create example environment file
    cat > "$template_dir/example.env" << 'EOF'
# Example environment variables for Windows VPS
# Copy this file to .env and fill in your values

# GitHub Configuration (required for backup to GitHub Releases)
GITHUB_TOKEN=your_github_token_here

# Ngrok Configuration (optional, for stable tunneling)
NGROK_TOKEN=your_ngrok_token_here

# Custom Windows Password (optional)
WINDOWS_PASSWORD=your_secure_password_here

# VPS Configuration
VPS_NAME=StudyVPS
TIMEOUT_MINUTES=360
AUTO_RESTART=true

# Backup Configuration
BACKUP_ENABLED=true
BACKUP_RETENTION_DAYS=30
MAX_LOCAL_BACKUPS=5
EOF
    
    success_msg "Configuration templates created"
}

# Show setup summary
show_setup_summary() {
    echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                        🎉 Setup Complete! 🎉                          ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    
    echo -e "\n${CYAN}📋 Setup Summary:${NC}"
    echo -e "   ✅ Dependencies installed and verified"
    echo -e "   ✅ Project directories created"
    echo -e "   ✅ Git configuration updated"
    echo -e "   ✅ Health checks completed"
    echo -e "   ✅ Configuration templates created"
    
    echo -e "\n${CYAN}📁 Project Structure:${NC}"
    echo -e "   📂 TASTRVPS/          - Main application files"
    echo -e "   📂 .github/workflows/ - GitHub Actions workflows"
    echo -e "   📂 logs/              - System logs"
    echo -e "   📂 backups/           - Backup storage"
    echo -e "   📂 templates/         - Configuration templates"
    echo -e "   📂 docs/              - Documentation"
    
    echo -e "\n${CYAN}🚀 Next Steps:${NC}"
    echo -e "   1. Go to your repository's Actions tab"
    echo -e "   2. Select 'Create Windows VPS (Auto Restart)' workflow"
    echo -e "   3. Click 'Run workflow' button"
    echo -e "   4. Wait 2-3 minutes for VPS to start"
    echo -e "   5. Use the provided connection info to access your VPS"
    
    echo -e "\n${CYAN}💡 Tips:${NC}"
    echo -e "   • Your VPS will run for up to 6 hours"
    echo -e "   • It will automatically restart when time expires"
    echo -e "   • Backup/restore is available for persistent storage"
    echo -e "   • Check logs/ directory for detailed information"
    
    echo -e "\n${YELLOW}🔧 Optional Configuration:${NC}"
    echo -e "   • Add NGROK_TOKEN secret for stable tunneling"
    echo -e "   • Customize config.yml for advanced settings"
    echo -e "   • Set up custom Windows password via secrets"
    
    echo -e "\n${GREEN}🎓 Happy learning and coding! 📚${NC}"
}

# Show help
show_help() {
    cat << EOF
${GREEN}$SCRIPT_NAME v$SCRIPT_VERSION${NC}
System Setup Script for Windows VPS

${YELLOW}USAGE:${NC}
    $SCRIPT_NAME [command] [options]

${YELLOW}COMMANDS:${NC}
    ${CYAN}install${NC}     Install dependencies and setup environment (default)
    ${CYAN}health${NC}      Perform health checks only
    ${CYAN}templates${NC}   Create configuration templates only
    ${CYAN}git${NC}         Configure Git settings only
    ${CYAN}help${NC}        Show this help message

${YELLOW}OPTIONS:${NC}
    ${CYAN}--skip-deps${NC}     Skip dependency installation
    ${CYAN}--skip-health${NC}   Skip health checks
    ${CYAN}--quiet${NC}         Reduce output verbosity
    ${CYAN}--debug${NC}         Enable debug output

${YELLOW}EXAMPLES:${NC}
    $SCRIPT_NAME                    # Full setup
    $SCRIPT_NAME install            # Full setup (explicit)
    $SCRIPT_NAME health             # Health checks only
    $SCRIPT_NAME --skip-deps        # Setup without installing dependencies
    $SCRIPT_NAME install --quiet    # Quiet installation

${YELLOW}ENVIRONMENT:${NC}
    This script automatically detects:
    • Operating system (Linux, macOS, Windows)
    • GitHub Actions environment
    • Available package managers
    • Existing configurations

${YELLOW}FEATURES:${NC}
    ✅ Cross-platform compatibility
    ✅ Automatic dependency detection and installation
    ✅ Health checks and system validation
    ✅ Git configuration
    ✅ GitHub Actions integration
    ✅ Configuration template generation
    ✅ Comprehensive logging

For more information, visit: https://github.com/your-username/windows-vps
EOF
}

# Main script logic
main() {
    local command="${1:-install}"
    local skip_deps=false
    local skip_health=false
    local quiet=false
    local debug=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-deps)
                skip_deps=true
                shift
                ;;
            --skip-health)
                skip_health=true
                shift
                ;;
            --quiet)
                quiet=true
                shift
                ;;
            --debug)
                debug=true
                shift
                ;;
            help|-h|--help)
                show_help
                exit 0
                ;;
            *)
                if [[ "$1" != "$command" ]]; then
                    command="$1"
                fi
                shift
                ;;
        esac
    done
    
    # Set debug mode
    if [[ "$debug" == "true" ]]; then
        set -x
    fi
    
    # Show banner (unless quiet)
    if [[ "$quiet" != "true" ]]; then
        print_banner
    fi
    
    info_msg "Starting Windows VPS setup (command: $command)..."
    
    case "$command" in
        "install")
            if [[ "$skip_deps" != "true" ]]; then
                install_dependencies
            fi
            setup_directories
            setup_git_config
            setup_github_actions
            create_templates
            if [[ "$skip_health" != "true" ]]; then
                perform_health_checks
            fi
            if [[ "$quiet" != "true" ]]; then
                show_setup_summary
            fi
            ;;
        "health")
            perform_health_checks
            ;;
        "templates")
            create_templates
            ;;
        "git")
            setup_git_config
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $command${NC}"
            echo -e "${YELLOW}💡 Use '$SCRIPT_NAME help' for usage information${NC}"
            exit 1
            ;;
    esac
    
    success_msg "Setup script completed successfully!"
}

# Run main function with all arguments
main "$@"
