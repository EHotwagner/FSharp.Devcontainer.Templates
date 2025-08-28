# Agentic CLI Feature for Devcontainers

## Overview
Added Agentic CLI as a devcontainer feature to provide modular AI agent capabilities within development containers.

## Feature Details

### Location
- `features/src/agentic-cli/`
  - `devcontainer-feature.json` - Feature metadata and options
  - `install.sh` - Installation script

### Options
- `version` - Version/branch to install (default: "latest")
- `installBun` - Install Bun runtime (default: true)
- `addToPath` - Add to system PATH (default: true)
- `createConfig` - Create basic configuration (default: true)

### Installation Process
1. Installs Bun runtime if needed
2. Clones Agentic repository from GitHub
3. Builds the CLI using Bun
4. Installs binary to `~/.local/bin`
5. Configures PATH in shell profiles
6. Creates basic Agentic configuration

## Template Integration

### Templates Updated
1. **aspnet-fsharp** - Added as optional feature (`includeAgentic` option, default: true)
2. **fsharp-full** - Added as included feature (no option needed)
3. **fsharp-minimal** - Added as optional feature (`includeAgentic` option, default: false)

### Configuration
- ASP.NET F# template: Enabled by default for web development workflows
- Full F# template: Always included for comprehensive development environment
- Minimal F# template: Optional for users who want lightweight setup

## Available Commands
Once installed, users can use:
- `agentic init` - Initialize project
- `agentic status` - Check status
- `agentic pull` - Pull updates
- `agentic plan <description>` - Plan tasks
- `agentic research <query>` - Research topics

## Configuration Files
- Config: `~/.agentic/config.json`
- Thoughts: `~/.agentic/thoughts/`

## Validation
- ✅ All JSON files validated
- ✅ Install script syntax verified
- ✅ Executable permissions set
- ✅ Feature properly integrated into all templates