#!/bin/bash

# YAML Configuration Management Script
# Handles configuration loading, validation, and environment variable export
# Version: 2.0.0

set -euo pipefail

# Script configuration
SCRIPT_VERSION="2.0.0"
SCRIPT_NAME="config-manager.sh"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_FILE="$PROJECT_ROOT/TASTRVPS/config.yml"
BACKUP_CONFIG="$PROJECT_ROOT/TASTRVPS/backup.conf"
LOG_FILE="$PROJECT_ROOT/logs/config-manager.log"

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

# Debug message
debug_msg() {
    if [[ "${DEBUG_MODE:-false}" == "true" ]]; then
        log "DEBUG" "$1"
    fi
}

# Check if yq is available
check_yq_dependency() {
    if ! command -v yq >/dev/null 2>&1; then
        warn_msg "yq not found. Attempting to install..."
        
        # Try to install yq
        if command -v wget >/dev/null 2>&1; then
            local yq_version="v4.35.2"
            local yq_binary="yq_linux_amd64"
            
            # Detect architecture
            case "$(uname -m)" in
                x86_64) yq_binary="yq_linux_amd64" ;;
                aarch64|arm64) yq_binary="yq_linux_arm64" ;;
                *) warn_msg "Unsupported architecture for yq auto-install" ;;
            esac
            
            # Download and install yq
            local temp_dir=$(mktemp -d)
            if wget -O "$temp_dir/yq" "https://github.com/mikefarah/yq/releases/download/$yq_version/$yq_binary" 2>/dev/null; then
                chmod +x "$temp_dir/yq"
                
                # Try to move to a location in PATH
                if [[ -w "/usr/local/bin" ]]; then
                    sudo mv "$temp_dir/yq" "/usr/local/bin/yq" 2>/dev/null || cp "$temp_dir/yq" "$HOME/.local/bin/yq" 2>/dev/null || {
                        mkdir -p "$PROJECT_ROOT/bin"
                        cp "$temp_dir/yq" "$PROJECT_ROOT/bin/yq"
                        export PATH="$PROJECT_ROOT/bin:$PATH"
                    }
                    success_msg "yq installed successfully"
                else
                    mkdir -p "$PROJECT_ROOT/bin"
                    cp "$temp_dir/yq" "$PROJECT_ROOT/bin/yq"
                    export PATH="$PROJECT_ROOT/bin:$PATH"
                    success_msg "yq installed to project bin directory"
                fi
                
                rm -rf "$temp_dir"
            else
                rm -rf "$temp_dir"
                error_exit "Failed to download yq. Please install it manually: https://github.com/mikefarah/yq"
            fi
        else
            error_exit "yq is required but not found. Please install it: https://github.com/mikefarah/yq"
        fi
    fi
    
    # Verify yq is working
    if ! yq --version >/dev/null 2>&1; then
        error_exit "yq is not working properly"
    fi
    
    success_msg "yq dependency verified"
}

# Validate YAML syntax
validate_yaml_syntax() {
    local yaml_file="$1"
    
    if [[ ! -f "$yaml_file" ]]; then
        warn_msg "YAML file not found: $yaml_file"
        return 1
    fi
    
    info_msg "Validating YAML syntax: $(basename "$yaml_file")"
    
    # Check syntax with yq
    if yq eval '.' "$yaml_file" >/dev/null 2>&1; then
        success_msg "YAML syntax is valid"
        return 0
    else
        error_exit "YAML syntax error in $yaml_file"
    fi
}

