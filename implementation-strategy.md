# F# Devcontainer Features Implementation & Testing Strategy

## Implementation Approach

### Development Principles
1. **Modularity**: Each feature is self-contained and combinable
2. **Reproducibility**: Pin versions, deterministic installations
3. **Security**: No hardcoded secrets, validate inputs, run as non-root
4. **Performance**: Layer-aware Dockerfile caching, parallel installations
5. **Maintainability**: Clear documentation, conventional structure

### Feature Development Workflow

#### 1. Feature Scaffolding
```bash
# Create feature directory structure
mkdir -p features/src/{feature-name}/
mkdir -p features/test/{feature-name}/

# Generate base files
touch features/src/{feature-name}/devcontainer-feature.json
touch features/src/{feature-name}/install.sh
chmod +x features/src/{feature-name}/install.sh
```

#### 2. Feature Metadata Template
```json
{
  "id": "feature-name",
  "version": "1.0.0",
  "name": "Feature Display Name",
  "description": "Feature description",
  "documentationURL": "https://github.com/your-org/features/tree/main/src/feature-name",
  "licenseURL": "https://github.com/your-org/features/blob/main/LICENSE",
  "options": {
    "version": {
      "type": "string",
      "proposals": ["latest", "7.0.3", "6.2.1"],
      "default": "latest",
      "description": "Tool version to install"
    }
  },
  "installsAfter": ["ghcr.io/devcontainers/features/dotnet:2"],
  "dependsOn": {
    "ghcr.io/devcontainers/features/dotnet": {}
  }
}
```

#### 3. Install Script Template
```bash
#!/bin/bash
set -euo pipefail

# Feature: {FEATURE_NAME}
# Version: {VERSION}
# Description: {DESCRIPTION}

# Parse feature options
VERSION=${VERSION:-"latest"}
FEATURE_NAME="feature-name"

echo "Installing ${FEATURE_NAME} version ${VERSION}..."

# Validation functions
validate_user() {
    if [[ $EUID -eq 0 ]]; then
        echo "This script should not be run as root"
        exit 1
    fi
}

install_tool() {
    case "$VERSION" in
        "latest")
            dotnet tool install -g "$FEATURE_NAME"
            ;;
        *)
            dotnet tool install -g "$FEATURE_NAME" --version "$VERSION"
            ;;
    esac
}

configure_tool() {
    # Tool-specific configuration
    echo "Configuring ${FEATURE_NAME}..."
}

# Main installation flow
main() {
    validate_user
    install_tool
    configure_tool
    echo "${FEATURE_NAME} installation completed successfully"
}

main "$@"
```

## Testing Strategy

### 1. Unit Testing (Feature-Level)

#### Test Structure
```
features/test/{feature-name}/
├── test.sh                    # Main test script
├── scenarios/
│   ├── default.sh            # Default options test
│   ├── custom-version.sh     # Version-specific test
│   └── combinations.sh       # Multi-feature test
└── fixtures/
    ├── sample-project/       # Test F# project
    └── expected-output/      # Expected results
```

#### Test Implementation Template
```bash
#!/bin/bash
# Test script for {feature-name}

set -euo pipefail
source dev-container-features-test-lib

# Test: Default installation
check "default-install" bash -c "
    echo 'Testing default installation...'
    # Verify tool is installed
    command -v tool-name
    # Verify version
    tool-name --version
"

# Test: Custom version
check "custom-version" bash -c "
    echo 'Testing custom version installation...'
    # Version-specific checks
"

# Test: VS Code integration
check "vscode-integration" bash -c "
    echo 'Testing VS Code integration...'
    # Check extensions are configured
    grep 'extension-id' ~/.vscode-server/data/Machine/settings.json || true
"

# Test: Sample project workflow
check "sample-workflow" bash -c "
    echo 'Testing with sample F# project...'
    cd /tmp
    dotnet new console -lang F# -n TestApp
    cd TestApp
    # Tool-specific workflow test
    dotnet build
"

reportResults
```

### 2. Integration Testing

