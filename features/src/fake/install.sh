#!/bin/bash
set -euo pipefail

# Feature: FAKE F# Build System
# Version: 1.0.0
# Description: F# domain-specific language for build tasks and automation

# Parse feature options
FAKE_VERSION=${VERSION:-"latest"}
CREATE_TEMPLATE=${CREATETEMPLATE:-"true"}
ENABLE_MODULES=${ENABLEMODULES:-"true"}
INCLUDE_TARGETS=${INCLUDETARGETS:-"Clean,Build,Test"}
ENABLE_PAKET_INTEGRATION=${ENABLEPAKETINTEGRATION:-"true"}
ENABLE_DOTNET_INTEGRATION=${ENABLEDOTNETINTEGRATION:-"true"}

echo "Installing FAKE F# build system (version: ${FAKE_VERSION})..."

# Validation functions
validate_environment() {
    echo "🔍 Validating environment..."
    
    if ! command -v dotnet >/dev/null 2>&1; then
        echo "❌ .NET SDK not found. Please ensure the dotnet feature is installed first."
        exit 1
    fi
    
    echo "✅ .NET SDK found: $(dotnet --version)"
}

install_fake() {
    echo "📦 Installing FAKE..."
    case "$FAKE_VERSION" in
        "latest")
            dotnet tool install -g fake-cli
            ;;
        *)
            dotnet tool install -g fake-cli --version "$FAKE_VERSION"
            ;;
    esac
}

create_build_template() {
    if [ "${CREATE_TEMPLATE}" = "true" ]; then
        echo "📝 Creating FAKE build template..."
        
        # Parse targets
        IFS=',' read -ra TARGETS <<< "$INCLUDE_TARGETS"
        
        # Generate build.fsx template
        cat > /tmp/build.fsx << 'EOF'
#r "paket:
nuget Fake.DotNet.Cli
nuget Fake.IO.FileSystem
nuget Fake.Core.Target //"
#load ".fake/build.fsx/intellisense.fsx"

open Fake.Core
open Fake.DotNet
open Fake.IO
open Fake.IO.FileSystemOperators
open Fake.IO.Globbing.Operators
open Fake.Core.TargetOperators

// *** Project Configuration ***
let projectName = "YourProject"
let solutionFile = "*.sln"
let testProjects = "tests/**/*Tests.fsproj"
let srcProjects = "src/**/*.fsproj"

// *** Build Configuration ***
let buildMode = Environment.environVarOrDefault "CONFIGURATION" "Release"
let buildDir = "./build/"
let testDir = "./testresults/"
let packageDir = "./packages/"

// *** Helper Functions ***
let run cmd args dir =
    Command.RawCommand (cmd, Arguments.OfArgs args)
    |> CreateProcess.fromCommand
    |> CreateProcess.withWorkingDirectory dir
    |> CreateProcess.ensureExitCode
    |> Proc.run
    |> ignore

let setBuildParams (defaults: DotNet.BuildOptions) =
    { defaults with
        Configuration = DotNet.BuildConfiguration.fromString buildMode
        Common = 
            { defaults.Common with
                DotNetCliPath = "dotnet" } }

let setTestParams (defaults: DotNet.TestOptions) =
    { defaults with
        Configuration = DotNet.BuildConfiguration.fromString buildMode
        Logger = Some "console;verbosity=detailed"
        ResultsDirectory = Some testDir
        Common = 
            { defaults.Common with
                DotNetCliPath = "dotnet" } }

// *** Build Targets ***
EOF

        # Add specific targets based on configuration
        for target in "${TARGETS[@]}"; do
            case "${target// /}" in
                "Clean")
                    cat >> /tmp/build.fsx << 'EOF'

Target.create "Clean" (fun _ ->
    !! "src/**/bin"
    ++ "src/**/obj"
    ++ "tests/**/bin"
    ++ "tests/**/obj"
    ++ buildDir
    ++ testDir
    ++ packageDir
    |> Shell.cleanDirs 
    
    Trace.log "✅ Cleaned build artifacts"
)
EOF
                    ;;
                "Restore")
                    if [ "${ENABLE_PAKET_INTEGRATION}" = "true" ]; then
                        cat >> /tmp/build.fsx << 'EOF'

