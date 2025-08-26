#!/bin/bash
set -euo pipefail

# Feature options from environment variables
FANTOMAS_VERSION=${VERSION:-"latest"}
ENABLE_EDITOR_CONFIG=${ENABLEEDITORCONFIG:-"true"}

echo "Installing Fantomas F# formatter (version: ${FANTOMAS_VERSION})..."

# Install Fantomas as global tool
if [ "${FANTOMAS_VERSION}" = "latest" ]; then
    dotnet tool install -g fantomas
else
    dotnet tool install -g fantomas --version "${FANTOMAS_VERSION}"
fi

# Create .editorconfig if requested
if [ "${ENABLE_EDITOR_CONFIG}" = "true" ]; then
    cat > /tmp/editorconfig-fsharp << 'EOF'
# F# formatting configuration
[*.fs]
insert_final_newline = true
indent_style = space
indent_size = 4

[*.fsx]
insert_final_newline = true
indent_style = space
indent_size = 4

[*.fsi]
insert_final_newline = true
indent_style = space
indent_size = 4
EOF

    echo "Created .editorconfig template at /tmp/editorconfig-fsharp"
    echo "You can copy this to your project root to enable consistent F# formatting"
fi

# Verify installation
if command -v fantomas >/dev/null 2>&1; then
    echo "✅ Fantomas installed successfully"
    fantomas --version
else
    echo "❌ Fantomas installation failed"
    exit 1
fi

echo "🎨 Fantomas F# formatter is ready!"
echo "Usage: fantomas <file.fs> or fantomas --recurse <directory>"