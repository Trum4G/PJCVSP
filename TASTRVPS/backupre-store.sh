#!/bin/bash

# Enhanced Backup and Restore Script for Windows VPS
# Supports multiple backup methods with compression and error handling
# Version: 2.0.0

set -euo pipefail

# Script configuration
SCRIPT_VERSION="2.0.0"
SCRIPT_NAME="backupre-store.sh"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/backup.conf"
LOG_FILE="$SCRIPT_DIR/../logs/vps-backup.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default configuration
BACKUP_ENABLED=true
COMPRESSION_LEVEL=6
RETENTION_DAYS=30
MAX_LOCAL_BACKUPS=5
PRIMARY_METHOD="github_releases"
FALLBACK_METHOD="transfer_sh"
LOCAL_METHOD="local_storage"

# Load configuration if exists
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        echo -e "${CYAN}📝 Loading configuration from backup.conf...${NC}"
        source "$CONFIG_FILE" 2>/dev/null || {
            echo -e "${YELLOW}⚠️  Warning: Could not load backup.conf, using defaults${NC}"
        }
    else
        echo -e "${YELLOW}⚠️  backup.conf not found, using default configuration${NC}"
    fi
}

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

# Check dependencies
check_dependencies() {
    local deps=("tar" "gzip" "curl" "jq")
    local missing_deps=()
    
    info_msg "Checking dependencies..."
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error_exit "Missing dependencies: ${missing_deps[*]}. Please install them first."
    fi
    
    success_msg "All dependencies are available"
}

# Get backup timestamp
get_timestamp() {
    date '+%Y%m%d-%H%M%S'
}

# Get backup filename
get_backup_filename() {
    local prefix="${1:-vps-backup}"
    local timestamp="${2:-$(get_timestamp)}"
    echo "${prefix}-${timestamp}.tar.gz"
}

# Create backup directory structure
create_backup_dirs() {
    local backup_dir="$SCRIPT_DIR/../backups"
    mkdir -p "$backup_dir"
    echo "$backup_dir"
}

# Validate backup size
validate_backup_size() {
    local file="$1"
    local max_size_mb="${MAX_BACKUP_SIZE_MB:-100}"
    
    if [[ -f "$file" ]]; then
        local size_mb=$(( $(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo 0) / 1024 / 1024 ))
        
        if [[ $size_mb -gt $max_size_mb ]]; then
            warn_msg "Backup size ($size_mb MB) exceeds maximum ($max_size_mb MB)"
            return 1
        fi
        
        info_msg "Backup size: $size_mb MB (within limits)"
    fi
    
    return 0
}

# Create compressed backup
create_backup_archive() {
    local backup_name="$1"
    local backup_dir="$2"
    local backup_file="$backup_dir/$backup_name"
    
    info_msg "Creating backup archive: $backup_name"
    
    # Prepare include paths
    local include_paths=("TASTRVPS" "logs" "templates" "docs" ".github/workflows" "README.md")
    if [[ -n "${BACKUP_INCLUDE_PATHS:-}" ]]; then
        # Convert bash array string to actual array
        eval "include_paths=(${BACKUP_INCLUDE_PATHS[*]})"
    fi
    
    # Prepare exclude patterns
    local exclude_args=()
    local exclude_patterns=("*.tmp" "*.log" "*.cache" "node_modules" ".git" "backups/*.tar.gz")
    if [[ -n "${BACKUP_EXCLUDE_PATTERNS:-}" ]]; then
        eval "exclude_patterns=(${BACKUP_EXCLUDE_PATTERNS[*]})"
    fi
    
    for pattern in "${exclude_patterns[@]}"; do
        exclude_args+=("--exclude=$pattern")
    done
    
    # Create the archive
    cd "$SCRIPT_DIR/.."
    
    if tar -czf "$backup_file" \
        "${exclude_args[@]}" \
        "${include_paths[@]}" 2>/dev/null; then
        
        success_msg "Backup archive created successfully"
        
        # Validate backup
        if validate_backup_size "$backup_file"; then
            # Generate checksum
            local checksum_file="${backup_file}.sha256"
            if command -v sha256sum >/dev/null 2>&1; then
                sha256sum "$backup_file" > "$checksum_file"
            elif command -v shasum >/dev/null 2>&1; then
                shasum -a 256 "$backup_file" > "$checksum_file"
            fi
            
            success_msg "Backup validation completed"
            echo "$backup_file"
            return 0
        else
            warn_msg "Backup validation failed"
        fi
    else
        error_exit "Failed to create backup archive"
    fi
    
    return 1
}