Target.create "Restore" (fun _ ->
    if Shell.Exec("paket", "restore") = 0 then
        Trace.log "✅ Paket restore completed"
    else
        DotNet.restore id solutionFile
        Trace.log "✅ NuGet restore completed"
)
EOF
                    else
                        cat >> /tmp/build.fsx << 'EOF'

Target.create "Restore" (fun _ ->
    DotNet.restore id solutionFile
    Trace.log "✅ NuGet restore completed"
)
EOF
                    fi
                    ;;
                "Build")
                    cat >> /tmp/build.fsx << 'EOF'

Target.create "Build" (fun _ ->
    solutionFile
    |> DotNet.build setBuildParams
    
    Trace.log "✅ Build completed successfully"
)
EOF
                    ;;
                "Test")
                    cat >> /tmp/build.fsx << 'EOF'

Target.create "Test" (fun _ ->
    !! testProjects
    |> Seq.iter (DotNet.test setTestParams)
    
    Trace.log "✅ Tests completed"
)
EOF
                    ;;
                "Package"|"Pack")
                    cat >> /tmp/build.fsx << 'EOF'

Target.create "Package" (fun _ ->
    !! srcProjects
    |> Seq.iter (DotNet.pack (fun p ->
        { p with
            Configuration = DotNet.BuildConfiguration.fromString buildMode
            OutputPath = Some packageDir
            Common = { p.Common with DotNetCliPath = "dotnet" } }))
    
    Trace.log "✅ Packages created"
)
EOF
                    ;;
                "Publish")
                    cat >> /tmp/build.fsx << 'EOF'

Target.create "Publish" (fun _ ->
    !! srcProjects
    |> Seq.iter (DotNet.publish (fun p ->
        { p with
            Configuration = DotNet.BuildConfiguration.fromString buildMode
            Common = { p.Common with DotNetCliPath = "dotnet" } }))
    
    Trace.log "✅ Published successfully"
)
EOF
                    ;;
            esac
        done

        # Add target dependencies
        cat >> /tmp/build.fsx << 'EOF'

// *** Target Dependencies ***
EOF

        # Generate dependencies based on targets
        if [[ "$INCLUDE_TARGETS" == *"Clean"* && "$INCLUDE_TARGETS" == *"Build"* ]]; then
            echo '"Clean"' >> /tmp/build.fsx
        fi
        
        if [[ "$INCLUDE_TARGETS" == *"Restore"* ]]; then
            if [[ "$INCLUDE_TARGETS" == *"Clean"* ]]; then
                echo '  ==> "Restore"' >> /tmp/build.fsx
            else
                echo '"Restore"' >> /tmp/build.fsx
            fi
        fi
        
        if [[ "$INCLUDE_TARGETS" == *"Build"* ]]; then
            if [[ "$INCLUDE_TARGETS" == *"Restore"* ]]; then
                echo '  ==> "Build"' >> /tmp/build.fsx
            elif [[ "$INCLUDE_TARGETS" == *"Clean"* ]]; then
                echo '  ==> "Build"' >> /tmp/build.fsx
            else
                echo '"Build"' >> /tmp/build.fsx
            fi
        fi
        
        if [[ "$INCLUDE_TARGETS" == *"Test"* ]]; then
            echo '  ==> "Test"' >> /tmp/build.fsx
        fi
        
        if [[ "$INCLUDE_TARGETS" == *"Package"* || "$INCLUDE_TARGETS" == *"Pack"* ]]; then
            echo '  ==> "Package"' >> /tmp/build.fsx
        fi
        
        if [[ "$INCLUDE_TARGETS" == *"Publish"* ]]; then
            echo '  ==> "Publish"' >> /tmp/build.fsx
        fi

        # Add entry point
        cat >> /tmp/build.fsx << 'EOF'

