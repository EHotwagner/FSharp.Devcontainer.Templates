#!/bin/bash
set -euo pipefail

# Feature: Paket Package Manager
# Version: 1.0.0
# Description: Installs Paket package manager with FSI integration

# Parse feature options
PAKET_VERSION=${VERSION:-"latest"}
ENABLE_AUTO_RESTORE=${ENABLEAUTORESTORE:-"true"}
CREATE_BOOTSTRAPPER=${CREATEBOOTSTRAPPER:-"false"}
INITIALIZE_REPO=${INITIALIZEREPO:-"false"}
ENABLE_FSI_INTEGRATION=${ENABLEFSIINTEGRATION:-"true"}
GENERATE_LOAD_SCRIPTS=${GENERATELOADSCRIPTS:-"true"}

echo "Installing Paket package manager (version: ${PAKET_VERSION})..."

# Validation functions
validate_environment() {
    echo "🔍 Validating environment..."
    
    if ! command -v dotnet >/dev/null 2>&1; then
        echo "❌ .NET SDK not found. Please ensure the dotnet feature is installed first."
        exit 1
    fi
    
    echo "✅ .NET SDK found: $(dotnet --version)"
}

install_paket() {
    echo "📦 Installing Paket..."
    case "$PAKET_VERSION" in
        "latest")
            dotnet tool install -g paket
            ;;
        *)
            dotnet tool install -g paket --version "$PAKET_VERSION"
            ;;
    esac
}

create_paket_templates() {
    echo "📝 Creating Paket configuration templates..."
    
    # Create paket.dependencies template
    cat > /tmp/paket.dependencies << 'EOF'
source https://api.nuget.org/v3/index.json

# Core F# dependencies
nuget FSharp.Core >= 6.0.0

# Add your dependencies here
# Example:
# nuget Newtonsoft.Json
# nuget Serilog
# nuget Expecto

# Development dependencies group
group Development
    source https://api.nuget.org/v3/index.json
    nuget FAKE
    nuget Fantomas
    
# Testing dependencies group  
group Testing
    source https://api.nuget.org/v3/index.json
    nuget Expecto
    nuget FsUnit
EOF

    # Create paket.references template
    cat > /tmp/paket.references << 'EOF'
FSharp.Core
EOF

    # Create .paket/Paket.Restore.targets template
    mkdir -p /tmp/.paket
    cat > /tmp/.paket/Paket.Restore.targets << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <PropertyGroup>
    <PaketExePath Condition=" '$(PaketExePath)' == '' ">$(MSBuildThisFileDirectory)paket.exe</PaketExePath>
    <PaketCommand Condition=" '$(OS)' == 'Windows_NT'">"$(PaketExePath)"</PaketCommand>
    <PaketCommand Condition=" '$(OS)' != 'Windows_NT' ">mono --runtime=v4.0.30319 "$(PaketExePath)"</PaketCommand>
  </PropertyGroup>
  
  <Target Name="PaketRestore" Condition="'$(PaketRestoreDisabled)' != 'true'">
    <Exec Command="$(PaketCommand) restore" Condition=" '$(PaketRestoreDisabled)' != 'true' " ContinueOnError="false" />
  </Target>
</Project>
EOF

    echo "✅ Paket templates created:"
    echo "   • /tmp/paket.dependencies - Main dependency file"
    echo "   • /tmp/paket.references - Project references template"
    echo "   • /tmp/.paket/Paket.Restore.targets - MSBuild integration"
}

configure_fsi_integration() {
    if [ "${ENABLE_FSI_INTEGRATION}" = "true" ]; then
        echo "⚙️ Configuring Paket FSI integration..."
        
        # Create FSI load script template
        cat > /tmp/load-project-references.fsx << 'EOF'
// Paket F# Interactive integration
// This script loads project dependencies for FSI sessions

#I __SOURCE_DIRECTORY__
#load ".paket/load/main.group.fsx"

// Alternative direct package loading:
// #r "nuget: FSharp.Core"
// #r "nuget: Newtonsoft.Json"

printfn "✅ Project dependencies loaded successfully"
EOF

        # Create paket.local template for FSI configuration
        cat > /tmp/paket.local << 'EOF'
# Paket local configuration
# This file is typically git-ignored and contains local overrides

storage: none
framework: net8.0
generate-load-scripts: true
generate-load-scripts-lang: fsx
generate-load-scripts-type: reference
EOF

        echo "✅ FSI integration configured:"
        echo "   • /tmp/load-project-references.fsx - FSI load script"
        echo "   • /tmp/paket.local - Local configuration"
    fi
}