# Upload to GitHub Releases
upload_to_github() {
    local backup_file="$1"
    local backup_name="$(basename "$backup_file")"
    
    info_msg "Uploading backup to GitHub Releases..."
    
    # Check if GitHub token is available
    if [[ -z "${GITHUB_TOKEN:-}" ]]; then
        warn_msg "GITHUB_TOKEN not available, skipping GitHub upload"
        return 1
    fi
    
    # Get repository information
    local repo_owner="${GITHUB_REPOSITORY_OWNER:-}"
    local repo_name="${GITHUB_REPOSITORY##*/}"
    
    if [[ -z "$repo_owner" || -z "$repo_name" ]]; then
        warn_msg "GitHub repository information not available"
        return 1
    fi
    
    # Create release
    local release_tag="backup-$(get_timestamp)"
    local release_name="VPS Backup $(date '+%Y-%m-%d %H:%M:%S')"
    local release_body="Automated VPS backup created by $SCRIPT_NAME v$SCRIPT_VERSION"
    
    local release_data=$(cat <<EOF
{
    "tag_name": "$release_tag",
    "name": "$release_name",
    "body": "$release_body",
    "draft": false,
    "prerelease": true
}
EOF
    )
    
    # Create the release
    local release_response
    if release_response=$(curl -s -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -d "$release_data" \
        "https://api.github.com/repos/$repo_owner/$repo_name/releases"); then
        
        local release_id
        release_id=$(echo "$release_response" | jq -r '.id')
        
        if [[ "$release_id" != "null" && -n "$release_id" ]]; then
            # Upload the backup file
            if curl -s -X POST \
                -H "Authorization: token $GITHUB_TOKEN" \
                -H "Content-Type: application/octet-stream" \
                --data-binary "@$backup_file" \
                "https://uploads.github.com/repos/$repo_owner/$repo_name/releases/$release_id/assets?name=$backup_name" >/dev/null; then
                
                success_msg "Backup uploaded to GitHub Releases: $release_tag"
                return 0
            else
                warn_msg "Failed to upload backup file to GitHub"
            fi
        else
            warn_msg "Failed to create GitHub release"
        fi
    else
        warn_msg "Failed to create GitHub release"
    fi
    
    return 1
}

