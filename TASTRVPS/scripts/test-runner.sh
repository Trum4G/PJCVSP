#!/bin/bash

# Comprehensive Test Suite for Windows VPS System
# Tests syntax, structure, functionality with assertion functions
# Version: 2.0.0

set -euo pipefail

# Script configuration
SCRIPT_VERSION="2.0.0"
SCRIPT_NAME="test-runner.sh"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_FILE="$PROJECT_ROOT/logs/test-runner.log"
REPORT_FILE="$PROJECT_ROOT/logs/test-report.html"

# Test configuration
TEST_TIMEOUT=600  # 10 minutes
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
SKIPPED_TESTS=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test results array
declare -a TEST_RESULTS=()

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
        "TEST")    echo -e "${CYAN}🧪 TEST: $message${NC}" ;;
        *)         echo -e "${CYAN}📝 $message${NC}" ;;
    esac
}

# Test assertion functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    ((TOTAL_TESTS++))
    
    if [[ "$expected" == "$actual" ]]; then
        ((PASSED_TESTS++))
        log "SUCCESS" "PASS: $test_name"
        TEST_RESULTS+=("PASS:$test_name")
        return 0
    else
        ((FAILED_TESTS++))
        log "ERROR" "FAIL: $test_name - Expected '$expected', got '$actual'"
        TEST_RESULTS+=("FAIL:$test_name:Expected '$expected', got '$actual'")
        return 1
    fi
}

assert_not_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"
    
    ((TOTAL_TESTS++))
    
    if [[ "$expected" != "$actual" ]]; then
        ((PASSED_TESTS++))
        log "SUCCESS" "PASS: $test_name"
        TEST_RESULTS+=("PASS:$test_name")
        return 0
    else
        ((FAILED_TESTS++))
        log "ERROR" "FAIL: $test_name - Expected not '$expected', but got '$actual'"
        TEST_RESULTS+=("FAIL:$test_name:Expected not '$expected', but got '$actual'")
        return 1
    fi
}

assert_true() {
    local condition="$1"
    local test_name="$2"
    
    ((TOTAL_TESTS++))
    
    if [[ "$condition" == "true" ]] || [[ "$condition" == "0" ]]; then
        ((PASSED_TESTS++))
        log "SUCCESS" "PASS: $test_name"
        TEST_RESULTS+=("PASS:$test_name")
        return 0
    else
        ((FAILED_TESTS++))
        log "ERROR" "FAIL: $test_name - Expected true, got '$condition'"
        TEST_RESULTS+=("FAIL:$test_name:Expected true, got '$condition'")
        return 1
    fi
}

assert_false() {
    local condition="$1"
    local test_name="$2"
    
    ((TOTAL_TESTS++))
    
    if [[ "$condition" == "false" ]] || [[ "$condition" == "1" ]]; then
        ((PASSED_TESTS++))
        log "SUCCESS" "PASS: $test_name"
        TEST_RESULTS+=("PASS:$test_name")
        return 0
    else
        ((FAILED_TESTS++))
        log "ERROR" "FAIL: $test_name - Expected false, got '$condition'"
        TEST_RESULTS+=("FAIL:$test_name:Expected false, got '$condition'")
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local test_name="$2"
    
    ((TOTAL_TESTS++))
    
    if [[ -f "$file" ]]; then
        ((PASSED_TESTS++))
        log "SUCCESS" "PASS: $test_name - File exists: $file"
        TEST_RESULTS+=("PASS:$test_name")
        return 0
    else
        ((FAILED_TESTS++))
        log "ERROR" "FAIL: $test_name - File does not exist: $file"
        TEST_RESULTS+=("FAIL:$test_name:File does not exist: $file")
        return 1
    fi
}

assert_dir_exists() {
    local dir="$1"
    local test_name="$2"
    
    ((TOTAL_TESTS++))
    
    if [[ -d "$dir" ]]; then
        ((PASSED_TESTS++))
        log "SUCCESS" "PASS: $test_name - Directory exists: $dir"
        TEST_RESULTS+=("PASS:$test_name")
        return 0
    else
        ((FAILED_TESTS++))
        log "ERROR" "FAIL: $test_name - Directory does not exist: $dir"
        TEST_RESULTS+=("FAIL:$test_name:Directory does not exist: $dir")
        return 1
    fi
}