#### Template Testing
```bash
# Test template with specific feature combinations
devcontainer templates test ./templates/fsharp-dotnet \
  --features='
    {
      "./features/src/fantomas": {"version": "7.0.3"},
      "./features/src/ionide": {},
      "./features/src/paket": {"enableAutoRestore": true}
    }
  '
```

#### Cross-Feature Compatibility Matrix
```yaml
# .github/workflows/test-matrix.yml
strategy:
  matrix:
    dotnet-version: ["6.0", "7.0", "8.0"]
    feature-combination:
      - "ionide+fantomas"
      - "ionide+paket+fake"
      - "ionide+fantomas+paket+fake"
      - "all-features"
    base-image:
      - "mcr.microsoft.com/dotnet/sdk:8.0"
      - "mcr.microsoft.com/vscode/devcontainers/dotnet:8.0"
```

### 3. Performance Testing

#### Build Time Monitoring
```bash
#!/bin/bash
# Performance test script

start_time=$(date +%s)

# Build container with features
devcontainer build .

end_time=$(date +%s)
build_duration=$((end_time - start_time))

echo "Build completed in ${build_duration} seconds"

# Test container size
container_size=$(docker images --format "table {{.Repository}}\t{{.Size}}" | grep test-container)
echo "Container size: ${container_size}"
```

#### Startup Time Testing
```bash
# Test feature installation time
time devcontainer features test ./features/src/fantomas
time devcontainer features test ./features/src/ionide
```

### 4. Automated Testing Pipeline

#### GitHub Actions Workflow
```yaml
name: Test F# Features

on:
  push:
    paths: ['features/**']
  pull_request:
    paths: ['features/**']

jobs:
  test-features:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        feature: [fantomas, ionide, paket, fake, aspnet-core, safe-stack, typescript, opencode-cli]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Install devcontainer CLI
        run: npm install -g @devcontainers/cli
        
      - name: Test feature
        run: devcontainer features test ./features/src/${{ matrix.feature }}
        
      - name: Test feature combinations
        run: |
          devcontainer features test \
            --features '{"./features/src/fantomas": {}, "./features/src/${{ matrix.feature }}": {}}' \
            ./features/test/combinations/
```

## Quality Assurance

### 1. Code Quality Checks

#### Shell Script Linting
```bash
# Install shellcheck
sudo apt-get install shellcheck

# Lint all install scripts
find features/src -name "install.sh" -exec shellcheck {} \;
```

#### JSON Validation
```bash
# Validate feature metadata
find features/src -name "devcontainer-feature.json" -exec jq empty {} \;
```

### 2. Security Scanning

#### Dependency Scanning
```bash
# Scan for known vulnerabilities in installed tools
# Implement custom scanner for .NET tools
dotnet list package --vulnerable --include-transitive
```

#### Secret Detection
```bash
# Scan for hardcoded secrets
git-secrets --scan features/
```

### 3. Documentation Validation

#### README Generation
```bash
# Auto-generate feature documentation
generate-feature-docs() {
    for feature in features/src/*/; do
        feature_name=$(basename "$feature")
        jq -r '.description' "$feature/devcontainer-feature.json" > "$feature/README.md"
    done
}
```

## Implementation Timeline

### Week 1-2: Foundation
- [ ] Set up feature development environment
- [ ] Implement fantomas feature (most stable)
- [ ] Create testing framework
- [ ] Establish CI/CD pipeline

### Week 3-4: Core Features
- [ ] Implement ionide feature
- [ ] Enhance paket feature (already exists)
- [ ] Add comprehensive test coverage
- [ ] Performance optimization

### Week 5-7: Web Development Features
- [ ] Implement aspnet-core feature
- [ ] Add typescript feature (Node.js + TypeScript toolchain)
- [ ] Add safe-stack feature (complex full-stack)
- [ ] Node.js toolchain integration for SAFE + TypeScript
- [ ] Web project template validation with F#/TypeScript interop

### Week 8-9: Build & Test Features
- [ ] Implement fake feature
- [ ] Add fsharp-testing feature
- [ ] Cross-feature integration testing (including TypeScript)
- [ ] Documentation completion

