# Devcontainer Features for .NET/F#

This directory contains reusable devcontainer features for .NET and F# development.

## Available Features

### 🎨 fantomas
F# code formatter with configurable options.
```json
"features": {
  "./features/src/fantomas": {
    "version": "latest",
    "enableEditorConfig": true
  }
}
```

### 📦 paket
Alternative package manager for F# projects.
```json
"features": {
  "./features/src/paket": {
    "version": "latest", 
    "createTemplate": true
  }
}
```

### 🧪 fsharp-testing
Complete testing setup with xUnit/Expecto, coverage tools, and property-based testing.
```json
"features": {
  "./features/src/fsharp-testing": {
    "framework": "xunit",
    "includeCoverage": true,
    "includePropertyBasedTesting": false
  }
}
```

## Template Integration Examples

### Basic F# Template
```json
{
  "features": {
    "ghcr.io/devcontainers/features/dotnet:2": {"version": "8.0"},
    "./features/src/fantomas": {}
  }
}
```

### Full F# Web Development
```json
{
  "features": {
    "ghcr.io/devcontainers/features/dotnet:2": {"version": "8.0"},
    "./features/src/fantomas": {"enableEditorConfig": true},
    "./features/src/paket": {"createTemplate": true},
    "./features/src/fsharp-testing": {
      "framework": "both",
      "includeCoverage": true
    }
  }
}
```

## Publishing Features

Each feature can be published separately:

1. **As individual repos** (for maximum discoverability):
   ```bash
   # Create separate repo for each feature
   gh repo create dotnet-fantomas-feature
   # Push feature source to repo
   # Users reference: "ghcr.io/user/dotnet-fantomas-feature"
   ```

2. **As collection** (for related features):
   ```bash
   devcontainer features publish ./features/src/* oci://ghcr.io/user/dotnet-features
   # Users reference: "ghcr.io/user/dotnet-features/fantomas"
   ```

## Development Workflow

1. Create feature in `features/src/feature-name/`
2. Test locally: `devcontainer features test ./features/src/feature-name`
3. Publish: `devcontainer features publish ./features/src/feature-name`
4. Reference in templates or user devcontainer.json

## Feature Dependencies

Features automatically handle dependencies:
- `fantomas` installs after `.NET`
- `paket` installs after `.NET` 
- `fsharp-testing` depends on `.NET`

Users can override installation order if needed with `overrideFeatureInstallOrder`.