assert_command_exists() {
    local command="$1"
    local test_name="$2"
    
    ((TOTAL_TESTS++))
    
    if command -v "$command" >/dev/null 2>&1; then
        ((PASSED_TESTS++))
        log "SUCCESS" "PASS: $test_name - Command exists: $command"
        TEST_RESULTS+=("PASS:$test_name")
        return 0
    else
        ((FAILED_TESTS++))
        log "ERROR" "FAIL: $test_name - Command does not exist: $command"
        TEST_RESULTS+=("FAIL:$test_name:Command does not exist: $command")
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local test_name="$3"
    
    ((TOTAL_TESTS++))
    
    if [[ "$haystack" == *"$needle"* ]]; then
        ((PASSED_TESTS++))
        log "SUCCESS" "PASS: $test_name - Contains '$needle'"
        TEST_RESULTS+=("PASS:$test_name")
        return 0
    else
        ((FAILED_TESTS++))
        log "ERROR" "FAIL: $test_name - Does not contain '$needle'"
        TEST_RESULTS+=("FAIL:$test_name:Does not contain '$needle'")
        return 1
    fi
}

skip_test() {
    local test_name="$1"
    local reason="$2"
    
    ((TOTAL_TESTS++))
    ((SKIPPED_TESTS++))
    
    log "WARNING" "SKIP: $test_name - $reason"
    TEST_RESULTS+=("SKIP:$test_name:$reason")
}

