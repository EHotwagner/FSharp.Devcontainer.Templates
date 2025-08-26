# F# Devcontainer Templates

A comprehensive collection of **devcontainer features** and **templates** for modern .NET and F# development. This repository provides everything you need to set up productive F# development environments with all the tools, testing frameworks, and best practices configured out of the box.

> 🏠 **Repository**: [EHotwagner/FSharp.Devcontainer.Templates](https://github.com/EHotwagner/FSharp.Devcontainer.Templates)

## 🚀 Quick Start

### Using Templates (Recommended)

Create a new F# project in seconds:

```bash
# Minimal F# console application
devcontainer templates apply ghcr.io/ehotwagner/fsharp.devcontainer.templates/fsharp-minimal

# ASP.NET Core F# web application  
devcontainer templates apply ghcr.io/ehotwagner/fsharp.devcontainer.templates/aspnet-fsharp

# Full-featured F# development environment
devcontainer templates apply ghcr.io/ehotwagner/fsharp.devcontainer.templates/fsharp-full
```

### Using Individual Features

Add specific tools to your existing devcontainer:

```json
{
  "features": {
    "ghcr.io/ehotwagner/fsharp.devcontainer.templates/features/fantomas:1": {},
    "ghcr.io/ehotwagner/fsharp.devcontainer.templates/features/paket:1": {},
    "ghcr.io/ehotwagner/fsharp.devcontainer.templates/features/fake:1": {}
  }
}
```

## 📦 What's Included

### 🎯 Templates

Three ready-to-use project templates:

| Template | Description | Best For |
|----------|-------------|----------|
| **[fsharp-minimal](templates/src/fsharp-minimal/)** | Lightweight F# console app | Learning, prototyping, utilities |
| **[aspnet-fsharp](templates/src/aspnet-fsharp/)** | F# web development with Giraffe | Web APIs, web applications |
| **[fsharp-full](templates/src/fsharp-full/)** | Complete F# dev environment | Complex projects, teams |

### 🔧 Features

Eight production-ready development tools:

| Feature | Description | Key Capabilities |
|---------|-------------|------------------|
| **[ionide](features/src/ionide/)** | F# language support | LSP, IntelliSense, debugging |
| **[fantomas](features/src/fantomas/)** | F# code formatter | Auto-formatting, style enforcement |
| **[paket](features/src/paket/)** | Package manager | Dependency management, reproducible builds |
| **[fake](features/src/fake/)** | Build automation | Build scripts, CI/CD integration |
| **[aspnet-core](features/src/aspnet-core/)** | Web development | HTTPS certs, EF tools, Giraffe |
| **[fsharp-testing](features/src/fsharp-testing/)** | Testing frameworks | xUnit, FsUnit, coverage analysis |
| **[typescript](features/src/typescript/)** | Frontend development | TS compiler, ESLint, Fable types |
| **[opencode-cli](features/src/opencode-cli/)** | AI development assistant | Code generation, intelligent assistance |

## 🏗️ Templates Overview

### F# Minimal Template
Perfect for getting started with F#:
```bash
mkdir my-fsharp-app
cd my-fsharp-app
devcontainer templates apply ghcr.io/ehotwagner/fsharp.devcontainer.templates/fsharp-minimal

# Generates:
# ├── src/
# │   ├── App.fsproj
# │   └── Program.fs
# ├── .devcontainer/
# └── .gitignore
```

**Features included**: Ionide + optional Fantomas, Paket, OpenCode

### ASP.NET Core F# Template
Full-stack web development:
```bash
mkdir my-web-app
cd my-web-app
devcontainer templates apply ghcr.io/ehotwagner/fsharp.devcontainer.templates/aspnet-fsharp

# Generates:
# ├── src/
# │   ├── WebApp.fsproj
# │   ├── Models.fs
# │   ├── Views.fs (Giraffe.ViewEngine)
# │   ├── Handlers.fs
# │   └── Program.fs
# ├── .devcontainer/
# └── appsettings.json
```

**Features included**: ASP.NET Core + Ionide + Giraffe + optional tools  
**Ports**: 5000 (HTTP), 5001 (HTTPS)  
**Includes**: OpenAPI/Swagger, Bootstrap UI, REST endpoints

### F# Full Development Template
Enterprise-ready development environment:
```bash
mkdir my-enterprise-app
cd my-enterprise-app
devcontainer templates apply ghcr.io/ehotwagner/fsharp.devcontainer.templates/fsharp-full

# Generates:
# ├── src/
# │   ├── App/           # Console application
# │   ├── Library/       # Shared business logic
# │   └── WebApp/        # Web application
# ├── tests/
# │   ├── App.Tests/
# │   ├── Library.Tests/
# │   └── WebApp.Tests/
# ├── build.fsx          # FAKE build script
# ├── paket.dependencies # Package management
# └── FSharpFullStack.sln
```

**Features included**: All 8 features with intelligent conditional installation  
**Project types**: Console, Library, Web, Mixed (all)  
**Build systems**: FAKE, .NET CLI  
**Package managers**: Paket, NuGet

## ⚙️ Template Configuration

All templates support extensive customization through options:

### F# Minimal Options
```bash
devcontainer templates apply ghcr.io/ehotwagner/fsharp.devcontainer.templates/fsharp-minimal \
  --option dotnetVersion=9.0 \
  --option includeFantomas=true \
  --option includePaket=false
```

### ASP.NET F# Options
```bash
devcontainer templates apply ghcr.io/ehotwagner/fsharp.devcontainer.templates/aspnet-fsharp \
  --option webFramework=giraffe \
  --option includeDatabase=true \
  --option includeOpenApi=true
```

### F# Full Options
```bash
devcontainer templates apply ghcr.io/ehotwagner/fsharp.devcontainer.templates/fsharp-full \
  --option projectType=mixed \
  --option buildSystem=fake \
  --option packageManager=paket \
  --option includeTypeScript=true
```

## 🔧 Feature Usage

### Individual Feature Installation

Add any feature to your existing devcontainer:

```json
{
  "features": {
    "ghcr.io/ehotwagner/fsharp.devcontainer.templates/features/fantomas:1": {
      "version": "latest",
      "enableEditorConfig": true
    },
    "ghcr.io/ehotwagner/fsharp.devcontainer.templates/features/paket:1": {
      "autoRestore": true,
      "enableFsiIntegration": true
    }
  }
}
```

### Local Development (Using This Repository)

Reference features locally during development:

```json
{
  "features": {
    "./features/src/fantomas": {},
    "./features/src/paket": {},
    "./features/src/fake": {}
  }
}
```

### Feature Combinations

Common feature combinations for different scenarios:

#### Basic F# Development
```json
{
  "features": {
    "ghcr.io/devcontainers/features/dotnet:2": {"version": "8.0"},
    "ghcr.io/ehotwagner/fsharp.devcontainer.templates/features/ionide:1": {},
    "ghcr.io/ehotwagner/fsharp.devcontainer.templates/features/fantomas:1": {}
  }
}
```

#### F# Web Development
```json
{
  "features": {
    "ghcr.io/devcontainers/features/dotnet:2": {"version": "8.0"},
    "ghcr.io/ehotwagner/fsharp.devcontainer.templates/features/aspnet-core:1": {"enableHttps": true},
    "ghcr.io/ehotwagner/fsharp.devcontainer.templates/features/ionide:1": {},
    "ghcr.io/ehotwagner/fsharp.devcontainer.templates/features/fantomas:1": {}
  }
}
```

#### Enterprise F# Development
```json
{
  "features": {
    "ghcr.io/devcontainers/features/dotnet:2": {"version": "8.0"},
    "ghcr.io/ehotwagner/fsharp.devcontainer.templates/features/ionide:1": {},
    "ghcr.io/ehotwagner/fsharp.devcontainer.templates/features/fantomas:1": {},
    "ghcr.io/ehotwagner/fsharp.devcontainer.templates/features/paket:1": {"autoRestore": true},
    "ghcr.io/ehotwagner/fsharp.devcontainer.templates/features/fake:1": {"installTemplates": true},
    "ghcr.io/ehotwagner/fsharp.devcontainer.templates/features/fsharp-testing:1": {},
    "ghcr.io/ehotwagner/fsharp.devcontainer.templates/features/opencode-cli:1": {}
  }
}
```

## 📚 Examples and Workflows

### Creating a New F# Project

1. **Start with a template**:
   ```bash
   mkdir my-project && cd my-project
   devcontainer templates apply ghcr.io/ehotwagner/fsharp.devcontainer.templates/fsharp-minimal
   ```

2. **Open in VS Code**:
   ```bash
   code .
   # VS Code will prompt to reopen in container
   ```

3. **Start developing**:
   ```bash
   # In the devcontainer terminal
   cd src
   dotnet run
   ```

### Adding Features to Existing Projects

1. **Edit `.devcontainer/devcontainer.json`**:
   ```json
   {
     "features": {
       "ghcr.io/ehotwagner/fsharp.devcontainer.templates/features/paket:1": {},
       "ghcr.io/ehotwagner/fsharp.devcontainer.templates/features/fake:1": {}
     }
   }
   ```

2. **Rebuild container**:
   ```bash
   # Command Palette: Dev Containers: Rebuild Container
   ```

### Testing and Quality Assurance

All templates include comprehensive testing setups:

```bash
# Run tests
dotnet test

# Format code
fantomas src/ tests/

# Build with FAKE
fake build

# Package management with Paket
paket install
paket update
```

## 🛠️ Development and Contributing

### Repository Structure

```
/
├── features/src/           # 8 reusable devcontainer features
│   ├── aspnet-core/       # Web development setup
│   ├── fantomas/          # F# code formatter
│   ├── fake/              # Build automation
│   ├── fsharp-testing/    # Testing frameworks
│   ├── ionide/            # F# language support
│   ├── opencode-cli/      # AI development assistant
│   ├── paket/             # Package management
│   └── typescript/        # Frontend development
├── templates/src/          # 3 project templates
│   ├── fsharp-minimal/    # Minimal F# console
│   ├── aspnet-fsharp/     # F# web application
│   └── fsharp-full/       # Full development environment
├── devcontainer-collection.json  # Registry metadata
└── README.md              # This file
```

### Testing Features

```bash
# Test individual features
devcontainer features test ./features/src/fantomas

# Test all features
find features/src -name "devcontainer-feature.json" -exec dirname {} \; | \
  xargs -I {} devcontainer features test {}

# Validate JSON schemas
find . -name "*.json" -exec python3 -m json.tool {} \;
```

### Publishing

```bash
# Publish features to GitHub Container Registry
devcontainer features publish ./features/src/* oci://ghcr.io/ehotwagner/fsharp.devcontainer.templates/features

# Publish templates to GitHub Container Registry  
devcontainer templates publish ./templates/src/* oci://ghcr.io/ehotwagner/fsharp.devcontainer.templates
```

### Contributing Guidelines

1. **Follow the existing patterns**:
   - Features: `install.sh` + `devcontainer-feature.json`
   - Templates: `devcontainer-template.json` + `.devcontainer/` + `post-create.sh`

2. **Test thoroughly**:
   - Validate JSON schemas
   - Test feature installation
   - Verify template generation

3. **Update documentation**:
   - Feature options and usage
   - Template capabilities and examples
   - Integration patterns

4. **Version consistently**:
   - Semantic versioning for features
   - Coordinated releases for templates

## 🔍 Advanced Usage

### Custom Feature Development

Create your own features following the pattern:

```bash
mkdir features/src/my-feature
cd features/src/my-feature

# Create metadata
cat > devcontainer-feature.json << 'EOF'
{
  "id": "my-feature",
  "version": "1.0.0",
  "name": "My Custom Feature",
  "description": "Custom development tool",
  "options": {
    "version": {
      "type": "string",
      "default": "latest"
    }
  }
}
EOF

# Create installation script
cat > install.sh << 'EOF'
#!/bin/bash
set -euo pipefail

VERSION=${VERSION:-"latest"}
echo "Installing my-feature version $VERSION..."
# Installation logic here
EOF

chmod +x install.sh
```

### Template Customization

Modify templates for your organization:

1. **Fork this repository**
2. **Customize templates**:
   - Update company-specific configurations
   - Add your preferred libraries and frameworks
   - Modify VS Code settings and extensions
3. **Publish to your registry**:
   ```bash
   devcontainer templates publish ./templates/src/* oci://ghcr.io/ehotwagner/fsharp.devcontainer.templates
   ```

### CI/CD Integration

Use templates in continuous integration:

```yaml
# .github/workflows/test.yml
name: Test F# Application
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup devcontainer
        uses: devcontainers/ci@v0.3
        with:
          imageName: ghcr.io/ehotwagner/fsharp.devcontainer.templates
          runCmd: |
            dotnet test
            fake build
```

## 📊 Compatibility and Requirements

### Supported Platforms
- ✅ **Linux** (Ubuntu 20.04+)
- ✅ **macOS** (Intel and Apple Silicon)
- ✅ **Windows** (WSL2)

### Dependencies
- **Docker** or **Podman**
- **VS Code** with Dev Containers extension
- **DevContainer CLI** (optional, for command-line usage)

### .NET Versions
- ✅ **.NET 8.0** (default, LTS)
- ✅ **.NET 9.0** (current)
- ✅ **Future versions** (configurable)

## 📈 Status and Roadmap

### Current Status
- ✅ **8 production-ready features** with comprehensive testing
- ✅ **3 complete templates** covering common F# scenarios
- ✅ **Local development** and testing infrastructure
- ✅ **Documentation** and usage examples

### Upcoming Features
- 🔄 **GitHub Actions** for automated testing and publishing
- 🔄 **Additional templates**: F# libraries, microservices, desktop apps
- 🔄 **Enhanced features**: Database tools, cloud deployment, monitoring
- 🔄 **Performance optimizations**: Faster builds, smaller containers

### Community
- 📖 **Documentation**: Comprehensive guides and examples
- 🧪 **Testing**: Automated validation and quality assurance
- 🤝 **Contributing**: Clear guidelines and development workflows
- 📦 **Publishing**: Registry distribution and versioning

## 🤝 Support and Community

### Getting Help
- 📚 **Documentation**: Check the detailed guides in each feature/template directory
- 🐛 **Issues**: Report bugs and request features on GitHub Issues
- 💬 **Discussions**: Ask questions in GitHub Discussions

### Contributing
We welcome contributions! Please see:
- [Feature development guidelines](features/README.md)
- [Template creation patterns](templates/README.md)
- [Testing and validation procedures](template-validation-results.md)

### License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Ready to start developing with F#?** 🚀

```bash
mkdir my-fsharp-project
cd my-fsharp-project
devcontainer templates apply ghcr.io/ehotwagner/fsharp.devcontainer.templates/fsharp-minimal
code .
```

*Happy F# coding!* 🎉