# Load configuration from YAML
load_yaml_config() {
    local config_file="${1:-$CONFIG_FILE}"
    
    info_msg "Loading configuration from: $(basename "$config_file")"
    
    if [[ ! -f "$config_file" ]]; then
        warn_msg "Configuration file not found: $config_file"
        return 1
    fi
    
    # Validate syntax first
    validate_yaml_syntax "$config_file"
    
    # Export configuration as environment variables
    info_msg "Exporting configuration to environment variables..."
    
    # VPS configuration
    export VPS_NAME=$(yq eval '.vps.name // "StudyVPS"' "$config_file")
    export VPS_DESCRIPTION=$(yq eval '.vps.description // "Windows VPS for learning"' "$config_file")
    export VPS_VERSION=$(yq eval '.vps.version // "2.0.0"' "$config_file")
    export VPS_TIMEOUT_MINUTES=$(yq eval '.vps.timeout_minutes // 360' "$config_file")
    export VPS_AUTO_RESTART=$(yq eval '.vps.auto_restart // true' "$config_file")
    
    # Windows user configuration
    export WINDOWS_USERNAME=$(yq eval '.windows_user.username // "Administrator"' "$config_file")
    export WINDOWS_AUTO_GENERATE_PASSWORD=$(yq eval '.windows_user.auto_generate_password // true' "$config_file")
    export WINDOWS_PASSWORD_LENGTH=$(yq eval '.windows_user.password_length // 12' "$config_file")
    export WINDOWS_ENABLE_RDP=$(yq eval '.windows_user.enable_rdp // true' "$config_file")
    
    # Remote access configuration
    export TMATE_SERVER=$(yq eval '.remote_access.tmate_server // "nyc1.tmate.io"' "$config_file")
    export TMATE_ENABLED=$(yq eval '.remote_access.tmate_enabled // true' "$config_file")
    export NGROK_ENABLED=$(yq eval '.remote_access.ngrok_enabled // true' "$config_file")
    export NGROK_REGION=$(yq eval '.remote_access.ngrok_region // "us"' "$config_file")
    export PLAYIT_ENABLED=$(yq eval '.remote_access.playit_enabled // true' "$config_file")
    export PLAYIT_AUTO_SETUP=$(yq eval '.remote_access.playit_auto_setup // true' "$config_file")
    
    # Backup configuration
    export BACKUP_ENABLED=$(yq eval '.backup.enabled // true' "$config_file")
    export BACKUP_COMPRESSION_LEVEL=$(yq eval '.backup.compression_level // 6' "$config_file")
    export BACKUP_RETENTION_DAYS=$(yq eval '.backup.retention_days // 30' "$config_file")
    export BACKUP_MAX_LOCAL_BACKUPS=$(yq eval '.backup.max_local_backups // 5' "$config_file")
    
    # Monitoring configuration
    export MONITORING_ENABLED=$(yq eval '.monitoring.enabled // true' "$config_file")
    export MONITORING_CHECK_INTERVAL=$(yq eval '.monitoring.check_interval_seconds // 60' "$config_file")
    export MONITORING_MEMORY_WARNING_GB=$(yq eval '.monitoring.thresholds.memory_warning_gb // 1.0' "$config_file")
    export MONITORING_DISK_WARNING_GB=$(yq eval '.monitoring.thresholds.disk_warning_gb // 2.0' "$config_file")
    export MONITORING_CPU_WARNING_PERCENT=$(yq eval '.monitoring.thresholds.cpu_warning_percent // 80' "$config_file")
    
    # Logging configuration
    export LOGGING_ENABLED=$(yq eval '.logging.enabled // true' "$config_file")
    export LOGGING_LEVEL=$(yq eval '.logging.level // "INFO"' "$config_file")
    export LOGGING_MAX_FILE_SIZE_MB=$(yq eval '.logging.max_file_size_mb // 10' "$config_file")
    export LOGGING_MAX_FILES=$(yq eval '.logging.max_files // 5' "$config_file")
    export LOGGING_DIRECTORY=$(yq eval '.logging.log_directory // "logs/"' "$config_file")
    
    # Security configuration
    export SECURITY_INPUT_VALIDATION=$(yq eval '.security.input_validation // true' "$config_file")
    export SECURITY_SESSION_TIMEOUT=$(yq eval '.security.session_timeout // true' "$config_file")
    export SECURITY_AUTO_CLEANUP=$(yq eval '.security.auto_cleanup // true' "$config_file")
    export SECURITY_PASSWORD_MIN_LENGTH=$(yq eval '.security.password_policy.min_length // 8' "$config_file")
    
    success_msg "Configuration loaded and exported to environment"
}

# Load backup configuration
load_backup_config() {
    local backup_config="${1:-$BACKUP_CONFIG}"
    
    info_msg "Loading backup configuration from: $(basename "$backup_config")"
    
    if [[ ! -f "$backup_config" ]]; then
        warn_msg "Backup configuration file not found: $backup_config"
        return 1
    fi
    
    # Source the backup configuration
    source "$backup_config"
    
    # Export key backup variables
    export BACKUP_VERSION
    export BACKUP_ENABLED
    export COMPRESSION_LEVEL
    export RETENTION_DAYS
    export MAX_LOCAL_BACKUPS
    export PRIMARY_METHOD
    export FALLBACK_METHOD
    export LOCAL_METHOD
    
    success_msg "Backup configuration loaded"
}

