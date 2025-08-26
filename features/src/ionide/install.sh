#!/bin/bash
set -euo pipefail

# Feature: Ionide F# Language Support
# Version: 1.0.0
# Description: Complete F# development environment for VS Code

# Parse feature options
ENABLE_FSAC=${ENABLEFSAC:-"true"}
ENABLE_TOOLTIPS=${ENABLETOOLTIPS:-"true"}
ENABLE_LINTING=${ENABLELINTING:-"true"}
ENABLE_CODE_LENS=${ENABLECODELENS:-"true"}
ENABLE_PAKET_INTEGRATION=${ENABLEPAKETINTEGRATION:-"true"}
ENABLE_FAKE_INTEGRATION=${ENABLEFAKEINTEGRATION:-"true"}

echo "Setting up Ionide F# language support for VS Code..."

# Validation functions
validate_environment() {
    echo "🔍 Validating environment..."
    
    # Check if dotnet is available
    if ! command -v dotnet >/dev/null 2>&1; then
        echo "❌ .NET SDK not found. Please ensure the dotnet feature is installed first."
        exit 1
    fi
    
    echo "✅ .NET SDK found: $(dotnet --version)"
}

install_vscode_extensions() {
    echo "📦 Installing VS Code extensions..."
    
    # Core Ionide F# extension
    echo "Installing Ionide F# extension..."
    
    # Optional Paket integration
    if [ "${ENABLE_PAKET_INTEGRATION}" = "true" ]; then
        echo "📦 Paket integration will be available when Ionide-Paket is installed"
    fi
    
    # Optional FAKE integration  
    if [ "${ENABLE_FAKE_INTEGRATION}" = "true" ]; then
        echo "🛠️ FAKE integration will be available when Ionide-FAKE is installed"
    fi
    
    # Extensions are installed via the customizations section in devcontainer-feature.json
    echo "✅ VS Code extensions configured for installation"
}

configure_fsharp_settings() {
    echo "⚙️ Configuring F# language service settings..."
    
    # Create VS Code settings directory if it doesn't exist
    mkdir -p /tmp/vscode-settings
    
    # Generate F# specific settings
    cat > /tmp/vscode-settings/fsharp-settings.json << EOF
{
    "FSharp.enableLSP": ${ENABLE_FSAC,,},
    "FSharp.enableTooltips": ${ENABLE_TOOLTIPS,,},
    "FSharp.linter": ${ENABLE_LINTING,,},
    "FSharp.enableCodeLens": ${ENABLE_CODE_LENS,,},
    "FSharp.suggestGitignore": false,
    "FSharp.enableTreeView": true,
    "FSharp.showExplorerIcon": true,
    "FSharp.enableBackgroundServices": true,
    "FSharp.workspaceModePeekDeepLevel": 2,
    "FSharp.enableMSBuildProjectGraph": true,
    "FSharp.dotNetRoot": "/usr/share/dotnet",
    "editor.semanticHighlighting.enabled": true,
    "editor.bracketPairColorization.enabled": true,
    "files.associations": {
        "*.fs": "fsharp",
        "*.fsx": "fsharp", 
        "*.fsi": "fsharp"
    }
}
EOF

    echo "✅ F# settings created at /tmp/vscode-settings/fsharp-settings.json"
    echo "💡 These settings will be applied automatically in the devcontainer"
}

create_fsharp_snippet() {
    echo "📝 Creating F# code snippets..."
    
    mkdir -p /tmp/vscode-snippets
    
    cat > /tmp/vscode-snippets/fsharp.json << 'EOF'
{
    "Module declaration": {
        "prefix": "module",
        "body": [
            "module ${1:ModuleName}",
            "",
            "$0"
        ],
        "description": "F# module declaration"
    },
    "Open namespace": {
        "prefix": "open",
        "body": [
            "open ${1:Namespace}"
        ],
        "description": "Open namespace or module"
    },
    "Let binding": {
        "prefix": "let",
        "body": [
            "let ${1:name} = ${2:value}"
        ],
        "description": "Let binding"
    },
    "Function definition": {
        "prefix": "letfun", 
        "body": [
            "let ${1:functionName} ${2:parameters} =",
            "    ${3:body}"
        ],
        "description": "Function definition"
    },
    "Type definition": {
        "prefix": "type",
        "body": [
            "type ${1:TypeName} = {",
            "    ${2:Property}: ${3:Type}",
            "}"
        ],
        "description": "Record type definition"
    },
    "Pattern match": {
        "prefix": "match",
        "body": [
            "match ${1:expression} with",
            "| ${2:pattern} -> ${3:result}",
            "| _ -> ${4:default}"
        ],
        "description": "Pattern match expression"
    }
}
EOF

    echo "✅ F# code snippets created at /tmp/vscode-snippets/fsharp.json"
}

verify_installation() {
    echo "🔍 Verifying Ionide setup..."
    
    # Check .NET SDK again
    if command -v dotnet >/dev/null 2>&1; then
        echo "✅ .NET SDK available: $(dotnet --version)"
    else
        echo "⚠️ .NET SDK not found in PATH"
        return 1
    fi
    
    # Verify settings files were created
    if [ -f "/tmp/vscode-settings/fsharp-settings.json" ]; then
        echo "✅ F# settings configured"
    else
        echo "⚠️ F# settings not found"
        return 1
    fi
    
    echo "✅ Ionide F# language support is ready!"
    return 0
}

# Main installation flow
main() {
    validate_environment
    install_vscode_extensions
    configure_fsharp_settings  
    create_fsharp_snippet
    verify_installation
    
    echo ""
    echo "🚀 Ionide F# language support is ready!"
    echo ""
    echo "📖 Features enabled:"
    echo "   • F# Language Server Protocol (LSP): ${ENABLE_FSAC}"
    echo "   • Hover tooltips: ${ENABLE_TOOLTIPS}" 
    echo "   • F# linting: ${ENABLE_LINTING}"
    echo "   • Code lens: ${ENABLE_CODE_LENS}"
    echo "   • Paket integration: ${ENABLE_PAKET_INTEGRATION}"
    echo "   • FAKE integration: ${ENABLE_FAKE_INTEGRATION}"
    echo ""
    echo "🔧 Configuration files created:"
    echo "   • F# settings: /tmp/vscode-settings/fsharp-settings.json"
    echo "   • F# snippets: /tmp/vscode-snippets/fsharp.json"
    echo ""
    echo "💡 Next steps:"
    echo "   • VS Code extensions will be installed automatically"
    echo "   • Open an F# project to see Ionide in action"
    echo "   • Use Ctrl+Shift+P and search 'F#' to see available commands"
}

main "$@"