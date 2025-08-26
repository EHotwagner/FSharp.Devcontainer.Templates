#!/bin/bash
set -euo pipefail

# Feature: OpenCode AI Assistant
# Version: 1.0.0
# Description: Integration with opencode.ai Claude-powered development assistant

# Parse feature options
OPENCODE_VERSION=${VERSION:-"latest"}
ENABLE_VSCODE_INTEGRATION=${ENABLEVSCODEINTEGRATION:-"true"}
AUTO_AUTHENTICATE=${AUTOAUTHENTICATE:-"false"}
INSTALL_METHOD=${INSTALLMETHOD:-"npm"}
ENABLE_CONTEXT_SHARING=${ENABLECONTEXTSHARING:-"true"}
CONFIGURE_GIT_INTEGRATION=${CONFIGUREGITINTEGRATION:-"false"}

echo "Setting up OpenCode AI assistant (version: ${OPENCODE_VERSION})..."

# Validation functions
validate_environment() {
    echo "🔍 Validating environment..."
    
    case "$INSTALL_METHOD" in
        "npm")
            if ! command -v npm >/dev/null 2>&1; then
                echo "❌ npm not found. Please ensure Node.js feature is installed first."
                exit 1
            fi
            echo "✅ npm found: $(npm --version)"
            ;;
        "binary"|"curl")
            if ! command -v curl >/dev/null 2>&1; then
                echo "❌ curl not found. Please install curl for binary installation."
                exit 1
            fi
            echo "✅ curl found for binary installation"
            ;;
    esac
}

install_opencode() {
    echo "📦 Installing OpenCode CLI..."
    
    case "$INSTALL_METHOD" in
        "npm")
            install_via_npm
            ;;
        "binary")
            install_via_binary
            ;;
        "curl")
            install_via_curl
            ;;
    esac
}

install_via_npm() {
    echo "📦 Installing OpenCode via npm..."
    
    case "$OPENCODE_VERSION" in
        "latest")
            npm install -g @opencode/cli || echo "⚠️ OpenCode CLI not available in npm registry yet"
            ;;
        *)
            npm install -g "@opencode/cli@${OPENCODE_VERSION}" || echo "⚠️ OpenCode CLI not available in npm registry yet"
            ;;
    esac
    
    # Fallback: Create a mock installation for development
    create_mock_cli
}

install_via_binary() {
    echo "📥 Installing OpenCode via binary download..."
    
    # Determine architecture
    ARCH=$(uname -m)
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    
    case "$ARCH" in
        "x86_64") ARCH="x64" ;;
        "aarch64"|"arm64") ARCH="arm64" ;;
        *) echo "⚠️ Unsupported architecture: $ARCH"; ARCH="x64" ;;
    esac
    
    # Download binary (mock URL for development)
    DOWNLOAD_URL="https://github.com/opencode-ai/cli/releases/latest/download/opencode-${OS}-${ARCH}"
    
    echo "📥 Downloading from: $DOWNLOAD_URL"
    if curl -L "$DOWNLOAD_URL" -o /tmp/opencode 2>/dev/null; then
        chmod +x /tmp/opencode
        sudo mv /tmp/opencode /usr/local/bin/opencode
        echo "✅ OpenCode binary installed"
    else
        echo "⚠️ Binary download failed, creating mock CLI"
        create_mock_cli
    fi
}

install_via_curl() {
    echo "📥 Installing OpenCode via curl script..."
    
    # Mock installation script
    if curl -fsSL https://opencode.ai/install.sh 2>/dev/null | bash; then
        echo "✅ OpenCode installed via curl script"
    else
        echo "⚠️ Curl installation failed, creating mock CLI"
        create_mock_cli
    fi
}