# Validate configuration values
validate_configuration() {
    info_msg "Validating configuration values..."
    
    local validation_errors=0
    
    # Validate VPS timeout
    if [[ ! "$VPS_TIMEOUT_MINUTES" =~ ^[0-9]+$ ]] || [[ $VPS_TIMEOUT_MINUTES -lt 30 ]] || [[ $VPS_TIMEOUT_MINUTES -gt 360 ]]; then
        warn_msg "Invalid VPS timeout: $VPS_TIMEOUT_MINUTES (should be 30-360 minutes)"
        ((validation_errors++))
    fi
    
    # Validate password length
    if [[ ! "$WINDOWS_PASSWORD_LENGTH" =~ ^[0-9]+$ ]] || [[ $WINDOWS_PASSWORD_LENGTH -lt 8 ]] || [[ $WINDOWS_PASSWORD_LENGTH -gt 128 ]]; then
        warn_msg "Invalid password length: $WINDOWS_PASSWORD_LENGTH (should be 8-128 characters)"
        ((validation_errors++))
    fi
    
    # Validate compression level
    if [[ ! "$BACKUP_COMPRESSION_LEVEL" =~ ^[0-9]$ ]] || [[ $BACKUP_COMPRESSION_LEVEL -lt 1 ]] || [[ $BACKUP_COMPRESSION_LEVEL -gt 9 ]]; then
        warn_msg "Invalid compression level: $BACKUP_COMPRESSION_LEVEL (should be 1-9)"
        ((validation_errors++))
    fi
    
    # Validate retention days
    if [[ ! "$BACKUP_RETENTION_DAYS" =~ ^[0-9]+$ ]] || [[ $BACKUP_RETENTION_DAYS -lt 1 ]] || [[ $BACKUP_RETENTION_DAYS -gt 365 ]]; then
        warn_msg "Invalid retention days: $BACKUP_RETENTION_DAYS (should be 1-365 days)"
        ((validation_errors++))
    fi
    
    # Validate monitoring interval
    if [[ ! "$MONITORING_CHECK_INTERVAL" =~ ^[0-9]+$ ]] || [[ $MONITORING_CHECK_INTERVAL -lt 10 ]] || [[ $MONITORING_CHECK_INTERVAL -gt 3600 ]]; then
        warn_msg "Invalid monitoring interval: $MONITORING_CHECK_INTERVAL (should be 10-3600 seconds)"
        ((validation_errors++))
    fi
    
    # Validate logging level
    case "$LOGGING_LEVEL" in
        "DEBUG"|"INFO"|"WARNING"|"ERROR") ;;
        *) 
            warn_msg "Invalid logging level: $LOGGING_LEVEL (should be DEBUG, INFO, WARNING, or ERROR)"
            ((validation_errors++))
            ;;
    esac
    
    # Summary
    if [[ $validation_errors -eq 0 ]]; then
        success_msg "All configuration values are valid"
        return 0
    else
        warn_msg "Found $validation_errors configuration validation error(s)"
        return 1
    fi
}