# Upload to transfer.sh
upload_to_transfer() {
    local backup_file="$1"
    local backup_name="$(basename "$backup_file")"
    
    info_msg "Uploading backup to transfer.sh..."
    
    local transfer_url="${TRANSFER_URL:-https://transfer.sh}"
    local max_days="${TRANSFER_MAX_DAYS:-14}"
    
    if transfer_result=$(curl -s --upload-file "$backup_file" \
        -H "Max-Days: $max_days" \
        "$transfer_url/$backup_name"); then
        
        if [[ -n "$transfer_result" && "$transfer_result" =~ ^https?:// ]]; then
            success_msg "Backup uploaded to transfer.sh: $transfer_result"
            echo "$transfer_result" > "$backup_file.transfer_url"
            return 0
        fi
    fi
    
    warn_msg "Failed to upload backup to transfer.sh"
    return 1
}

# Local backup storage
store_local_backup() {
    local backup_file="$1"
    local backup_dir="$(dirname "$backup_file")"
    
    info_msg "Managing local backup storage..."
    
    # Count existing backups
    local backup_count
    backup_count=$(find "$backup_dir" -name "vps-backup-*.tar.gz" -type f | wc -l)
    
    # Clean up old backups if needed
    if [[ $backup_count -gt ${MAX_LOCAL_BACKUPS:-5} ]]; then
        info_msg "Cleaning up old local backups (keeping ${MAX_LOCAL_BACKUPS:-5} most recent)"
        
        # Remove oldest backups
        find "$backup_dir" -name "vps-backup-*.tar.gz" -type f -printf '%T@ %p\n' | \
        sort -n | \
        head -n -${MAX_LOCAL_BACKUPS:-5} | \
        cut -d' ' -f2- | \
        while read -r old_backup; do
            rm -f "$old_backup" "$old_backup.sha256" "$old_backup.transfer_url"
            info_msg "Removed old backup: $(basename "$old_backup")"
        done
    fi
    
    success_msg "Local backup storage managed successfully"
    return 0
}

# Main backup function
perform_backup() {
    local backup_type="${1:-regular}"
    
    info_msg "Starting backup process (type: $backup_type)..."
    
    # Check if backup is enabled
    if [[ "${BACKUP_ENABLED:-true}" != "true" ]]; then
        warn_msg "Backup is disabled in configuration"
        return 1
    fi
    
    # Create backup directory
    local backup_dir
    backup_dir=$(create_backup_dirs)
    
    # Generate backup filename
    local backup_name
    backup_name=$(get_backup_filename "vps-backup" "$(get_timestamp)")
    
    # Create backup archive
    local backup_file
    if backup_file=$(create_backup_archive "$backup_name" "$backup_dir"); then
        success_msg "Backup archive created: $backup_name"
        
        # Try upload methods in order
        local upload_success=false
        
        # Primary method: GitHub Releases
        if [[ "${PRIMARY_METHOD:-github_releases}" == "github_releases" ]]; then
            if upload_to_github "$backup_file"; then
                upload_success=true
            fi
        fi
        
        # Fallback method: transfer.sh
        if [[ "$upload_success" != "true" && "${FALLBACK_METHOD:-transfer_sh}" == "transfer_sh" ]]; then
            if upload_to_transfer "$backup_file"; then
                upload_success=true
            fi
        fi
        
        # Local storage (always do this)
        store_local_backup "$backup_file"
        
        if [[ "$upload_success" == "true" ]]; then
            success_msg "Backup completed successfully with remote storage"
        else
            warn_msg "Backup completed but remote upload failed (local backup available)"
        fi
        
        return 0
    else
        error_exit "Failed to create backup archive"
    fi
}

# List available backups
list_backups() {
    info_msg "Listing available backups..."
    
    local backup_dir="$SCRIPT_DIR/../backups"
    
    if [[ -d "$backup_dir" ]]; then
        echo -e "${CYAN}📦 Local Backups:${NC}"
        find "$backup_dir" -name "vps-backup-*.tar.gz" -type f -exec ls -lh {} \; | \
        awk '{print "  📁 " $9 " (" $5 ", " $6 " " $7 " " $8 ")"}'
        
        echo -e "\n${CYAN}🔗 Transfer URLs:${NC}"
        find "$backup_dir" -name "*.transfer_url" -type f | while read -r url_file; do
            if [[ -f "$url_file" ]]; then
                local backup_name=$(basename "$url_file" .transfer_url)
                local url=$(cat "$url_file")
                echo "  🌐 $backup_name: $url"
            fi
        done
    else
        warn_msg "No backup directory found"
    fi
}

# Restore from backup
restore_backup() {
    local backup_source="$1"
    
    info_msg "Starting restore process from: $backup_source"
    
    local backup_file=""
    local temp_download=false
    
    # Determine backup source type
    if [[ "$backup_source" =~ ^https?:// ]]; then
        # Download from URL
        info_msg "Downloading backup from URL..."
        backup_file="/tmp/restore-backup-$(get_timestamp).tar.gz"
        
        if curl -L -o "$backup_file" "$backup_source"; then
            temp_download=true
            success_msg "Backup downloaded successfully"
        else
            error_exit "Failed to download backup from URL"
        fi
    elif [[ -f "$backup_source" ]]; then
        # Local file
        backup_file="$backup_source"
        info_msg "Using local backup file: $backup_file"
    else
        # Try to find in backup directory
        local backup_dir="$SCRIPT_DIR/../backups"
        local found_backup
        
        if found_backup=$(find "$backup_dir" -name "*$backup_source*" -type f -name "*.tar.gz" | head -1); then
            backup_file="$found_backup"
            info_msg "Found matching backup: $backup_file"
        else
            error_exit "Backup source not found: $backup_source"
        fi
    fi
    
    # Verify backup file
    if [[ ! -f "$backup_file" ]]; then
        error_exit "Backup file not found: $backup_file"
    fi
    
    # Verify checksum if available
    local checksum_file="${backup_file}.sha256"
    if [[ -f "$checksum_file" ]]; then
        info_msg "Verifying backup checksum..."
        if command -v sha256sum >/dev/null 2>&1; then
            if sha256sum -c "$checksum_file" >/dev/null 2>&1; then
                success_msg "Backup checksum verified"
            else
                warn_msg "Backup checksum verification failed"
            fi
        fi
    fi
    
    # Create backup of current state before restore
    info_msg "Creating backup of current state before restore..."
    perform_backup "pre-restore" || warn_msg "Failed to create pre-restore backup"
    
    # Perform restore
    info_msg "Extracting backup archive..."
    cd "$SCRIPT_DIR/.."
    
    if tar -xzf "$backup_file"; then
        success_msg "Backup restored successfully"
        
        # Cleanup temporary download
        if [[ "$temp_download" == "true" ]]; then
            rm -f "$backup_file"
        fi
        
        return 0
    else
        error_exit "Failed to extract backup archive"
    fi
}

# Cleanup old backups
cleanup_backups() {
    local retention_days="${RETENTION_DAYS:-30}"
    local backup_dir="$SCRIPT_DIR/../backups"
    
    info_msg "Cleaning up backups older than $retention_days days..."
    
    if [[ -d "$backup_dir" ]]; then
        local cleaned_count=0
        
        # Find and remove old backups
        while IFS= read -r -d '' old_backup; do
            rm -f "$old_backup" "${old_backup}.sha256" "${old_backup}.transfer_url"
            info_msg "Removed old backup: $(basename "$old_backup")"
            ((cleaned_count++))
        done < <(find "$backup_dir" -name "vps-backup-*.tar.gz" -type f -mtime +${retention_days} -print0)
        
        if [[ $cleaned_count -gt 0 ]]; then
            success_msg "Cleaned up $cleaned_count old backup(s)"
        else
            info_msg "No old backups to clean up"
        fi
    fi
}

# Health check
health_check() {
    info_msg "Performing health check..."
    
    local issues=0
    
    # Check disk space
    local free_space_mb
    free_space_mb=$(df "$SCRIPT_DIR" | awk 'NR==2 {print int($4/1024)}')
    local min_space="${MIN_FREE_DISK_SPACE_MB:-1000}"
    
    if [[ $free_space_mb -lt $min_space ]]; then
        warn_msg "Low disk space: ${free_space_mb}MB free (minimum: ${min_space}MB)"
        ((issues++))
    else
        success_msg "Disk space OK: ${free_space_mb}MB free"
    fi
    
    # Check dependencies
    check_dependencies || ((issues++))
    
    # Check configuration
    if [[ -f "$CONFIG_FILE" ]]; then
        success_msg "Configuration file found: $CONFIG_FILE"
    else
        warn_msg "Configuration file not found: $CONFIG_FILE"
        ((issues++))
    fi
    
    if [[ $issues -eq 0 ]]; then
        success_msg "Health check passed"
        return 0
    else
        warn_msg "Health check found $issues issue(s)"
        return 1
    fi
}

# Show help
show_help() {
    cat << EOF
${GREEN}$SCRIPT_NAME v$SCRIPT_VERSION${NC}
Enhanced Backup and Restore Script for Windows VPS

${YELLOW}USAGE:${NC}
    $SCRIPT_NAME <command> [options]

${YELLOW}COMMANDS:${NC}
    ${CYAN}backup${NC} [type]           Create a new backup
                             Types: regular (default), final, emergency
    
    ${CYAN}restore${NC} <source>        Restore from backup
                             Source: file path, URL, or backup name pattern
    
    ${CYAN}list${NC}                   List available backups
    
    ${CYAN}cleanup${NC}                Clean up old backups based on retention policy
    
    ${CYAN}health${NC}                 Perform system health check
    
    ${CYAN}help${NC}                   Show this help message

${YELLOW}EXAMPLES:${NC}
    $SCRIPT_NAME backup
    $SCRIPT_NAME backup final
    $SCRIPT_NAME restore vps-backup-20250114-143022.tar.gz
    $SCRIPT_NAME restore https://transfer.sh/abc123/backup.tar.gz
    $SCRIPT_NAME list
    $SCRIPT_NAME cleanup
    $SCRIPT_NAME health

${YELLOW}CONFIGURATION:${NC}
    Configuration is loaded from: $CONFIG_FILE
    Logs are written to: $LOG_FILE

${YELLOW}BACKUP METHODS:${NC}
    1. GitHub Releases (primary) - Requires GITHUB_TOKEN
    2. Transfer.sh (fallback) - Public temporary storage
    3. Local storage (always) - Stored in backups/ directory

${YELLOW}FEATURES:${NC}
    ✅ Multiple backup methods with fallback
    ✅ Compression with configurable levels
    ✅ Automatic cleanup based on retention policy
    ✅ Checksum verification for integrity
    ✅ Health checks and monitoring
    ✅ Comprehensive logging
    ✅ Error handling and recovery

For more information, visit: https://github.com/your-username/windows-vps
EOF
}

# Main script logic
main() {
    local command="${1:-help}"
    
    # Load configuration
    load_config
    
    # Create log directory
    mkdir -p "$(dirname "$LOG_FILE")"
    
    case "$command" in
        "backup")
            local backup_type="${2:-regular}"
            check_dependencies
            perform_backup "$backup_type"
            ;;
        "restore")
            local backup_source="${2:-}"
            if [[ -z "$backup_source" ]]; then
                error_exit "Backup source is required for restore command"
            fi
            check_dependencies
            restore_backup "$backup_source"
            ;;
        "list")
            list_backups
            ;;
        "cleanup")
            cleanup_backups
            ;;
        "health")
            health_check
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $command${NC}"
            echo -e "${YELLOW}💡 Use '$SCRIPT_NAME help' for usage information${NC}"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