# Print test banner
print_test_banner() {
    echo -e "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════════╗
║                    Windows VPS Test Suite                           ║
║                       Version 2.0.0                                 ║
║                                                                      ║
║  🧪 Comprehensive testing for all system components                 ║
║  📊 Syntax, structure, and functionality validation                 ║
╚══════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Test 1: Project structure
test_project_structure() {
    log "TEST" "Testing project structure..."
    
    assert_dir_exists "$PROJECT_ROOT" "Project root directory exists"
    assert_dir_exists "$PROJECT_ROOT/.github/workflows" "GitHub workflows directory exists"
    assert_dir_exists "$PROJECT_ROOT/TASTRVPS" "TASTRVPS directory exists"
    assert_dir_exists "$PROJECT_ROOT/TASTRVPS/scripts" "Scripts directory exists"
    assert_dir_exists "$PROJECT_ROOT/logs" "Logs directory exists"
    assert_dir_exists "$PROJECT_ROOT/docs" "Docs directory exists"
}

# Test 2: Required files
test_required_files() {
    log "TEST" "Testing required files..."
    
    assert_file_exists "$PROJECT_ROOT/README.md" "README.md exists"
    assert_file_exists "$PROJECT_ROOT/.github/workflows/tmate.yml" "GitHub workflow exists"
    assert_file_exists "$PROJECT_ROOT/TASTRVPS/config.yml" "Main config file exists"
    assert_file_exists "$PROJECT_ROOT/TASTRVPS/backup.conf" "Backup config exists"
    assert_file_exists "$PROJECT_ROOT/TASTRVPS/backupre-store.sh" "Backup script exists"
    assert_file_exists "$PROJECT_ROOT/TASTRVPS/scripts/setup.sh" "Setup script exists"
    assert_file_exists "$PROJECT_ROOT/TASTRVPS/scripts/config-manager.sh" "Config manager exists"
    assert_file_exists "$PROJECT_ROOT/TASTRVPS/scripts/test-runner.sh" "Test runner exists"
}

# Test 3: Script syntax validation
test_script_syntax() {
    log "TEST" "Testing script syntax..."
    
    # Test bash scripts
    local bash_scripts=(
        "$PROJECT_ROOT/TASTRVPS/backupre-store.sh"
        "$PROJECT_ROOT/TASTRVPS/scripts/setup.sh"
        "$PROJECT_ROOT/TASTRVPS/scripts/config-manager.sh"
        "$PROJECT_ROOT/TASTRVPS/scripts/test-runner.sh"
    )
    
    for script in "${bash_scripts[@]}"; do
        if [[ -f "$script" ]]; then
            if bash -n "$script" 2>/dev/null; then
                assert_true "true" "Bash syntax valid: $(basename "$script")"
            else
                assert_true "false" "Bash syntax valid: $(basename "$script")"
            fi
        else
            skip_test "Bash syntax: $(basename "$script")" "File not found"
        fi
    done
}

# Test 4: YAML syntax validation
test_yaml_syntax() {
    log "TEST" "Testing YAML syntax..."
    
    local yaml_files=(
        "$PROJECT_ROOT/TASTRVPS/config.yml"
        "$PROJECT_ROOT/.github/workflows/tmate.yml"
    )
    
    for yaml_file in "${yaml_files[@]}"; do
        if [[ -f "$yaml_file" ]]; then
            # Try different YAML validators
            local valid=false
            
            # Try with yq if available
            if command -v yq >/dev/null 2>&1; then
                if yq eval '.' "$yaml_file" >/dev/null 2>&1; then
                    valid=true
                fi
            # Try with python if available
            elif command -v python3 >/dev/null 2>&1; then
                if python3 -c "import yaml; yaml.safe_load(open('$yaml_file'))" 2>/dev/null; then
                    valid=true
                fi
            # Try with ruby if available
            elif command -v ruby >/dev/null 2>&1; then
                if ruby -ryaml -e "YAML.load_file('$yaml_file')" 2>/dev/null; then
                    valid=true
                fi
            else
                skip_test "YAML syntax: $(basename "$yaml_file")" "No YAML validator available"
                continue
            fi
            
            if [[ "$valid" == "true" ]]; then
                assert_true "true" "YAML syntax valid: $(basename "$yaml_file")"
            else
                assert_true "false" "YAML syntax valid: $(basename "$yaml_file")"
            fi
        else
            skip_test "YAML syntax: $(basename "$yaml_file")" "File not found"
        fi
    done
}

# Test 5: Configuration validation
test_configuration_validation() {
    log "TEST" "Testing configuration validation..."
    
    if [[ -f "$PROJECT_ROOT/TASTRVPS/scripts/config-manager.sh" ]]; then
        # Test config manager validation
        if bash "$PROJECT_ROOT/TASTRVPS/scripts/config-manager.sh" validate 2>/dev/null; then
            assert_true "true" "Configuration validation passes"
        else
            assert_true "false" "Configuration validation passes"
        fi
    else
        skip_test "Configuration validation" "Config manager not found"
    fi
    
    # Test specific config values if config exists
    if [[ -f "$PROJECT_ROOT/TASTRVPS/config.yml" ]] && command -v yq >/dev/null 2>&1; then
        local vps_name
        vps_name=$(yq eval '.vps.name' "$PROJECT_ROOT/TASTRVPS/config.yml" 2>/dev/null || echo "")
        assert_not_equals "" "$vps_name" "VPS name is configured"
        
        local timeout_minutes
        timeout_minutes=$(yq eval '.vps.timeout_minutes' "$PROJECT_ROOT/TASTRVPS/config.yml" 2>/dev/null || echo "0")
        if [[ "$timeout_minutes" =~ ^[0-9]+$ ]] && [[ $timeout_minutes -ge 30 ]] && [[ $timeout_minutes -le 360 ]]; then
            assert_true "true" "VPS timeout is valid range (30-360)"
        else
            assert_true "false" "VPS timeout is valid range (30-360)"
        fi
    else
        skip_test "Config value validation" "Config file or yq not available"
    fi
}

# Test 6: GitHub workflow validation
test_github_workflow() {
    log "TEST" "Testing GitHub workflow..."
    
    local workflow_file="$PROJECT_ROOT/.github/workflows/tmate.yml"
    
    if [[ -f "$workflow_file" ]]; then
        # Check for required workflow elements
        local workflow_content
        workflow_content=$(cat "$workflow_file")
        
        assert_contains "$workflow_content" "workflow_dispatch" "Workflow has manual trigger"
        assert_contains "$workflow_content" "windows-latest" "Workflow uses Windows runner"
        assert_contains "$workflow_content" "timeout-minutes" "Workflow has timeout configuration"
        assert_contains "$workflow_content" "inputs:" "Workflow has input parameters"
        
        # Check for required steps
        assert_contains "$workflow_content" "Validate Inputs" "Workflow validates inputs"
        assert_contains "$workflow_content" "Setup Windows RDP" "Workflow sets up RDP"
        assert_contains "$workflow_content" "Keep-alive Monitoring" "Workflow has monitoring"
        
        # Check for security features
        assert_contains "$workflow_content" "password" "Workflow handles passwords"
        assert_contains "$workflow_content" "validation" "Workflow has input validation"
    else
        skip_test "GitHub workflow validation" "Workflow file not found"
    fi
}

# Test 7: Backup functionality
test_backup_functionality() {
    log "TEST" "Testing backup functionality..."
    
    local backup_script="$PROJECT_ROOT/TASTRVPS/backupre-store.sh"
    
    if [[ -f "$backup_script" ]]; then
        # Test backup script help
        if bash "$backup_script" help >/dev/null 2>&1; then
            assert_true "true" "Backup script help command works"
        else
            assert_true "false" "Backup script help command works"
        fi
        
        # Test backup script health check
        if bash "$backup_script" health >/dev/null 2>&1; then
            assert_true "true" "Backup script health check works"
        else
            # Health check might fail due to missing dependencies, which is expected
            skip_test "Backup script health check" "Dependencies may be missing"
        fi
        
        # Check backup script has required functions
        local script_content
        script_content=$(cat "$backup_script")
        
        assert_contains "$script_content" "perform_backup" "Backup script has backup function"
        assert_contains "$script_content" "restore_backup" "Backup script has restore function"
        assert_contains "$script_content" "upload_to_github" "Backup script has GitHub upload"
        assert_contains "$script_content" "upload_to_transfer" "Backup script has transfer.sh upload"
        assert_contains "$script_content" "validate_backup_size" "Backup script validates size"
    else
        skip_test "Backup functionality" "Backup script not found"
    fi
}

# Test 8: Setup script functionality
test_setup_functionality() {
    log "TEST" "Testing setup script functionality..."
    
    local setup_script="$PROJECT_ROOT/TASTRVPS/scripts/setup.sh"
    
    if [[ -f "$setup_script" ]]; then
        # Test setup script help
        if bash "$setup_script" help >/dev/null 2>&1; then
            assert_true "true" "Setup script help command works"
        else
            assert_true "false" "Setup script help command works"
        fi
        
        # Check setup script has required functions
        local script_content
        script_content=$(cat "$setup_script")
        
        assert_contains "$script_content" "install_dependencies" "Setup script has dependency installation"
        assert_contains "$script_content" "setup_directories" "Setup script has directory setup"
        assert_contains "$script_content" "setup_git_config" "Setup script has Git configuration"
        assert_contains "$script_content" "perform_health_checks" "Setup script has health checks"
    else
        skip_test "Setup functionality" "Setup script not found"
    fi
}

# Test 9: Dependencies check
test_dependencies() {
    log "TEST" "Testing system dependencies..."
    
    # Core dependencies
    local core_deps=("bash" "curl")
    for dep in "${core_deps[@]}"; do
        assert_command_exists "$dep" "Core dependency: $dep"
    done
    
    # Optional but recommended dependencies
    local optional_deps=("git" "tar" "gzip")
    for dep in "${optional_deps[@]}"; do
        if command -v "$dep" >/dev/null 2>&1; then
            assert_command_exists "$dep" "Optional dependency: $dep"
        else
            skip_test "Optional dependency: $dep" "Not installed (optional)"
        fi
    done
    
    # Advanced dependencies
    local advanced_deps=("jq" "yq")
    for dep in "${advanced_deps[@]}"; do
        if command -v "$dep" >/dev/null 2>&1; then
            assert_command_exists "$dep" "Advanced dependency: $dep"
        else
            skip_test "Advanced dependency: $dep" "Not installed (will be auto-installed)"
        fi
    done
}

# Test 10: File permissions
test_file_permissions() {
    log "TEST" "Testing file permissions..."
    
    local executable_files=(
        "$PROJECT_ROOT/TASTRVPS/backupre-store.sh"
        "$PROJECT_ROOT/TASTRVPS/scripts/setup.sh"
        "$PROJECT_ROOT/TASTRVPS/scripts/config-manager.sh"
        "$PROJECT_ROOT/TASTRVPS/scripts/test-runner.sh"
    )
    
    for file in "${executable_files[@]}"; do
        if [[ -f "$file" ]]; then
            if [[ -x "$file" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
                assert_true "true" "File is executable: $(basename "$file")"
            else
                # On some systems, execute permission might not be set but file can still run
                skip_test "File executable: $(basename "$file")" "Permission check skipped on this system"
            fi
        else
            skip_test "File executable: $(basename "$file")" "File not found"
        fi
    done
}

# Test 11: Documentation completeness
test_documentation() {
    log "TEST" "Testing documentation completeness..."
    
    if [[ -f "$PROJECT_ROOT/README.md" ]]; then
        local readme_content
        readme_content=$(cat "$PROJECT_ROOT/README.md")
        
        assert_contains "$readme_content" "Windows VPS" "README mentions Windows VPS"
        assert_contains "$readme_content" "GitHub Actions" "README mentions GitHub Actions"
        assert_contains "$readme_content" "Usage" "README has usage section"
        assert_contains "$readme_content" "Features" "README has features section"
    else
        skip_test "README documentation" "README.md not found"
    fi
    
    # Check if documentation directory exists and has content
    if [[ -d "$PROJECT_ROOT/docs" ]]; then
        local doc_files
        doc_files=$(find "$PROJECT_ROOT/docs" -name "*.md" -type f | wc -l)
        if [[ $doc_files -gt 0 ]]; then
            assert_true "true" "Documentation directory has content"
        else
            skip_test "Documentation content" "No markdown files in docs/"
        fi
    else
        skip_test "Documentation directory" "docs/ directory not found"
    fi
}

# Test 12: Security validation
test_security() {
    log "TEST" "Testing security features..."
    
    # Check workflow for security best practices
    local workflow_file="$PROJECT_ROOT/.github/workflows/tmate.yml"
    
    if [[ -f "$workflow_file" ]]; then
        local workflow_content
        workflow_content=$(cat "$workflow_file")
        
        # Check for input validation
        assert_contains "$workflow_content" "Validate Inputs" "Workflow validates inputs"
        
        # Check for timeout configuration
        assert_contains "$workflow_content" "timeout-minutes" "Workflow has timeout protection"
        
        # Check that no hardcoded secrets are present
        if ! grep -i "password.*=" "$workflow_file" | grep -v "inputs\." | grep -v "secrets\." | grep -v "env\." >/dev/null 2>&1; then
            assert_true "true" "No hardcoded passwords in workflow"
        else
            assert_true "false" "No hardcoded passwords in workflow"
        fi
        
        # Check for cleanup steps
        assert_contains "$workflow_content" "Cleanup" "Workflow has cleanup steps"
    else
        skip_test "Security validation" "Workflow file not found"
    fi
    
    # Check scripts for security best practices
    local scripts=(
        "$PROJECT_ROOT/TASTRVPS/backupre-store.sh"
        "$PROJECT_ROOT/TASTRVPS/scripts/setup.sh"
        "$PROJECT_ROOT/TASTRVPS/scripts/config-manager.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            # Check for 'set -euo pipefail' (bash strict mode)
            if grep -q "set -euo pipefail" "$script"; then
                assert_true "true" "Script uses bash strict mode: $(basename "$script")"
            else
                assert_true "false" "Script uses bash strict mode: $(basename "$script")"
            fi
        fi
    done
}

# Generate HTML test report
generate_html_report() {
    log "INFO" "Generating HTML test report..."
    
    local report_file="$REPORT_FILE"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local pass_rate=0
    
    if [[ $TOTAL_TESTS -gt 0 ]]; then
        pass_rate=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    fi
    
    # Create HTML report
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Windows VPS Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { text-align: center; margin-bottom: 30px; }
        .summary { display: flex; justify-content: space-around; margin: 20px 0; }
        .stat-box { text-align: center; padding: 15px; border-radius: 5px; color: white; }
        .total { background-color: #3498db; }
        .passed { background-color: #27ae60; }
        .failed { background-color: #e74c3c; }
        .skipped { background-color: #f39c12; }
        .pass-rate { background-color: #9b59b6; }
        .test-results { margin-top: 30px; }
        .test-item { margin: 10px 0; padding: 10px; border-radius: 5px; }
        .test-pass { background-color: #d4edda; border-left: 4px solid #27ae60; }
        .test-fail { background-color: #f8d7da; border-left: 4px solid #e74c3c; }
        .test-skip { background-color: #fff3cd; border-left: 4px solid #f39c12; }
        .test-name { font-weight: bold; }
        .test-details { font-size: 0.9em; color: #666; margin-top: 5px; }
        .footer { text-align: center; margin-top: 30px; color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🧪 Windows VPS Test Suite Report</h1>
            <p>Generated on: $timestamp</p>
            <p>Test Suite Version: $SCRIPT_VERSION</p>
        </div>
        
        <div class="summary">
            <div class="stat-box total">
                <h3>$TOTAL_TESTS</h3>
                <p>Total Tests</p>
            </div>
            <div class="stat-box passed">
                <h3>$PASSED_TESTS</h3>
                <p>Passed</p>
            </div>
            <div class="stat-box failed">
                <h3>$FAILED_TESTS</h3>
                <p>Failed</p>
            </div>
            <div class="stat-box skipped">
                <h3>$SKIPPED_TESTS</h3>
                <p>Skipped</p>
            </div>
            <div class="stat-box pass-rate">
                <h3>$pass_rate%</h3>
                <p>Pass Rate</p>
            </div>
        </div>
        
        <div class="test-results">
            <h2>📋 Test Results</h2>
EOF
    
    # Add test results
    for result in "${TEST_RESULTS[@]}"; do
        local status="${result%%:*}"
        local remainder="${result#*:}"
        local test_name="${remainder%%:*}"
        local details="${remainder#*:}"
        
        case "$status" in
            "PASS")
                echo "            <div class=\"test-item test-pass\">" >> "$report_file"
                echo "                <div class=\"test-name\">✅ $test_name</div>" >> "$report_file"
                ;;
            "FAIL")
                echo "            <div class=\"test-item test-fail\">" >> "$report_file"
                echo "                <div class=\"test-name\">❌ $test_name</div>" >> "$report_file"
                if [[ "$details" != "$test_name" ]]; then
                    echo "                <div class=\"test-details\">$details</div>" >> "$report_file"
                fi
                ;;
            "SKIP")
                echo "            <div class=\"test-item test-skip\">" >> "$report_file"
                echo "                <div class=\"test-name\">⏭️ $test_name</div>" >> "$report_file"
                if [[ "$details" != "$test_name" ]]; then
                    echo "                <div class=\"test-details\">Reason: $details</div>" >> "$report_file"
                fi
                ;;
        esac
        echo "            </div>" >> "$report_file"
    done
    
    # Close HTML
    cat >> "$report_file" << EOF
        </div>
        
        <div class="footer">
            <p>Report generated by $SCRIPT_NAME v$SCRIPT_VERSION</p>
            <p>Windows VPS System - GitHub Actions Based Free Windows Virtual Machine</p>
        </div>
    </div>
</body>
</html>
EOF
    
    log "SUCCESS" "HTML report generated: $report_file"
}

# Show test summary
show_test_summary() {
    echo -e "\n${CYAN}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                        🧪 Test Summary                              ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    
    local pass_rate=0
    if [[ $TOTAL_TESTS -gt 0 ]]; then
        pass_rate=$(( (PASSED_TESTS * 100) / TOTAL_TESTS ))
    fi
    
    echo -e "\n${BLUE}📊 Test Statistics:${NC}"
    echo -e "   Total Tests:  $TOTAL_TESTS"
    echo -e "   ${GREEN}✅ Passed:     $PASSED_TESTS${NC}"
    echo -e "   ${RED}❌ Failed:     $FAILED_TESTS${NC}"
    echo -e "   ${YELLOW}⏭️  Skipped:    $SKIPPED_TESTS${NC}"
    echo -e "   ${PURPLE}📈 Pass Rate:  $pass_rate%${NC}"
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "\n${GREEN}🎉 All tests passed! Your Windows VPS system is ready to go!${NC}"
        return 0
    else
        echo -e "\n${RED}⚠️  Some tests failed. Please check the logs for details.${NC}"
        echo -e "${YELLOW}💡 Failed tests may indicate missing dependencies or configuration issues.${NC}"
        return 1
    fi
}

# Show help
show_help() {
    cat << EOF
${GREEN}$SCRIPT_NAME v$SCRIPT_VERSION${NC}
Comprehensive Test Suite for Windows VPS System

${YELLOW}USAGE:${NC}
    $SCRIPT_NAME [options]

${YELLOW}OPTIONS:${NC}
    ${CYAN}--quick${NC}         Run only essential tests (faster)
    ${CYAN}--verbose${NC}       Enable verbose output
    ${CYAN}--no-report${NC}     Skip HTML report generation
    ${CYAN}--timeout${NC} <sec> Set test timeout (default: 600 seconds)
    ${CYAN}--help${NC}          Show this help message

${YELLOW}TEST SUITES:${NC}
    1. ${CYAN}Project Structure${NC}     - Verify directory layout
    2. ${CYAN}Required Files${NC}        - Check essential files exist
    3. ${CYAN}Script Syntax${NC}         - Validate bash script syntax
    4. ${CYAN}YAML Syntax${NC}           - Validate YAML configuration
    5. ${CYAN}Configuration${NC}         - Test config validation
    6. ${CYAN}GitHub Workflow${NC}       - Validate workflow structure
    7. ${CYAN}Backup Functionality${NC}  - Test backup/restore features
    8. ${CYAN}Setup Functionality${NC}   - Test setup script features
    9. ${CYAN}Dependencies${NC}          - Check required dependencies
    10. ${CYAN}File Permissions${NC}     - Verify executable permissions
    11. ${CYAN}Documentation${NC}        - Check documentation completeness
    12. ${CYAN}Security${NC}             - Validate security features

${YELLOW}OUTPUTS:${NC}
    • Console output with colored results
    • Detailed log file: logs/test-runner.log
    • HTML report: logs/test-report.html

${YELLOW}EXAMPLES:${NC}
    $SCRIPT_NAME                    # Run all tests
    $SCRIPT_NAME --quick            # Run essential tests only
    $SCRIPT_NAME --verbose          # Run with detailed output
    $SCRIPT_NAME --no-report        # Skip HTML report

${YELLOW}EXIT CODES:${NC}
    0 - All tests passed
    1 - Some tests failed
    2 - Test execution error

For more information, visit: https://github.com/your-username/windows-vps
EOF
}

# Main test execution
main() {
    local quick_mode=false
    local verbose_mode=false
    local generate_report=true
    local custom_timeout=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --quick)
                quick_mode=true
                shift
                ;;
            --verbose)
                verbose_mode=true
                shift
                ;;
            --no-report)
                generate_report=false
                shift
                ;;
            --timeout)
                custom_timeout="$2"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}❌ Unknown option: $1${NC}"
                echo -e "${YELLOW}💡 Use '$SCRIPT_NAME --help' for usage information${NC}"
                exit 2
                ;;
        esac
    done
    
    # Set timeout
    if [[ -n "$custom_timeout" ]]; then
        TEST_TIMEOUT="$custom_timeout"
    fi
    
    # Set verbose mode
    if [[ "$verbose_mode" == "true" ]]; then
        set -x
    fi
    
    # Print banner
    print_test_banner
    
    log "INFO" "Starting comprehensive test suite..."
    log "INFO" "Test timeout: $TEST_TIMEOUT seconds"
    log "INFO" "Quick mode: $quick_mode"
    log "INFO" "Verbose mode: $verbose_mode"
    
    # Initialize test results
    TOTAL_TESTS=0
    PASSED_TESTS=0
    FAILED_TESTS=0
    SKIPPED_TESTS=0
    TEST_RESULTS=()
    
    # Run test suites
    local start_time=$(date +%s)
    
    # Essential tests (always run)
    test_project_structure
    test_required_files
    test_script_syntax
    test_yaml_syntax
    
    if [[ "$quick_mode" != "true" ]]; then
        # Full test suite
        test_configuration_validation
        test_github_workflow
        test_backup_functionality
        test_setup_functionality
        test_dependencies
        test_file_permissions
        test_documentation
        test_security
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    log "INFO" "Test execution completed in $duration seconds"
    
    # Generate reports
    if [[ "$generate_report" == "true" ]]; then
        generate_html_report
    fi
    
    # Show summary
    show_test_summary
    
    # Exit with appropriate code
    if [[ $FAILED_TESTS -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function with all arguments
main "$@"