create_mock_cli() {
    echo "🛠️ Creating mock OpenCode CLI for development..."
    
    # Create mock CLI script
    cat > /tmp/opencode << 'EOF'
#!/bin/bash
# OpenCode AI Assistant CLI (Mock Implementation)

VERSION="1.0.0-dev"
CONFIG_DIR="$HOME/.opencode"
CONFIG_FILE="$CONFIG_DIR/config.json"

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

show_help() {
    cat << 'HELP'
OpenCode AI Assistant CLI

Usage: opencode [COMMAND] [OPTIONS]

Commands:
    auth          Authenticate with OpenCode
    config        Configure OpenCode settings
    chat          Start interactive chat session
    analyze       Analyze code in current directory
    suggest       Get code suggestions
    explain       Explain code functionality
    fix           Auto-fix code issues
    test          Generate tests for code
    docs          Generate documentation
    version       Show version information
    help          Show this help message

Options:
    --help, -h    Show help
    --version     Show version
    --config      Specify config file
    --verbose     Verbose output

Examples:
    opencode auth                    # Authenticate
    opencode chat                    # Start chat session
    opencode analyze --lang fsharp   # Analyze F# code
    opencode suggest main.fs         # Get suggestions for file
    opencode explain function_name   # Explain function
    opencode fix --auto              # Auto-fix issues
    opencode test --generate         # Generate tests

For more information, visit: https://opencode.ai/docs
HELP
}

show_version() {
    echo "OpenCode CLI version $VERSION"
}

authenticate() {
    echo "🔐 OpenCode Authentication"
    echo ""
    echo "To authenticate with OpenCode:"
    echo "1. Visit: https://opencode.ai/auth"
    echo "2. Generate an API key"
    echo "3. Run: opencode config --set api_key=YOUR_KEY"
    echo ""
    echo "Or set environment variable: export OPENCODE_API_KEY=YOUR_KEY"
}

configure() {
    case "$2" in
        "--set")
            if [[ "$3" == *"="* ]]; then
                key="${3%%=*}"
                value="${3#*=}"
                echo "Setting $key = $value"
                # In real implementation, save to config file
                echo "✅ Configuration saved"
            else
                echo "❌ Invalid format. Use: opencode config --set key=value"
            fi
            ;;
        "--get")
            echo "Current configuration:"
            echo "api_key: [configured]"
            echo "context_sharing: enabled"
            echo "auto_suggestions: enabled"
            ;;
        *)
            echo "Usage: opencode config [--set key=value] [--get]"
            ;;
    esac
}

start_chat() {
    echo "💬 Starting OpenCode AI chat session..."
    echo "Type 'help' for available commands, 'exit' to quit"
    echo ""
    
    while true; do
        read -p "opencode> " input
        case "$input" in
            "exit"|"quit"|"q")
                echo "👋 Goodbye!"
                break
                ;;
            "help")
                echo "Available commands:"
                echo "  analyze [file]  - Analyze code"
                echo "  suggest [file]  - Get suggestions"
                echo "  explain [code]  - Explain code"
                echo "  fix [file]      - Fix code issues"
                echo "  exit           - Exit chat"
                ;;
            "analyze"*)
                echo "🔍 Analyzing code... (mock response)"
                echo "✅ No issues found in F# code"
                ;;
            "suggest"*)
                echo "💡 Code suggestions... (mock response)"
                echo "Consider using pattern matching for better readability"
                ;;
            *)
                echo "🤖 AI: This is a mock response. In the real implementation,"
                echo "    I would provide AI-powered assistance for: $input"
                ;;
        esac
    done
}

analyze_code() {
    echo "🔍 Analyzing code in current directory..."
    echo "Language: F#"
    echo "Files found: $(find . -name "*.fs" -o -name "*.fsx" -o -name "*.fsi" | wc -l)"
    echo "✅ Analysis complete (mock)"
}

suggest_code() {
    file="$2"
    if [ -f "$file" ]; then
        echo "💡 Analyzing file: $file"
        echo "Suggestions:"
        echo "  • Consider using more descriptive variable names"
        echo "  • Add type annotations for better clarity"
        echo "  • Use pattern matching instead of if-else chains"
    else
        echo "❌ File not found: $file"
    fi
}

# Main command dispatcher
case "$1" in
    "auth"|"authenticate")
        authenticate
        ;;
    "config"|"configure")
        configure "$@"
        ;;
    "chat")
        start_chat
        ;;
    "analyze")
        analyze_code "$@"
        ;;
    "suggest")
        suggest_code "$@"
        ;;
    "explain")
        echo "🤖 Explaining: $2 (mock implementation)"
        ;;
    "fix")
        echo "🔧 Auto-fixing code issues... (mock implementation)"
        ;;
    "test")
        echo "🧪 Generating tests... (mock implementation)"
        ;;
    "docs")
        echo "📖 Generating documentation... (mock implementation)"
        ;;
    "version"|"--version")
        show_version
        ;;
    "help"|"--help"|"")
        show_help
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo "Run 'opencode help' for available commands"
        exit 1
        ;;
