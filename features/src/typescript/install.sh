#!/bin/bash
set -euo pipefail

# Feature: TypeScript Development Support
# Version: 1.0.0
# Description: TypeScript development environment for F# developers

# Parse feature options
TYPESCRIPT_VERSION=${VERSION:-"latest"}
ENABLE_ESLINT=${ENABLEESLINT:-"true"}
ENABLE_PRETTIER=${ENABLEPRETTIER:-"true"}
NODE_VERSION=${NODEVERSION:-"18-lts"}
PACKAGE_MANAGER=${PACKAGEMANAGER:-"npm"}
ENABLE_STRICT=${ENABLESTRICT:-"true"}
INCLUDE_FABLE_TYPES=${INCLUDESTABLETYPES:-"true"}
CONFIG_TEMPLATE=${CONFIGTEMPLATE:-"fable"}

echo "Setting up TypeScript development environment (version: ${TYPESCRIPT_VERSION})..."

# Validation functions
validate_environment() {
    echo "🔍 Validating environment..."
    
    if ! command -v node >/dev/null 2>&1; then
        echo "❌ Node.js not found. Please ensure the node feature is installed first."
        exit 1
    fi
    
    if ! command -v npm >/dev/null 2>&1; then
        echo "❌ npm not found. Please ensure npm is available."
        exit 1
    fi
    
    echo "✅ Node.js found: $(node --version)"
    echo "✅ npm found: $(npm --version)"
}

install_typescript() {
    echo "📦 Installing TypeScript compiler..."
    
    case "$TYPESCRIPT_VERSION" in
        "latest")
            npm install -g typescript
            ;;
        *)
            npm install -g "typescript@${TYPESCRIPT_VERSION}"
            ;;
    esac
    
    # Install TypeScript language server
    npm install -g typescript-language-server
    
    echo "✅ TypeScript compiler installed: $(tsc --version)"
}

install_package_manager() {
    case "$PACKAGE_MANAGER" in
        "yarn")
            echo "📦 Installing Yarn..."
            npm install -g yarn
            echo "✅ Yarn installed: $(yarn --version)"
            ;;
        "pnpm")
            echo "📦 Installing pnpm..."
            npm install -g pnpm
            echo "✅ pnpm installed: $(pnpm --version)"
            ;;
        "npm")
            echo "✅ Using npm (already available)"
            ;;
    esac
}

install_linting_tools() {
    if [ "${ENABLE_ESLINT}" = "true" ]; then
        echo "🔍 Installing ESLint..."
        npm install -g eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
        
        # Create ESLint configuration
        create_eslint_config
    fi
    
    if [ "${ENABLE_PRETTIER}" = "true" ]; then
        echo "🎨 Installing Prettier..."
        npm install -g prettier
        
        # Create Prettier configuration
        create_prettier_config
    fi
}

create_typescript_configs() {
    echo "⚙️ Creating TypeScript configuration templates..."
    
    case "$CONFIG_TEMPLATE" in
        "fable")
            create_fable_tsconfig
            ;;
        "standard")
            create_standard_tsconfig
            ;;
        "node")
            create_node_tsconfig
            ;;
        "react")
            create_react_tsconfig
            ;;
    esac
}

create_fable_tsconfig() {
    echo "🎯 Creating Fable-compatible TypeScript configuration..."
    
    cat > /tmp/tsconfig.json << EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ES2020",
    "moduleResolution": "node",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "allowJs": true,
    "checkJs": false,
    "jsx": "react-jsx",
    "declaration": false,
    "declarationMap": false,
    "sourceMap": true,
    "outDir": "./dist",
    "strict": ${ENABLE_STRICT,,},
    "noUnusedLocals": false,
    "noUnusedParameters": false,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noImplicitAny": ${ENABLE_STRICT,,},
    "strictNullChecks": ${ENABLE_STRICT,,},
    "strictFunctionTypes": ${ENABLE_STRICT,,},
    "strictPropertyInitialization": false,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": false
  },
  "include": [
    "src/**/*",
    "tests/**/*",
    "*.ts",
    "*.tsx"
  ],
  "exclude": [
    "node_modules",
    "dist",
    "build",
    "**/*.spec.ts",
    "**/*.test.ts"
  ],
  "ts-node": {
    "esm": true
  }
}
EOF

    echo "✅ Fable-compatible TypeScript config created"
}