### Week 10-11: Enhancement & Polish
- [ ] Implement opencode-cli integration
- [ ] Add dotnet-tools feature
- [ ] Performance benchmarking (including TypeScript compilation)
- [ ] Security audit

## Monitoring & Maintenance

### 1. Dependency Updates
```bash
# Automated dependency checking
check-updates() {
    # Check for new .NET SDK releases
    curl -s https://api.nuget.org/v3-flatcontainer/microsoft.netcore.app/index.json
    
    # Check tool updates
    dotnet tool list -g --outdated
}
```

### 2. Usage Analytics
- Track feature adoption through GitHub telemetry
- Monitor build failure rates
- Collect user feedback through issues

### 3. Release Management
- Semantic versioning for features
- Automated changelog generation
- Coordinated releases with dependency updates

## Risk Mitigation

### 1. Breaking Changes
- Version pinning strategy
- Backward compatibility testing
- Migration guides for major updates

### 2. External Dependencies
- Fallback mirror repositories
- Offline installation packages
- Dependency vendoring for critical tools

### 3. Security Vulnerabilities
- Regular security scanning
- Rapid response procedures
- Security advisory publication

## Web Development Feature Implementation Notes

### ASP.NET Core Feature
```bash
# Feature installation approach
install_aspnet_templates() {
    # Install ASP.NET Core templates for F#
    dotnet new install Microsoft.AspNetCore.SPA.ProjectTemplates
    
    # Install popular F# web frameworks
    case "$FRAMEWORK" in
        "giraffe")
            dotnet add package Giraffe
            ;;
        "saturn")
            dotnet add package Saturn
            ;;
        "minimal")
            # Use built-in minimal APIs
            ;;
    esac
}

configure_web_development() {
    # Configure hot reload
    if [[ "$ENABLE_HOT_RELOAD" == "true" ]]; then
        echo "dotnet watch run" >> .vscode/tasks.json
    fi
    
    # Add Swagger if requested
    if [[ "$INCLUDE_SWAGGER" == "true" ]]; then
        dotnet add package Swashbuckle.AspNetCore
    fi
}
```

### SAFE Stack Feature
```bash
# Complex multi-tool installation
install_safe_stack() {
    # Install .NET components
    dotnet tool install -g SAFE.Template
    
    # Install Node.js toolchain
    npm install -g webpack webpack-cli webpack-dev-server
    
    # Install Fable compiler
    npm install -g @fable-org/cli
    
    # Create SAFE project template
    case "$TEMPLATE" in
        "minimal")
            safe init --template minimal
            ;;
        "fulma")
            safe init --template fulma
            ;;
        "daisyui")
            safe init --template daisyui
            ;;
    esac
}

configure_safe_development() {
    # Configure client package manager
    case "$CLIENT_PACKAGE_MANAGER" in
        "yarn")
            npm install -g yarn
            ;;
        "pnpm")
            npm install -g pnpm
            ;;
    esac
    
    # Database setup
    if [[ "$INCLUDE_DATABASE" != "none" ]]; then
        setup_database_provider "$INCLUDE_DATABASE"
    fi
}
```

### Testing Strategy for Web Features

#### ASP.NET Core Testing
```bash
# Test web application scaffolding
test_aspnet_core() {
    # Create test project
    dotnet new webapi -lang F# -n TestWebApi
    cd TestWebApi
    
    # Verify build
    dotnet build
    
    # Test endpoint accessibility
    dotnet run &
    sleep 5
    curl -f http://localhost:5000/api/values || exit 1
    pkill -f dotnet
}
```

#### SAFE Stack Testing
```bash
# Test full-stack application
test_safe_stack() {
    # Create SAFE project
    safe init --template minimal TestSafe
    cd TestSafe
    
    # Test server build
    dotnet build src/Server
    
    # Test client build
    npm install
    npm run build
    
    # Integration test
    npm run start &
    sleep 10
    curl -f http://localhost:8080 || exit 1
    pkill -f node
}
```

This comprehensive strategy ensures robust, maintainable, and secure F# devcontainer features with full web development support.