# Show current configuration
show_configuration() {
    echo -e "\n${CYAN}📋 Current Configuration:${NC}"
    echo -e "\n${YELLOW}🖥️  VPS Settings:${NC}"
    echo -e "   Name: ${VPS_NAME:-Not Set}"
    echo -e "   Version: ${VPS_VERSION:-Not Set}"
    echo -e "   Timeout: ${VPS_TIMEOUT_MINUTES:-Not Set} minutes"
    echo -e "   Auto Restart: ${VPS_AUTO_RESTART:-Not Set}"
    
    echo -e "\n${YELLOW}👤 Windows User:${NC}"
    echo -e "   Username: ${WINDOWS_USERNAME:-Not Set}"
    echo -e "   Auto Generate Password: ${WINDOWS_AUTO_GENERATE_PASSWORD:-Not Set}"
    echo -e "   Password Length: ${WINDOWS_PASSWORD_LENGTH:-Not Set}"
    echo -e "   RDP Enabled: ${WINDOWS_ENABLE_RDP:-Not Set}"
    
    echo -e "\n${YELLOW}🌐 Remote Access:${NC}"
    echo -e "   Tmate Server: ${TMATE_SERVER:-Not Set}"
    echo -e "   Tmate Enabled: ${TMATE_ENABLED:-Not Set}"
    echo -e "   Ngrok Enabled: ${NGROK_ENABLED:-Not Set}"
    echo -e "   Ngrok Region: ${NGROK_REGION:-Not Set}"
    echo -e "   Playit Enabled: ${PLAYIT_ENABLED:-Not Set}"
    
    echo -e "\n${YELLOW}💾 Backup Settings:${NC}"
    echo -e "   Enabled: ${BACKUP_ENABLED:-Not Set}"
    echo -e "   Compression Level: ${BACKUP_COMPRESSION_LEVEL:-Not Set}"
    echo -e "   Retention Days: ${BACKUP_RETENTION_DAYS:-Not Set}"
    echo -e "   Max Local Backups: ${BACKUP_MAX_LOCAL_BACKUPS:-Not Set}"
    
    echo -e "\n${YELLOW}📊 Monitoring:${NC}"
    echo -e "   Enabled: ${MONITORING_ENABLED:-Not Set}"
    echo -e "   Check Interval: ${MONITORING_CHECK_INTERVAL:-Not Set} seconds"
    echo -e "   Memory Warning: ${MONITORING_MEMORY_WARNING_GB:-Not Set} GB"
    echo -e "   Disk Warning: ${MONITORING_DISK_WARNING_GB:-Not Set} GB"
    echo -e "   CPU Warning: ${MONITORING_CPU_WARNING_PERCENT:-Not Set}%"
    
    echo -e "\n${YELLOW}📝 Logging:${NC}"
    echo -e "   Enabled: ${LOGGING_ENABLED:-Not Set}"
    echo -e "   Level: ${LOGGING_LEVEL:-Not Set}"
    echo -e "   Max File Size: ${LOGGING_MAX_FILE_SIZE_MB:-Not Set} MB"
    echo -e "   Max Files: ${LOGGING_MAX_FILES:-Not Set}"
    echo -e "   Directory: ${LOGGING_DIRECTORY:-Not Set}"
    
    echo -e "\n${YELLOW}🛡️  Security:${NC}"
    echo -e "   Input Validation: ${SECURITY_INPUT_VALIDATION:-Not Set}"
    echo -e "   Session Timeout: ${SECURITY_SESSION_TIMEOUT:-Not Set}"
    echo -e "   Auto Cleanup: ${SECURITY_AUTO_CLEANUP:-Not Set}"
    echo -e "   Min Password Length: ${SECURITY_PASSWORD_MIN_LENGTH:-Not Set}"
}

# Export environment variables to GitHub Actions
export_to_github_actions() {
    if [[ -n "${GITHUB_ENV:-}" ]]; then
        info_msg "Exporting configuration to GitHub Actions environment..."
        
        # Export key variables
        {
            echo "VPS_NAME=$VPS_NAME"
            echo "VPS_TIMEOUT_MINUTES=$VPS_TIMEOUT_MINUTES"
            echo "VPS_AUTO_RESTART=$VPS_AUTO_RESTART"
            echo "WINDOWS_USERNAME=$WINDOWS_USERNAME"
            echo "TMATE_SERVER=$TMATE_SERVER"
            echo "BACKUP_ENABLED=$BACKUP_ENABLED"
            echo "MONITORING_ENABLED=$MONITORING_ENABLED"
            echo "LOGGING_LEVEL=$LOGGING_LEVEL"
        } >> "$GITHUB_ENV"
        
        success_msg "Configuration exported to GitHub Actions"
    else
        debug_msg "Not running in GitHub Actions, skipping environment export"
    fi
}

# Create default configuration
create_default_config() {
    local config_file="${1:-$CONFIG_FILE}"
    
    info_msg "Creating default configuration: $(basename "$config_file")"
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$config_file")"
    
    # Create default config.yml
    cat > "$config_file" << 'EOF'
# Default Configuration for Windows VPS
vps:
  name: "StudyVPS"
  description: "Windows VPS for learning and projects"
  version: "2.0.0"
  timeout_minutes: 360
  auto_restart: true

windows_user:
  username: "Administrator"
  auto_generate_password: true
  password_length: 12
  enable_rdp: true

remote_access:
  tmate_server: "nyc1.tmate.io"
  tmate_enabled: true
  ngrok_enabled: true
  ngrok_region: "us"
  playit_enabled: true
  playit_auto_setup: true

backup:
  enabled: true
  compression_level: 6
  retention_days: 30
  max_local_backups: 5

monitoring:
  enabled: true
  check_interval_seconds: 60
  thresholds:
    memory_warning_gb: 1.0
    disk_warning_gb: 2.0
    cpu_warning_percent: 80

logging:
  enabled: true
  level: "INFO"
  max_file_size_mb: 10
  max_files: 5
  log_directory: "logs/"

security:
  input_validation: true
  session_timeout: true
  auto_cleanup: true
  password_policy:
    min_length: 8
EOF
    
    success_msg "Default configuration created"
}