create_standard_tsconfig() {
    echo "📋 Creating standard TypeScript configuration..."
    
    cat > /tmp/tsconfig.json << EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "allowJs": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": ${ENABLE_STRICT,,},
    "moduleResolution": "node",
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "removeComments": false,
    "noImplicitAny": ${ENABLE_STRICT,,},
    "strictNullChecks": ${ENABLE_STRICT,,},
    "strictFunctionTypes": ${ENABLE_STRICT,,},
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "exactOptionalPropertyTypes": true
  },
  "include": [
    "src/**/*"
  ],
  "exclude": [
    "node_modules",
    "dist"
  ]
}
EOF

    echo "✅ Standard TypeScript config created"
}

create_node_tsconfig() {
    echo "🟢 Creating Node.js TypeScript configuration..."
    
    cat > /tmp/tsconfig.json << EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": ${ENABLE_STRICT,,},
    "moduleResolution": "node",
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "sourceMap": true,
    "types": ["node"],
    "typeRoots": ["./node_modules/@types"]
  },
  "include": [
    "src/**/*"
  ],
  "exclude": [
    "node_modules",
    "dist",
    "tests"
  ]
}
EOF

    echo "✅ Node.js TypeScript config created"
}

create_react_tsconfig() {
    echo "⚛️ Creating React TypeScript configuration..."
    
    cat > /tmp/tsconfig.json << EOF
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "esnext",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": ${ENABLE_STRICT,,},
    "forceConsistentCasingInFileNames": true,
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "declaration": false,
    "sourceMap": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": [
    "src/**/*"
  ],
  "exclude": [
    "node_modules"
  ]
}
EOF

    echo "✅ React TypeScript config created"
}

create_eslint_config() {
    echo "🔍 Creating ESLint configuration..."
    
    cat > /tmp/.eslintrc.js << 'EOF'
module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  plugins: [
    '@typescript-eslint',
  ],
  extends: [
    'eslint:recommended',
    '@typescript-eslint/recommended',
  ],
  env: {
    node: true,
    browser: true,
    es2020: true,
  },
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'module',
  },
  rules: {
    // TypeScript specific rules
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/explicit-module-boundary-types': 'off',
    '@typescript-eslint/no-explicit-any': 'warn',
    
    // General rules
    'no-console': 'warn',
    'prefer-const': 'error',
    'no-var': 'error',
  },
  ignorePatterns: [
    'dist/',
    'node_modules/',
    '*.js'
  ]
};
EOF

    echo "✅ ESLint configuration created"
}

create_prettier_config() {
    echo "🎨 Creating Prettier configuration..."
    
    cat > /tmp/.prettierrc << 'EOF'
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false,
  "bracketSpacing": true,
  "arrowParens": "avoid",
  "endOfLine": "lf",
  "quoteProps": "as-needed",
  "jsxSingleQuote": true,
  "bracketSameLine": false
}
EOF

    cat > /tmp/.prettierignore << 'EOF'
# Dependencies
node_modules/

# Build outputs
dist/
build/
.next/
coverage/

# Logs
*.log

# OS generated files
.DS_Store
Thumbs.db

# Editor directories
.vscode/
.idea/

# Temporary files
*.tmp
*.temp
EOF

    echo "✅ Prettier configuration created"
}

