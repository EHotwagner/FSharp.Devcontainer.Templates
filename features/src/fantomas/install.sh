#!/bin/bash
set -euo pipefail

# Feature: Fantomas F# Formatter
# Version: 1.0.0
# Description: Installs Fantomas F# code formatter with VS Code integration

# Parse feature options
FANTOMAS_VERSION=${VERSION:-"latest"}
ENABLE_EDITOR_CONFIG=${ENABLEEDITORCONFIG:-"true"}
FORMAT_ON_SAVE=${FORMATONSAVE:-"true"}
MAX_LINE_LENGTH=${MAXLINELENGTH:-"120"}

echo "Installing Fantomas F# formatter (version: ${FANTOMAS_VERSION})..."

# Validation functions
validate_user() {
    if [[ $EUID -eq 0 ]]; then
        echo "⚠️  Running as root - this is acceptable for container setup"
    fi
}

install_fantomas() {
    echo "📦 Installing Fantomas..."
    case "$FANTOMAS_VERSION" in
        "latest")
            dotnet tool install -g fantomas
            ;;
        *)
            dotnet tool install -g fantomas --version "$FANTOMAS_VERSION"
            ;;
    esac
}

create_editorconfig() {
    if [ "${ENABLE_EDITOR_CONFIG}" = "true" ]; then
        echo "📝 Creating .editorconfig template..."
        cat > /tmp/editorconfig-fsharp << EOF
# F# formatting configuration for Fantomas
root = true

[*.{fs,fsx,fsi}]
insert_final_newline = true
indent_style = space
indent_size = 4
max_line_length = ${MAX_LINE_LENGTH}
trim_trailing_whitespace = true

# Fantomas-specific settings
fsharp_semicolon_at_end_of_line = false
fsharp_space_before_parameter = true
fsharp_space_before_lowercase_invocation = true
fsharp_space_before_uppercase_invocation = false
fsharp_space_before_class_constructor = false
fsharp_space_before_member = false
fsharp_space_before_colon = false
fsharp_space_after_comma = true
fsharp_space_before_semicolon = false
fsharp_space_after_semicolon = true
fsharp_indent_on_try_with = false
fsharp_space_around_delimiter = true
fsharp_max_line_length = ${MAX_LINE_LENGTH}
EOF

        echo "✅ Created .editorconfig template at /tmp/editorconfig-fsharp"
        echo "💡 Copy this to your project root to enable consistent F# formatting"
    fi
}

configure_vscode() {
    if [ "${FORMAT_ON_SAVE}" = "true" ]; then
        echo "⚙️  Configuring VS Code format-on-save..."
        # VS Code settings are handled by the feature's customizations section
        echo "✅ VS Code will format F# files on save (requires Ionide extension)"
    fi
}

verify_installation() {
    echo "🔍 Verifying Fantomas installation..."
    if command -v fantomas >/dev/null 2>&1; then
        echo "✅ Fantomas installed successfully"
        fantomas --version
        return 0
    else
        echo "❌ Fantomas installation failed"
        return 1
    fi
}

# Main installation flow
main() {
    validate_user
    install_fantomas
    create_editorconfig
    configure_vscode
    verify_installation
    
    echo ""
    echo "🎨 Fantomas F# formatter is ready!"
    echo "📖 Usage:"
    echo "   • Format single file: fantomas file.fs"
    echo "   • Format directory:   fantomas --recurse src/"
    echo "   • Check formatting:   fantomas --check file.fs"
    echo ""
    echo "🔧 Configuration:"
    echo "   • Copy /tmp/editorconfig-fsharp to your project root as .editorconfig"
    echo "   • Fantomas will respect .editorconfig settings automatically"
    echo "   • VS Code will format on save when Ionide extension is installed"
}

main "$@"