# Update configuration value
update_config_value() {
    local key="$1"
    local value="$2"
    local config_file="${3:-$CONFIG_FILE}"
    
    info_msg "Updating configuration: $key = $value"
    
    if [[ ! -f "$config_file" ]]; then
        warn_msg "Configuration file not found, creating default..."
        create_default_config "$config_file"
    fi
    
    # Update the value using yq
    if yq eval ".$key = \"$value\"" -i "$config_file"; then
        success_msg "Configuration updated successfully"
        validate_yaml_syntax "$config_file"
    else
        error_exit "Failed to update configuration"
    fi
}

# Show help
show_help() {
    cat << EOF
${GREEN}$SCRIPT_NAME v$SCRIPT_VERSION${NC}
YAML Configuration Management Script

${YELLOW}USAGE:${NC}
    $SCRIPT_NAME <command> [options]

${YELLOW}COMMANDS:${NC}
    ${CYAN}load${NC}              Load and export configuration to environment
    ${CYAN}show${NC}              Display current configuration
    ${CYAN}validate${NC}          Validate configuration files
    ${CYAN}create${NC}            Create default configuration file
    ${CYAN}update${NC} <key> <value>  Update a configuration value
    ${CYAN}export${NC}            Export to GitHub Actions environment
    ${CYAN}help${NC}              Show this help message

${YELLOW}OPTIONS:${NC}
    ${CYAN}--config${NC} <file>   Use specific config file (default: config.yml)
    ${CYAN}--backup-config${NC} <file>  Use specific backup config file
    ${CYAN}--debug${NC}           Enable debug output

${YELLOW}EXAMPLES:${NC}
    $SCRIPT_NAME load                           # Load all configurations
    $SCRIPT_NAME show                           # Show current config
    $SCRIPT_NAME validate                       # Validate YAML files
    $SCRIPT_NAME create                         # Create default config
    $SCRIPT_NAME update vps.name "MyVPS"       # Update VPS name
    $SCRIPT_NAME export                         # Export to GitHub Actions

${YELLOW}CONFIGURATION KEYS:${NC}
    ${CYAN}vps.name${NC}                     VPS instance name
    ${CYAN}vps.timeout_minutes${NC}          Session timeout (30-360)
    ${CYAN}windows_user.username${NC}        Windows username
    ${CYAN}windows_user.password_length${NC} Password length (8-128)
    ${CYAN}backup.enabled${NC}               Enable/disable backup
    ${CYAN}backup.compression_level${NC}     Compression level (1-9)
    ${CYAN}monitoring.enabled${NC}           Enable/disable monitoring
    ${CYAN}logging.level${NC}                Log level (DEBUG/INFO/WARNING/ERROR)

${YELLOW}DEPENDENCIES:${NC}
    • yq - YAML processor (auto-installed if missing)
    • bash - Shell interpreter

For more information, visit: https://github.com/your-username/windows-vps
EOF
}

# Main script logic
main() {
    local command="${1:-load}"
    local config_file="$CONFIG_FILE"
    local backup_config_file="$BACKUP_CONFIG"
    local debug=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --config)
                config_file="$2"
                shift 2
                ;;
            --backup-config)
                backup_config_file="$2"
                shift 2
                ;;
            --debug)
                debug=true
                export DEBUG_MODE=true
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
    
    info_msg "Starting configuration management (command: $command)..."
    
    case "$command" in
        "load")
            check_yq_dependency
            load_yaml_config "$config_file"
            load_backup_config "$backup_config_file"
            validate_configuration
            export_to_github_actions
            ;;
        "show")
            check_yq_dependency
            load_yaml_config "$config_file"
            load_backup_config "$backup_config_file"
            show_configuration
            ;;
        "validate")
            check_yq_dependency
            validate_yaml_syntax "$config_file"
            if [[ -f "$backup_config_file" ]]; then
                info_msg "Backup config validation (shell script syntax)"
                bash -n "$backup_config_file" && success_msg "Backup config syntax is valid"
            fi
            ;;
        "create")
            check_yq_dependency
            create_default_config "$config_file"
            ;;
        "update")
            local key="${2:-}"
            local value="${3:-}"
            if [[ -z "$key" || -z "$value" ]]; then
                error_exit "Update command requires key and value: $SCRIPT_NAME update <key> <value>"
            fi
            check_yq_dependency
            update_config_value "$key" "$value" "$config_file"
            ;;
        "export")
            check_yq_dependency
            load_yaml_config "$config_file"
            load_backup_config "$backup_config_file"
            export_to_github_actions
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $command${NC}"
            echo -e "${YELLOW}💡 Use '$SCRIPT_NAME help' for usage information${NC}"
            exit 1
            ;;
    esac
    
    success_msg "Configuration management completed successfully!"
}

# Run main function with all arguments
main "$@"
