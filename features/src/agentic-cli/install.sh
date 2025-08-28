#!/bin/bash
set -euo pipefail

# Feature: Agentic CLI
# Version: 1.0.0
# Description: Installs Agentic CLI - modular AI agent system for development workflows

# Parse feature options
AGENTIC_VERSION=${VERSION:-"latest"}
INSTALL_BUN=${INSTALLBUN:-"true"}
ADD_TO_PATH=${ADDTOPATH:-"true"}
CREATE_CONFIG=${CREATECONFIG:-"true"}

echo "Installing Agentic CLI (version: ${AGENTIC_VERSION})..."

# Validation functions
validate_environment() {
    if [[ $EUID -eq 0 ]]; then
        echo "⚠️  Running as root - this is acceptable for container setup"
        USER_HOME="/root"
        SUDO=""
    else
        USER_HOME="$HOME"
        SUDO="sudo"
    fi
    echo "🏠 User home: ${USER_HOME}"
}

install_bun() {
    if [ "${INSTALL_BUN}" = "true" ]; then
        echo "📦 Installing Bun runtime..."
        if ! command -v bun >/dev/null 2>&1; then
            curl -fsSL https://bun.sh/install | bash
            # Add bun to PATH for this session
            export PATH="$USER_HOME/.bun/bin:$PATH"
            echo "✅ Bun installed successfully"
        else
            echo "✅ Bun already installed"
        fi
    fi
}

install_agentic() {
    echo "📦 Installing Agentic CLI..."
    
    # Ensure we have a temporary directory for installation
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Clone the repository
    case "$AGENTIC_VERSION" in
        "latest"|"main")
            git clone https://github.com/Cluster444/agentic.git
            ;;
        *)
            git clone --branch "$AGENTIC_VERSION" https://github.com/Cluster444/agentic.git
            ;;
    esac
    
    cd agentic
    
    # Install dependencies and build
    echo "🔨 Building Agentic CLI..."
    bun install
    bun run build
    
    # Create installation directory
    INSTALL_DIR="$USER_HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
    
    # Copy binary to installation directory
    cp bin/agentic "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/agentic"
    
    # Create a symlink for system-wide access if running as root
    if [[ $EUID -eq 0 ]]; then
        ln -sf "$INSTALL_DIR/agentic" /usr/local/bin/agentic
    fi
    
    # Cleanup
    cd /
    rm -rf "$TEMP_DIR"
    
    echo "✅ Agentic CLI installed to $INSTALL_DIR/agentic"
}

configure_path() {
    if [ "${ADD_TO_PATH}" = "true" ]; then
        echo "⚙️  Configuring PATH..."
        
        # Add to bashrc
        if [ -f "$USER_HOME/.bashrc" ]; then
            if ! grep -q "$USER_HOME/.local/bin" "$USER_HOME/.bashrc"; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$USER_HOME/.bashrc"
                echo "✅ Added ~/.local/bin to PATH in .bashrc"
            fi
        fi
        
        # Add to zshrc if it exists
        if [ -f "$USER_HOME/.zshrc" ]; then
            if ! grep -q "$USER_HOME/.local/bin" "$USER_HOME/.zshrc"; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$USER_HOME/.zshrc"
                echo "✅ Added ~/.local/bin to PATH in .zshrc"
            fi
        fi
        
        # Add to current session
        export PATH="$USER_HOME/.local/bin:$PATH"
    fi
}

create_agentic_config() {
    if [ "${CREATE_CONFIG}" = "true" ]; then
        echo "📝 Creating Agentic configuration..."
        
        # Create config directory
        CONFIG_DIR="$USER_HOME/.agentic"
        mkdir -p "$CONFIG_DIR"
        
        # Create basic config file
        cat > "$CONFIG_DIR/config.json" << 'EOF'
{
  "defaultAgent": "general",
  "agents": {
    "general": {
      "description": "General-purpose agent for development tasks",
      "enabled": true
    }
  },
  "commands": {
    "research": {
      "enabled": true,
      "defaultAgent": "general"
    },
    "plan": {
      "enabled": true,
      "defaultAgent": "general"
    },
    "execute": {
      "enabled": true,
      "defaultAgent": "general"
    }
  }
}
EOF
        
        # Create thoughts directory
        mkdir -p "$CONFIG_DIR/thoughts"
        
        echo "✅ Created Agentic configuration at $CONFIG_DIR"
    fi
}

verify_installation() {
    echo "🔍 Verifying Agentic installation..."
    
    # Test if agentic command is available
    if command -v agentic >/dev/null 2>&1; then
        echo "✅ Agentic CLI installed successfully"
        echo "📋 Available commands:"
        agentic --help || echo "   (help command failed, but binary is installed)"
        return 0
    else
        echo "❌ Agentic installation verification failed"
        return 1
    fi
}

# Main installation flow
main() {
    validate_environment
    install_bun
    install_agentic
    configure_path
    create_agentic_config
    verify_installation
    
    echo ""
    echo "🤖 Agentic CLI is ready!"
    echo "📖 Usage:"
    echo "   • Initialize project:  agentic init"
    echo "   • Check status:       agentic status"
    echo "   • Pull updates:       agentic pull"
    echo "   • Plan tasks:         agentic plan <description>"
    echo "   • Research topics:    agentic research <query>"
    echo ""
    echo "🔧 Configuration:"
    echo "   • Config location: ~/.agentic/config.json"
    echo "   • Thoughts storage: ~/.agentic/thoughts/"
    echo "   • Documentation: https://github.com/Cluster444/agentic"
    echo ""
    echo "💡 Tip: Run 'agentic init' in your project directory to get started"
}

main "$@"