setup_auto_restore() {
    if [ "${ENABLE_AUTO_RESTORE}" = "true" ]; then
        echo "🔄 Configuring automatic package restore..."
        
        # Create global MSBuild properties
        mkdir -p /tmp/msbuild
        cat > /tmp/msbuild/Directory.Build.props << 'EOF'
<Project>
  <PropertyGroup>
    <RestorePackagesWithLockFile>true</RestorePackagesWithLockFile>
    <DisableImplicitNuGetFallbackFolder>true</DisableImplicitNuGetFallbackFolder>
  </PropertyGroup>
  
  <Import Project=".paket/Paket.Restore.targets" Condition="Exists('.paket/Paket.Restore.targets')" />
</Project>
EOF

        echo "✅ Auto-restore configured via Directory.Build.props"
    fi
}

create_bootstrapper() {
    if [ "${CREATE_BOOTSTRAPPER}" = "true" ]; then
        echo "🥾 Creating Paket bootstrapper..."
        
        # Download paket bootstrapper
        mkdir -p /tmp/.paket
        if command -v curl >/dev/null 2>&1; then
            curl -L https://github.com/fsprojects/Paket/releases/latest/download/paket.bootstrapper.exe -o /tmp/.paket/paket.bootstrapper.exe
            echo "✅ Paket bootstrapper downloaded to /tmp/.paket/paket.bootstrapper.exe"
        else
            echo "⚠️ curl not available, skipping bootstrapper download"
        fi
    fi
}

initialize_repository() {
    if [ "${INITIALIZE_REPO}" = "true" ]; then
        echo "🏗️ Initializing Paket repository structure..."
        
        # Create basic directory structure
        mkdir -p /tmp/src /tmp/tests
        
        # Copy templates to proper locations
        cp /tmp/paket.dependencies /tmp/paket.dependencies.init
        cp /tmp/paket.references /tmp/src/paket.references.init
        
        echo "✅ Repository structure initialized"
        echo "💡 Run 'paket install' in your project directory to complete setup"
    fi
}

verify_installation() {
    echo "🔍 Verifying Paket installation..."
    
    if command -v paket >/dev/null 2>&1; then
        echo "✅ Paket installed successfully"
        paket --version
        return 0
    else
        echo "❌ Paket installation failed"
        return 1
    fi
}

# Main installation flow
main() {
    validate_environment
    install_paket
    create_paket_templates
    configure_fsi_integration
    setup_auto_restore
    create_bootstrapper
    initialize_repository
    verify_installation
    
    echo ""
    echo "📦 Paket package manager is ready!"
    echo ""
    echo "🔧 Configuration:"
    echo "   • Auto-restore: ${ENABLE_AUTO_RESTORE}"
    echo "   • FSI integration: ${ENABLE_FSI_INTEGRATION}"
    echo "   • Load scripts: ${GENERATE_LOAD_SCRIPTS}"
    echo "   • Bootstrapper: ${CREATE_BOOTSTRAPPER}"
    echo ""
    echo "📖 Quick start:"
    echo "   • paket init                    - Initialize new project"
    echo "   • paket add <package>          - Add dependency"
    echo "   • paket install                - Install dependencies"
    echo "   • paket update                 - Update dependencies"
    echo "   • paket generate-load-scripts  - Generate FSI scripts"
    echo ""
    echo "🔗 FSI Integration:"
    echo "   • Use #load \".paket/load/main.group.fsx\" in FSI"
    echo "   • Copy /tmp/load-project-references.fsx to your project"
    echo ""
    echo "📁 Templates created in /tmp/ - copy to your project as needed"
}

main "$@"