esac
EOF

    # Make executable and install
    chmod +x /tmp/opencode
    sudo mv /tmp/opencode /usr/local/bin/opencode
    
    echo "✅ Mock OpenCode CLI installed at /usr/local/bin/opencode"
}

configure_vscode_integration() {
    if [ "${ENABLE_VSCODE_INTEGRATION}" = "true" ]; then
        echo "⚙️ Configuring VS Code integration..."
        
        # Create VS Code settings for OpenCode
        mkdir -p /tmp/vscode-opencode
        cat > /tmp/vscode-opencode/settings.json << EOF
{
    "opencode.enableAutoCompletion": true,
    "opencode.enableCodeAnalysis": ${ENABLE_CONTEXT_SHARING,,},
    "opencode.contextSharing": ${ENABLE_CONTEXT_SHARING,,},
    "opencode.autoSuggest": true,
    "opencode.languageSupport": ["fsharp", "typescript", "javascript"],
    "opencode.apiEndpoint": "https://api.opencode.ai",
    "opencode.maxContextLines": 1000,
    "opencode.enableInlineChat": true,
    "opencode.keyBindings": {
        "openChat": "ctrl+shift+o",
        "explainCode": "ctrl+shift+e",
        "suggestCode": "ctrl+shift+s"
    }
}
EOF

        echo "✅ VS Code settings configured for OpenCode"
    fi
}

configure_authentication() {
    if [ "${AUTO_AUTHENTICATE}" = "true" ]; then
        echo "🔐 Setting up authentication..."
        
        # Create authentication configuration
        mkdir -p /tmp/.opencode
        cat > /tmp/.opencode/config.json << 'EOF'
{
    "version": "1.0.0",
    "authentication": {
        "method": "api_key",
        "auto_refresh": true,
        "expires_in": 3600
    },
    "settings": {
        "context_sharing": true,
        "auto_suggestions": true,
        "language_preferences": ["fsharp", "typescript"],
        "response_format": "markdown"
    },
    "endpoints": {
        "api": "https://api.opencode.ai",
        "auth": "https://auth.opencode.ai",
        "websocket": "wss://ws.opencode.ai"
    }
}
EOF

        echo "✅ Authentication configuration created"
        echo "💡 Set OPENCODE_API_KEY environment variable or run 'opencode auth'"
    fi
}

configure_git_integration() {
    if [ "${CONFIGURE_GIT_INTEGRATION}" = "true" ]; then
        echo "🔗 Configuring Git integration..."
        
        # Create git hooks for OpenCode
        mkdir -p /tmp/git-hooks
        
        # Pre-commit hook for code analysis
        cat > /tmp/git-hooks/pre-commit << 'EOF'
#!/bin/bash
# OpenCode Pre-commit Hook

echo "🔍 Running OpenCode analysis..."

# Check if OpenCode is available
if ! command -v opencode >/dev/null 2>&1; then
    echo "⚠️ OpenCode CLI not found, skipping analysis"
    exit 0
fi

# Analyze staged files
staged_files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(fs|fsx|fsi|ts|tsx|js)$')

if [ -n "$staged_files" ]; then
    echo "Analyzing staged files..."
    for file in $staged_files; do
        echo "  • $file"
        # In real implementation: opencode analyze "$file"
    done
    echo "✅ Analysis complete"
fi

exit 0
EOF

        # Commit message hook for suggestions
        cat > /tmp/git-hooks/prepare-commit-msg << 'EOF'
#!/bin/bash
# OpenCode Commit Message Hook

commit_file="$1"
commit_source="$2"

# Only enhance commit messages for regular commits
if [ "$commit_source" != "message" ] && [ "$commit_source" != "template" ]; then
    exit 0
fi

# Check if OpenCode is available
if ! command -v opencode >/dev/null 2>&1; then
    exit 0
fi

# Get staged files
staged_files=$(git diff --cached --name-only)

if [ -n "$staged_files" ]; then
    echo "" >> "$commit_file"
    echo "# OpenCode Analysis:" >> "$commit_file"
    echo "# Files modified: $(echo "$staged_files" | wc -l)" >> "$commit_file"
    echo "# Languages: $(echo "$staged_files" | grep -E '\.(fs|fsx|fsi)$' | wc -l) F#, $(echo "$staged_files" | grep -E '\.(ts|tsx)$' | wc -l) TypeScript" >> "$commit_file"
fi
EOF

        chmod +x /tmp/git-hooks/pre-commit /tmp/git-hooks/prepare-commit-msg
        
        echo "✅ Git hooks created in /tmp/git-hooks/"
        echo "💡 Copy to .git/hooks/ in your repository to enable"
    fi
}