// *** Default Target ***
Target.runOrDefault "Build"
EOF

        echo "✅ Build template created at /tmp/build.fsx"
    fi
}

create_paket_dependencies() {
    if [ "${ENABLE_PAKET_INTEGRATION}" = "true" ]; then
        echo "📦 Creating Paket dependencies for FAKE..."
        
        cat > /tmp/paket.dependencies.fake << 'EOF'
source https://api.nuget.org/v3/index.json

# FAKE build system
group Build
    source https://api.nuget.org/v3/index.json
    nuget Fake.DotNet.Cli
    nuget Fake.IO.FileSystem  
    nuget Fake.Core.Target
    nuget Fake.Core.ReleaseNotes
    nuget Fake.DotNet.AssemblyInfoFile
    nuget Fake.DotNet.Paket
    nuget Fake.Tools.Git
    nuget Fake.Core.Environment
    nuget Fake.Core.UserInput
    nuget Fake.IO.Zip
EOF

        echo "✅ Paket dependencies template created for FAKE"
    fi
}

create_build_scripts() {
    echo "📜 Creating build helper scripts..."
    
    # Create build.sh for Unix systems
    cat > /tmp/build.sh << 'EOF'
#!/usr/bin/env bash

set -eu
set -o pipefail

# FAKE F# Build Script

# Restore tools
dotnet tool restore

# Run FAKE build
dotnet fake build --target "${1:-Build}"
EOF

    # Create build.cmd for Windows systems
    cat > /tmp/build.cmd << 'EOF'
@echo off

rem FAKE F# Build Script

rem Restore tools
dotnet tool restore

rem Run FAKE build
dotnet fake build --target %1
if %1.==. (
    dotnet fake build --target Build
)
EOF

    chmod +x /tmp/build.sh
    
    echo "✅ Build scripts created:"
    echo "   • /tmp/build.sh - Unix build script"
    echo "   • /tmp/build.cmd - Windows build script"
}

create_dotnet_tools_manifest() {
    echo "🔧 Creating .NET tools manifest..."
    
    mkdir -p /tmp/.config
    cat > /tmp/.config/dotnet-tools.json << EOF
{
  "version": 1,
  "isRoot": true,
  "tools": {
    "fake-cli": {
      "version": "${FAKE_VERSION}",
      "commands": [
        "fake"
      ]
    }
  }
}
EOF

    echo "✅ .NET tools manifest created at /tmp/.config/dotnet-tools.json"
}

verify_installation() {
    echo "🔍 Verifying FAKE installation..."
    
    if command -v fake >/dev/null 2>&1; then
        echo "✅ FAKE installed successfully"
        fake --version
        return 0
    else
        echo "❌ FAKE installation failed"
        return 1
    fi
}

# Main installation flow
main() {
    validate_environment
    install_fake
    create_build_template
    create_paket_dependencies
    create_build_scripts
    create_dotnet_tools_manifest
    verify_installation
    
    echo ""
    echo "🏗️ FAKE F# build system is ready!"
    echo ""
    echo "🔧 Configuration:"
    echo "   • Template created: ${CREATE_TEMPLATE}"
    echo "   • Paket integration: ${ENABLE_PAKET_INTEGRATION}"
    echo "   • .NET integration: ${ENABLE_DOTNET_INTEGRATION}"
    echo "   • Build targets: ${INCLUDE_TARGETS}"
    echo ""
    echo "📖 Quick start:"
    echo "   • fake build                     - Run default build"
    echo "   • fake build --target Clean     - Run specific target"
    echo "   • fake build --list             - List available targets"
    echo ""
    echo "📁 Files created in /tmp/ (copy to your project):"
    echo "   • build.fsx                      - Main build script"
    echo "   • build.sh / build.cmd           - Helper scripts"
    echo "   • .config/dotnet-tools.json      - Tools manifest"
    if [ "${ENABLE_PAKET_INTEGRATION}" = "true" ]; then
        echo "   • paket.dependencies.fake        - FAKE dependencies"
    fi
    echo ""
    echo "💡 Copy these files to your project root and customize as needed"
}

main "$@"