install_fable_types() {
    if [ "${INCLUDE_FABLE_TYPES}" = "true" ]; then
        echo "🎯 Installing Fable-specific type definitions..."
        
        # Install Fable core types
        npm install -g @fable-org/fable-library-ts || echo "⚠️ Fable types not available globally, install in project"
        
        # Create Fable type definitions template
        cat > /tmp/fable-types.d.ts << 'EOF'
// Fable F# to TypeScript type definitions
declare module "fable-library-ts/*" {
  export * from "fable-library-ts";
}

// F# Option type mapping
declare type Option<T> = T | null | undefined;

// F# Result type mapping  
declare type Result<T, E> = 
  | { tag: "Ok"; value: T }
  | { tag: "Error"; value: E };

// F# Choice type mapping
declare type Choice<T1, T2> =
  | { tag: "Choice1Of2"; value: T1 }
  | { tag: "Choice2Of2"; value: T2 };

// F# List type mapping
declare interface FSharpList<T> extends Array<T> {
  readonly head: T;
  readonly tail: FSharpList<T>;
  readonly isEmpty: boolean;
}

// F# Record type helper
declare type FSharpRecord = Record<string, any>;

// F# Union type helper
declare type FSharpUnion = { tag: string; [key: string]: any };

// Common F# interop functions
declare namespace FSharp {
  function mapOption<T, U>(mapper: (value: T) => U, option: Option<T>): Option<U>;
  function bindOption<T, U>(binder: (value: T) => Option<U>, option: Option<T>): Option<U>;
  function defaultValue<T>(defaultVal: T, option: Option<T>): T;
}
EOF

        echo "✅ Fable type definitions created at /tmp/fable-types.d.ts"
    fi
}

create_package_json_template() {
    echo "📦 Creating package.json template..."
    
    cat > /tmp/package.json << EOF
{
  "name": "fsharp-typescript-project",
  "version": "1.0.0",
  "description": "F# project with TypeScript integration",
  "main": "dist/index.js",
  "scripts": {
    "build": "tsc",
    "watch": "tsc --watch",
    "start": "node dist/index.js",
    "dev": "tsc --watch & nodemon dist/index.js",
    "clean": "rm -rf dist/",
    "lint": "eslint src/**/*.ts",
    "lint:fix": "eslint src/**/*.ts --fix",
    "format": "prettier --write src/**/*.ts",
    "type-check": "tsc --noEmit"
  },
  "devDependencies": {
    "typescript": "^${TYPESCRIPT_VERSION}",
    "@types/node": "^20.0.0"$(
      if [ "${ENABLE_ESLINT}" = "true" ]; then
        echo ','
        echo '    "eslint": "^8.0.0",'
        echo '    "@typescript-eslint/parser": "^6.0.0",'
        echo '    "@typescript-eslint/eslint-plugin": "^6.0.0"'
      fi
    )$(
      if [ "${ENABLE_PRETTIER}" = "true" ]; then
        echo ','
        echo '    "prettier": "^3.0.0"'
      fi
    )$(
      if [ "${INCLUDE_FABLE_TYPES}" = "true" ]; then
        echo ','
        echo '    "@fable-org/fable-library-ts": "^1.0.0"'
      fi
    )
  },
  "keywords": ["fsharp", "typescript", "fable"],
  "author": "",
  "license": "MIT"
}
EOF

    echo "✅ package.json template created"
}

create_development_scripts() {
    echo "📜 Creating development helper scripts..."
    
    # Create TypeScript build script
    cat > /tmp/build-ts.sh << 'EOF'
#!/bin/bash
# TypeScript Build Script

echo "🏗️ Building TypeScript project..."

# Type checking
echo "🔍 Type checking..."
tsc --noEmit

# Build
echo "📦 Compiling TypeScript..."
tsc

echo "✅ TypeScript build completed"
EOF

    # Create development watch script
    cat > /tmp/watch-ts.sh << 'EOF'
#!/bin/bash
# TypeScript Watch Script

echo "👀 Starting TypeScript watch mode..."

# Run TypeScript compiler in watch mode
tsc --watch
EOF

    # Create linting script
    if [ "${ENABLE_ESLINT}" = "true" ]; then
        cat > /tmp/lint-ts.sh << 'EOF'
#!/bin/bash
# TypeScript Linting Script

echo "🔍 Linting TypeScript files..."

# Run ESLint
eslint src/**/*.ts

# Auto-fix if requested
if [ "$1" = "--fix" ]; then
    echo "🔧 Auto-fixing linting issues..."
    eslint src/**/*.ts --fix
fi

echo "✅ Linting completed"
EOF
    fi

    chmod +x /tmp/build-ts.sh /tmp/watch-ts.sh
    if [ "${ENABLE_ESLINT}" = "true" ]; then
        chmod +x /tmp/lint-ts.sh
    fi
    
    echo "✅ Development scripts created"
}

