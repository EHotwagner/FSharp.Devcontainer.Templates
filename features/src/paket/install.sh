#!/bin/bash
set -euo pipefail

# Feature options from environment variables
PAKET_VERSION=${VERSION:-"latest"}
CREATE_TEMPLATE=${CREATETEMPLATE:-"false"}

echo "Installing Paket package manager (version: ${PAKET_VERSION})..."

# Install Paket as global tool
if [ "${PAKET_VERSION}" = "latest" ]; then
    dotnet tool install -g paket
else
    dotnet tool install -g paket --version "${PAKET_VERSION}"
fi

# Create paket.dependencies template if requested
if [ "${CREATE_TEMPLATE}" = "true" ]; then
    cat > /tmp/paket.dependencies << 'EOF'
source https://api.nuget.org/v3/index.json

# Add your dependencies here
# Example:
# nuget FSharp.Core
# nuget Newtonsoft.Json

# For development dependencies:
# group Development
#   source https://api.nuget.org/v3/index.json
#   nuget FAKE
#   nuget Paket
EOF

    echo "Created paket.dependencies template at /tmp/paket.dependencies"
    echo "Copy this to your project root and customize as needed"
fi

# Verify installation
if command -v paket >/dev/null 2>&1; then
    echo "✅ Paket installed successfully"
    paket --version
else
    echo "❌ Paket installation failed"
    exit 1
fi

echo "📦 Paket package manager is ready!"
echo "Usage: paket init (initialize), paket install (install packages)"