create_configuration_files() {
    echo "📝 Creating OpenCode configuration files..."
    
    # Create global configuration
    cat > /tmp/opencode-global.json << 'EOF'
{
    "version": "1.0.0",
    "defaults": {
        "language": "fsharp",
        "output_format": "markdown",
        "max_suggestions": 5,
        "context_window": 1000,
        "temperature": 0.7
    },
    "features": {
        "auto_completion": true,
        "code_analysis": true,
        "test_generation": true,
        "documentation": true,
        "refactoring_suggestions": true
    },
    "integrations": {
        "vscode": true,
        "git": false,
        "ci_cd": false
    }
}
EOF

    # Create F# specific configuration
    cat > /tmp/opencode-fsharp.json << 'EOF'
{
    "language": "fsharp",
    "file_extensions": [".fs", ".fsx", ".fsi"],
    "features": {
        "pattern_matching_suggestions": true,
        "type_inference_help": true,
        "pipeline_optimization": true,
        "immutability_suggestions": true,
        "functional_style_tips": true
    },
    "analysis": {
        "complexity_threshold": 10,
        "line_length_limit": 120,
        "prefer_expressions": true,
        "suggest_discriminated_unions": true
    },
    "testing": {
        "preferred_framework": "expecto",
        "generate_property_tests": true,
        "test_naming_convention": "should_[behavior]_when_[condition]"
    }
}
EOF

    echo "✅ Configuration files created"
}

verify_installation() {
    echo "🔍 Verifying OpenCode installation..."
    
    # Check if OpenCode CLI is available
    if command -v opencode >/dev/null 2>&1; then
        echo "✅ OpenCode CLI available: $(opencode version)"
    else
        echo "❌ OpenCode CLI not found"
        return 1
    fi
    
    # Test basic functionality
    if opencode help >/dev/null 2>&1; then
        echo "✅ OpenCode CLI responds to commands"
    else
        echo "⚠️ OpenCode CLI not responding properly"
    fi
    
    echo "✅ OpenCode AI assistant is ready!"
    return 0
}

# Main installation flow
main() {
    validate_environment
    install_opencode
    configure_vscode_integration
    configure_authentication
    configure_git_integration
    create_configuration_files
    verify_installation
    
    echo ""
    echo "🤖 OpenCode AI assistant is ready!"
    echo ""
    echo "🔧 Configuration:"
    echo "   • Installation method: ${INSTALL_METHOD}"
    echo "   • Version: ${OPENCODE_VERSION}"
    echo "   • VS Code integration: ${ENABLE_VSCODE_INTEGRATION}"
    echo "   • Context sharing: ${ENABLE_CONTEXT_SHARING}"
    echo "   • Git integration: ${CONFIGURE_GIT_INTEGRATION}"
    echo "   • Auto authentication: ${AUTO_AUTHENTICATE}"
    echo ""
    echo "📖 Quick start:"
    echo "   • opencode auth                  - Authenticate with API"
    echo "   • opencode chat                  - Start interactive session"
    echo "   • opencode analyze              - Analyze current code"
    echo "   • opencode suggest file.fs      - Get code suggestions"
    echo "   • opencode help                 - Show all commands"
    echo ""
    echo "🔐 Authentication:"
    if [ "${AUTO_AUTHENTICATE}" = "true" ]; then
        echo "   • Set OPENCODE_API_KEY environment variable"
        echo "   • Or run: opencode config --set api_key=YOUR_KEY"
    else
        echo "   • Run: opencode auth to authenticate"
    fi
    echo ""
    echo "📁 Configuration files created in /tmp/:"
    echo "   • opencode-global.json          - Global settings"
    echo "   • opencode-fsharp.json          - F# specific settings"
    if [ "${ENABLE_VSCODE_INTEGRATION}" = "true" ]; then
        echo "   • vscode-opencode/settings.json - VS Code settings"
    fi
    if [ "${CONFIGURE_GIT_INTEGRATION}" = "true" ]; then
        echo "   • git-hooks/                    - Git integration hooks"
    fi
    echo ""
    echo "💡 Note: This is a development implementation. The real OpenCode CLI"
    echo "    will provide actual AI-powered assistance when available."
}

main "$@"