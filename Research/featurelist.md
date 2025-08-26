# F# .NET Devcontainer Features List

## Core F# Development Features

### 1. ionide (F# Language Support)
**Purpose**: Complete F# development environment for VS Code
- **Components**:
  - Ionide-fsharp extension (main F# language server)
  - Ionide-paket extension (Paket integration)
  - Ionide-fake extension (FAKE build system integration)
- **Options**:
  - `enableFSAC`: Enable F# Analyzer & Compiler service (default: true)
  - `enableTooltips`: Enable hover tooltips (default: true)
  - `enableLinting`: Enable F# linting (default: true)
  - `enableCodeLens`: Enable code lens features (default: true)
- **Implementation**: VS Code extension installation + configuration
- **Dependencies**: .NET SDK
- **Version**: Latest stable release from VS Code marketplace

### 2. fantomas (F# Code Formatter)
**Purpose**: Automated F# source code formatting
- **Components**:
  - Fantomas .NET tool installation
  - EditorConfig integration
  - Format-on-save configuration
- **Options**:
  - `version`: Fantomas version (default: "latest")
  - `enableEditorConfig`: Use .editorconfig settings (default: true)
  - `formatOnSave`: Auto-format on file save (default: true)
  - `indentSize`: Indentation size (default: 4)
  - `maxLineLength`: Maximum line length (default: 120)
- **Implementation**: `dotnet tool install fantomas`
- **Configuration**: .editorconfig and VS Code settings
- **Version**: 7.0.3 (latest stable)

### 3. paket (Dependency Manager)
**Purpose**: Alternative .NET package manager with precise dependency control
- **Components**:
  - Paket .NET tool installation
  - Paket bootstrapper setup
  - Integration with project templates
- **Options**:
  - `version`: Paket version (default: "latest")
  - `enableAutoRestore`: Auto-restore on build (default: true)
  - `createBootstrapper`: Include paket.bootstrapper.exe (default: false)
  - `initializeRepo`: Run paket init on container creation (default: false)
- **Implementation**: `dotnet tool install paket`
- **Dependencies**: .NET SDK
- **Version**: Latest stable from NuGet

### 4. fake (F# Build System)
**Purpose**: F# domain-specific language for build tasks and automation
- **Components**:
  - FAKE .NET tool installation
  - Build script templates
  - Integration with common build tasks
- **Options**:
  - `version`: FAKE version (default: "latest")
  - `createTemplate`: Generate sample build.fsx (default: true)
  - `enableModules`: Include common FAKE modules (default: true)
  - `includeTargets`: Predefined build targets (default: ["Clean", "Build", "Test"])
- **Implementation**: `dotnet tool install fake-cli`
- **Dependencies**: .NET SDK
- **Version**: Latest stable from NuGet

### 5. aspnet-core (ASP.NET Core for F#)
**Purpose**: ASP.NET Core web development support for F# applications
- **Components**:
  - ASP.NET Core project templates for F#
  - Giraffe web framework integration
  - Saturn framework support
  - Web API and MVC templates
- **Options**:
  - `framework`: Web framework choice ("giraffe" | "saturn" | "minimal" | "mvc")
  - `includeSwagger`: Install Swagger/OpenAPI tools (default: true)
  - `includeAuth`: Add authentication scaffolding (default: false)
  - `enableHotReload`: Configure hot reload for development (default: true)
  - `includeDocker`: Add Dockerfile for containerization (default: false)
- **Implementation**: `dotnet new` templates + NuGet packages
- **Dependencies**: .NET SDK, ASP.NET Core runtime
- **Version**: Latest stable ASP.NET Core release

### 6. safe-stack (SAFE Stack Full-Stack F#)
**Purpose**: Complete full-stack F# web application development with SAFE Stack
- **Components**:
  - SAFE Stack template installation
  - Saturn (Server) + Azure (Cloud) + Fable (Client) + Elmish (UI)
  - Webpack configuration for client bundling
  - Node.js tooling for client-side development
- **Options**:
  - `template`: SAFE template variant ("minimal" | "default" | "fulma" | "daisyui")
  - `includeAuth`: Add authentication (Auth0/Azure AD) (default: false)
  - `includeDatabase`: Database provider ("none" | "litedb" | "postgres" | "sqlserver")
  - `clientPackageManager`: Client package manager ("npm" | "yarn" | "pnpm")
  - `enableSSR`: Server-side rendering support (default: false)
  - `includeTailwind`: Include Tailwind CSS (default: false)
  - `deployTarget`: Deployment target ("azure" | "docker" | "none")
- **Implementation**: SAFE template + npm toolchain setup
- **Dependencies**: .NET SDK, Node.js, SAFE CLI
- **Version**: Latest SAFE Stack template release

### 7. opencode-cli (AI Code Assistant)
**Purpose**: Integration with opencode.ai Claude-powered development assistant
- **Components**:
  - OpenCode CLI tool installation
  - Authentication setup
  - VS Code integration
- **Options**:
  - `version`: OpenCode version (default: "latest")
  - `enableVSCodeIntegration`: Install VS Code extension (default: true)
  - `autoAuthenticate`: Prompt for auth on startup (default: false)
- **Implementation**: npm/binary installation
- **Dependencies**: Node.js or standalone binary
- **Version**: Latest from opencode.ai releases

## Supporting Development Features

### 8. fsharp-testing (Testing Framework Setup)
**Purpose**: Comprehensive F# testing environment
- **Components**:
  - Test framework selection (xUnit, NUnit, MSTest)
  - Test runner configuration
  - Coverage tools setup
- **Options**:
  - `framework`: Test framework choice ("xunit" | "nunit" | "mstest")
  - `includeCoverage`: Install coverage tools (default: true)
  - `enableReportGenerator`: HTML coverage reports (default: true)
  - `testTemplate`: Generate sample test project (default: true)
- **Implementation**: Template generation + tool installation
- **Dependencies**: .NET SDK

### 9. dotnet-tools (Common .NET Tools)
**Purpose**: Essential .NET CLI tools for F# development
- **Components**:
  - EF Core tools
  - Outdated package checker
  - Template engines
- **Options**:
  - `includeEF`: Entity Framework tools (default: false)
  - `includeOutdated`: Package update checker (default: true)
  - `includeTemplates`: Additional project templates (default: true)
  - `globalTools`: Custom global tools list (default: [])
- **Implementation**: `dotnet tool install` commands
- **Dependencies**: .NET SDK

### 10. fsharp-interactive (F# REPL & Notebooks)
**Purpose**: Advanced F# Interactive development environment with notebook and scripting support
- **Components**:
  - .NET Interactive kernel installation and configuration
  - Enhanced F# Interactive (FSI) setup with optimized settings
  - Polyglot notebook support for multi-language development
  - Load script generation for project dependencies
  - Package management workflow optimization
- **Options**:
  - `enableNotebooks`: Install .NET Interactive kernel for Jupyter/VS Code (default: true)
  - `enablePolyglot`: Support multi-language notebooks (C#, F#, PowerShell, etc.) (default: true)
  - `generateLoadScripts`: Auto-generate .fsx load scripts for projects (default: true)
  - `optimizeFSI`: Apply performance and usability FSI settings (default: true)
  - `enableDebugging`: Configure FSI debugging support (default: true)
  - `packageManager`: Package loading strategy ("nuget" | "paket") (default: "nuget")
  - `enableShebang`: Support executable .fsx scripts with shebang (default: true)
- **Implementation**: 
  - `dotnet tool install -g Microsoft.dotnet-interactive`
  - FSI configuration files and load scripts
  - VS Code integration setup
- **Dependencies**: .NET SDK, Ionide
- **Key Features**:
  - Seamless `#r "nuget:"` package loading
  - Multi-language notebook development
  - Project dependency auto-loading
  - Enhanced REPL experience with history and completion
  - Script execution and debugging capabilities

### 11. typescript (TypeScript Development Support)
**Purpose**: TypeScript development environment for F# developers working with Fable and JavaScript interop
- **Components**:
  - TypeScript compiler installation and configuration
  - VS Code TypeScript language service
  - Type definition management (@types packages)
  - ESLint and Prettier integration for code quality
  - Node.js project template support
- **Options**:
  - `version`: TypeScript version (default: "latest")
  - `enableESLint`: Install and configure ESLint (default: true)
  - `enablePrettier`: Install and configure Prettier (default: true)
  - `nodeVersion`: Node.js version for TypeScript projects (default: "18-lts")
  - `packageManager`: Package manager choice ("npm" | "yarn" | "pnpm") (default: "npm")
  - `enableStrict`: Use strict TypeScript configuration (default: true)
  - `includeFableTypes`: Install Fable-specific type definitions (default: true)
  - `configTemplate`: TypeScript config template ("standard" | "fable" | "node" | "react") (default: "fable")
- **Implementation**:
  - `npm install -g typescript`
  - TypeScript configuration templates
  - VS Code extensions and settings
  - Integration with Fable compiler output
- **Dependencies**: Node.js 16+, npm/yarn/pnpm
- **Integration Points**:
  - **Fable Compiler**: Type-safe F# to TypeScript/JavaScript compilation
  - **SAFE Stack**: Client-side type definitions and interop
  - **VS Code**: Enhanced IntelliSense for mixed F#/TypeScript projects
- **Key Features**:
  - Seamless F# to TypeScript interop
  - Type-safe JavaScript library integration
  - Advanced debugging support for compiled F# code
  - Hot reload for TypeScript development
  - Automated type definition management

## Implementation Strategy

### Phase 1: Core Features (Priority: High)
1. **fantomas** - Most mature, widely adopted
2. **ionide** - Essential for F# development
3. **paket** - Already partially implemented

### Phase 2: Web Development (Priority: High)
1. **aspnet-core** - Standard web development
2. **safe-stack** - Full-stack F# development
3. **typescript** - JavaScript interop and Fable support

### Phase 3: Build & Test (Priority: Medium)
1. **fake** - Build automation
2. **fsharp-testing** - Test framework setup

### Phase 4: Enhancement Features (Priority: Low)
1. **opencode-cli** - AI assistant integration
2. **dotnet-tools** - Additional productivity tools
3. **fsharp-interactive** - Enhanced REPL

## Testing Strategy

### Validation Framework
1. **Feature Installation Tests**
   - Verify tool installation succeeds
   - Check version compatibility
   - Validate dependencies resolved

2. **Integration Tests**
   - Create sample F# project
   - Run build/format/test cycle
   - Verify VS Code extensions load

3. **Configuration Tests**
   - Test option combinations
   - Validate configuration files generated
   - Check inter-feature compatibility

### Testing Implementation
```bash
# Basic feature validation
devcontainer features test ./features/src/fantomas
devcontainer features test ./features/src/ionide
devcontainer features test ./features/src/paket
devcontainer features test ./features/src/fake
devcontainer features test ./features/src/aspnet-core
devcontainer features test ./features/src/safe-stack
devcontainer features test ./features/src/typescript

# Template validation with features
devcontainer templates test ./templates/fsharp-dotnet
devcontainer templates test ./templates/fsharp-web
```

### Continuous Integration
- GitHub Actions workflow for feature testing
- Matrix testing across .NET versions (6.0, 7.0, 8.0)
- Compatibility testing between feature combinations

## File Structure
```
features/
├── src/
│   ├── fantomas/
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
│   ├── ionide/
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
│   ├── paket/
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
│   ├── fake/
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
│   ├── aspnet-core/
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
│   ├── safe-stack/
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
│   ├── typescript/
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
│   ├── opencode-cli/
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
│   ├── fsharp-testing/
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
│   ├── dotnet-tools/
│   │   ├── devcontainer-feature.json
│   │   └── install.sh
│   └── fsharp-interactive/
│       ├── devcontainer-feature.json
│       └── install.sh
└── test/
    ├── fantomas/
    ├── ionide/
    ├── aspnet-core/
    ├── safe-stack/
    ├── typescript/
    └── [other feature tests]
```

## Quality Checklist
- [ ] Each feature has proper devcontainer-feature.json metadata
- [ ] Install scripts are idempotent and handle errors gracefully
- [ ] Options are properly validated and documented
- [ ] Features work independently and in combination
- [ ] VS Code integration configured correctly
- [ ] Documentation includes usage examples
- [ ] Version pinning strategy implemented
- [ ] Security considerations addressed (no hardcoded secrets)

## Version Management
- Pin specific tool versions for reproducibility
- Regular updates based on upstream releases
- Compatibility matrix documentation
- Semantic versioning for feature releases

## Publication Strategy
1. Develop and test features locally
2. Validate with real F# projects
3. Publish to GitHub Container Registry
4. Submit to devcontainer features registry
5. Maintain documentation and examples