verify_installation() {
    echo "🔍 Verifying TypeScript installation..."
    
    # Check TypeScript compiler
    if command -v tsc >/dev/null 2>&1; then
        echo "✅ TypeScript compiler available: $(tsc --version)"
    else
        echo "❌ TypeScript compiler not found"
        return 1
    fi
    
    # Check TypeScript language server
    if command -v typescript-language-server >/dev/null 2>&1; then
        echo "✅ TypeScript language server available"
    else
        echo "⚠️ TypeScript language server not found"
    fi
    
    # Check package manager
    case "$PACKAGE_MANAGER" in
        "yarn")
            if command -v yarn >/dev/null 2>&1; then
                echo "✅ Yarn available: $(yarn --version)"
            fi
            ;;
        "pnpm")
            if command -v pnpm >/dev/null 2>&1; then
                echo "✅ pnpm available: $(pnpm --version)"
            fi
            ;;
        "npm")
            echo "✅ npm available: $(npm --version)"
            ;;
    esac
    
    # Check linting tools
    if [ "${ENABLE_ESLINT}" = "true" ] && command -v eslint >/dev/null 2>&1; then
        echo "✅ ESLint available: $(eslint --version)"
    fi
    
    if [ "${ENABLE_PRETTIER}" = "true" ] && command -v prettier >/dev/null 2>&1; then
        echo "✅ Prettier available: $(prettier --version)"
    fi
    
    echo "✅ TypeScript development environment is ready!"
    return 0
}

# Main installation flow
main() {
    validate_environment
    install_typescript
    install_package_manager
    install_linting_tools
    create_typescript_configs
    install_fable_types
    create_package_json_template
    create_development_scripts
    verify_installation
    
    echo ""
    echo "🚀 TypeScript development environment is ready!"
    echo ""
    echo "🔧 Configuration:"
    echo "   • TypeScript: ${TYPESCRIPT_VERSION}"
    echo "   • Config template: ${CONFIG_TEMPLATE}"
    echo "   • Package manager: ${PACKAGE_MANAGER}"
    echo "   • ESLint: ${ENABLE_ESLINT}"
    echo "   • Prettier: ${ENABLE_PRETTIER}"
    echo "   • Strict mode: ${ENABLE_STRICT}"
    echo "   • Fable types: ${INCLUDE_FABLE_TYPES}"
    echo ""
    echo "📖 Quick start:"
    echo "   • tsc --init                     - Initialize TypeScript config"
    echo "   • tsc                           - Compile TypeScript"
    echo "   • tsc --watch                   - Watch mode compilation"
    echo ""
    echo "📁 Configuration files created in /tmp/:"
    echo "   • tsconfig.json                 - TypeScript configuration"
    echo "   • package.json                  - Package configuration"
    if [ "${ENABLE_ESLINT}" = "true" ]; then
        echo "   • .eslintrc.js                  - ESLint configuration"
    fi
    if [ "${ENABLE_PRETTIER}" = "true" ]; then
        echo "   • .prettierrc                   - Prettier configuration"
    fi
    if [ "${INCLUDE_FABLE_TYPES}" = "true" ]; then
        echo "   • fable-types.d.ts             - Fable type definitions"
    fi
    echo ""
    echo "💡 F# + TypeScript Integration:"
    echo "   • Use Fable to compile F# to TypeScript-compatible JavaScript"
    echo "   • Import Fable-generated modules in TypeScript projects"
    echo "   • Share type definitions between F# and TypeScript code"
    echo "   • Leverage TypeScript tooling for JavaScript libraries"
}

main "$@"