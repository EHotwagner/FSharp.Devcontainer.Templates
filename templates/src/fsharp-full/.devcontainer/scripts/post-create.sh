#!/bin/bash
set -euo pipefail

echo "🚀 Setting up comprehensive F# development environment..."

# Read template options
PROJECT_TYPE="${PROJECT_TYPE:-mixed}"
INCLUDE_DATABASE="${INCLUDE_DATABASE:-false}"
INCLUDE_TYPESCRIPT="${INCLUDE_TYPESCRIPT:-false}"
BUILD_SYSTEM="${BUILD_SYSTEM:-fake}"
PACKAGE_MANAGER="${PACKAGE_MANAGER:-paket}"

# Create project structure based on type
setup_project_structure() {
    case "$PROJECT_TYPE" in
        "console")
            create_console_project
            ;;
        "library")
            create_library_project
            ;;
        "web")
            create_web_project
            ;;
        "mixed")
            create_mixed_project
            ;;
        *)
            echo "Unknown project type: $PROJECT_TYPE, defaulting to mixed"
            create_mixed_project
            ;;
    esac
}

create_console_project() {
    echo "📦 Creating console application structure..."
    mkdir -p src/App tests/App.Tests
    
    # Main application
    cat > src/App/App.fsproj << 'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0</TargetFramework>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
  </PropertyGroup>
  
  <ItemGroup>
    <Compile Include="Domain.fs" />
    <Compile Include="Program.fs" />
  </ItemGroup>
</Project>
EOF
    
    cat > src/App/Domain.fs << 'EOF'
namespace App.Domain

open System

type Result<'T, 'E> = Ok of 'T | Error of 'E

module Calculator =
    let add x y = x + y
    let subtract x y = x - y
    let multiply x y = x * y
    let divide x y =
        if y = 0.0 then Error "Division by zero"
        else Ok (x / y)

module Utilities =
    let greet name =
        sprintf "Hello, %s! Welcome to F# development." name
    
    let processArgs args =
        match args with
        | [| name |] -> Some name
        | _ -> None
EOF
    
    cat > src/App/Program.fs << 'EOF'
open System
open App.Domain

[<EntryPoint>]
let main args =
    match Utilities.processArgs args with
    | Some name -> 
        printfn "%s" (Utilities.greet name)
        0
    | None -> 
        printfn "%s" (Utilities.greet "World")
        printfn "Calculator example: 10 / 2 = %A" (Calculator.divide 10.0 2.0)
        0
EOF

    # Tests
    create_test_project "App.Tests" "App"
}

create_library_project() {
    echo "📦 Creating library project structure..."
    mkdir -p src/Library tests/Library.Tests
    
    cat > src/Library/Library.fsproj << 'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
  </PropertyGroup>
  
  <ItemGroup>
    <Compile Include="Types.fs" />
    <Compile Include="Core.fs" />
    <Compile Include="Library.fs" />
  </ItemGroup>
</Project>
EOF

    cat > src/Library/Types.fs << 'EOF'
namespace Library.Types

type Person = {
    Id: int
    Name: string
    Email: string
    Age: int option
}

type ValidationError =
    | EmptyName
    | InvalidEmail
    | InvalidAge of int

type Result<'T> = Result<'T, ValidationError list>
EOF

    cat > src/Library/Core.fs << 'EOF'
namespace Library.Core

open Library.Types
open System.Text.RegularExpressions

module Validation =
    let validateName name =
        if String.length name = 0 then [EmptyName]
        else []
    
    let validateEmail email =
        let emailRegex = Regex(@"^[^@\s]+@[^@\s]+\.[^@\s]+$")
        if emailRegex.IsMatch(email) then []
        else [InvalidEmail]
    
    let validateAge age =
        match age with
        | Some a when a < 0 || a > 150 -> [InvalidAge a]
        | _ -> []

module PersonService =
    open Validation
    
    let createPerson id name email age =
        let errors = 
            (validateName name) @ 
            (validateEmail email) @ 
            (validateAge age)
        
        match errors with
        | [] -> Ok { Id = id; Name = name; Email = email; Age = age }
        | errs -> Error errs
EOF

    cat > src/Library/Library.fs << 'EOF'
namespace Library

open Library.Types
open Library.Core

/// Main library interface
module Api =
    /// Create a new person with validation
    let createPerson = PersonService.createPerson
    
    /// Validate person data
    let validatePerson person =
        createPerson person.Id person.Name person.Email person.Age
EOF

    create_test_project "Library.Tests" "Library"
}

create_web_project() {
    echo "📦 Creating web application structure..."
    mkdir -p src/WebApp tests/WebApp.Tests
    
    # Use the same Giraffe setup from ASP.NET template
    # but with more comprehensive structure
    create_giraffe_web_project
    create_test_project "WebApp.Tests" "WebApp"
}

create_mixed_project() {
    echo "📦 Creating mixed project structure..."
    mkdir -p src/{App,Library,WebApp} tests/{App.Tests,Library.Tests,WebApp.Tests}
    
    create_console_project
    create_library_project  
    create_web_project
    
    # Add solution file
    create_solution_file
}

create_giraffe_web_project() {
    # Similar to ASP.NET template but integrated into full structure
    cat > src/WebApp/WebApp.fsproj << 'EOF'
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
  </PropertyGroup>

  <ItemGroup>
    <Compile Include="Models.fs" />
    <Compile Include="Views.fs" />
    <Compile Include="Handlers.fs" />
    <Compile Include="Program.fs" />
  </ItemGroup>

  <ItemGroup>
    <PackageReference Include="Giraffe" Version="6.4.0" />
    <PackageReference Include="Microsoft.AspNetCore.OpenApi" Version="8.0.0" />
    <PackageReference Include="Swashbuckle.AspNetCore" Version="6.5.0" />
  </ItemGroup>
  
  <ItemGroup Condition="Exists('../Library/Library.fsproj')">
    <ProjectReference Include="../Library/Library.fsproj" />
  </ItemGroup>
</Project>
EOF

    # Copy web app files (simplified versions)
    cat > src/WebApp/Models.fs << 'EOF'
namespace WebApp.Models

[<CLIMutable>]
type ApiResponse<'T> = {
    Data: 'T
    Success: bool
    Message: string option
}

[<CLIMutable>]
type HealthCheck = {
    Status: string
    Timestamp: System.DateTime
    Version: string
}
EOF

    cat > src/WebApp/Views.fs << 'EOF'
namespace WebApp.Views

open Giraffe.ViewEngine

module Layout =
    let layout title content =
        html [] [
            head [] [
                title [] [ encodedText title ]
                meta [ _name "viewport"; _content "width=device-width, initial-scale=1.0" ]
                link [ _rel "stylesheet"; _href "https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" ]
            ]
            body [] [
                nav [ _class "navbar navbar-dark bg-dark" ] [
                    div [ _class "container" ] [
                        span [ _class "navbar-brand" ] [ encodedText "F# Full Stack App" ]
                    ]
                ]
                div [ _class "container mt-4" ] content
            ]
        ]

module Pages =
    let home =
        [
            h1 [] [ encodedText "F# Full Development Environment" ]
            p [] [ encodedText "A comprehensive F# development setup with all the tools you need." ]
            div [ _class "row" ] [
                div [ _class "col-md-4" ] [
                    div [ _class "card" ] [
                        div [ _class "card-body" ] [
                            h5 [ _class "card-title" ] [ encodedText "Console App" ]
                            p [ _class "card-text" ] [ encodedText "Command-line application with domain logic" ]
                        ]
                    ]
                ]
                div [ _class "col-md-4" ] [
                    div [ _class "card" ] [
                        div [ _class "card-body" ] [
                            h5 [ _class "card-title" ] [ encodedText "Library" ]
                            p [ _class "card-text" ] [ encodedText "Shared business logic and utilities" ]
                        ]
                    ]
                ]
                div [ _class "col-md-4" ] [
                    div [ _class "card" ] [
                        div [ _class "card-body" ] [
                            h5 [ _class "card-title" ] [ encodedText "Web API" ]
                            p [ _class "card-text" ] [ encodedText "RESTful API with Giraffe framework" ]
                            a [ _href "/api/health"; _class "btn btn-primary" ] [ encodedText "Health Check" ]
                        ]
                    ]
                ]
            ]
        ] |> Layout.layout "F# Full Stack"
EOF

    cat > src/WebApp/Handlers.fs << 'EOF'
namespace WebApp.Handlers

open Microsoft.AspNetCore.Http
open Giraffe
open WebApp.Models
open WebApp.Views
open System

module ApiHandlers =
    let healthCheck: HttpHandler =
        fun next ctx ->
            let health = {
                Status = "Healthy"
                Timestamp = DateTime.UtcNow
                Version = "1.0.0"
            }
            let response = {
                Data = health
                Success = true
                Message = None
            }
            json response next ctx

    let home: HttpHandler =
        fun next ctx ->
            Pages.home |> htmlView next ctx
EOF

    cat > src/WebApp/Program.fs << 'EOF'
open Microsoft.AspNetCore.Builder
open Microsoft.Extensions.DependencyInjection
open Microsoft.Extensions.Hosting
open Giraffe
open WebApp.Handlers

let webApp =
    choose [
        GET >=> choose [
            route "/" >=> ApiHandlers.home
            route "/api/health" >=> ApiHandlers.healthCheck
        ]
        RequestErrors.NOT_FOUND "Page not found"
    ]

[<EntryPoint>]
let main args =
    let builder = WebApplication.CreateBuilder(args)
    
    builder.Services.AddGiraffe() |> ignore
    builder.Services.AddEndpointsApiExplorer() |> ignore
    builder.Services.AddSwaggerGen() |> ignore
    
    let app = builder.Build()
    
    if app.Environment.IsDevelopment() then
        app.UseDeveloperExceptionPage() |> ignore
        app.UseSwagger() |> ignore
        app.UseSwaggerUI() |> ignore
    
    app.UseRouting() |> ignore
    app.UseGiraffe(webApp)
    
    app.Run()
    0
EOF
}

create_test_project() {
    local test_name=$1
    local project_ref=$2
    
    cat > tests/$test_name/$test_name.fsproj << EOF
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <IsPackable>false</IsPackable>
    <GenerateProgramFile>false</GenerateProgramFile>
  </PropertyGroup>

  <ItemGroup>
    <Compile Include="Tests.fs" />
    <Compile Include="Program.fs" />
  </ItemGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.8.0" />
    <PackageReference Include="xunit" Version="2.6.1" />
    <PackageReference Include="xunit.runner.visualstudio" Version="2.5.3" />
    <PackageReference Include="FsUnit.xUnit" Version="5.6.0" />
  </ItemGroup>

  <ItemGroup Condition="Exists('../../src/$project_ref/$project_ref.fsproj')">
    <ProjectReference Include="../../src/$project_ref/$project_ref.fsproj" />
  </ItemGroup>
</Project>
EOF

    cat > tests/$test_name/Tests.fs << EOF
module $test_name

open Xunit
open FsUnit.Xunit

[<Fact>]
let \`Sample test should pass\` () =
    let result = 2 + 2
    result |> should equal 4

[<Fact>]
let \`String test should work\` () =
    let message = "Hello, F#!"
    message |> should contain "F#"
EOF

    cat > tests/$test_name/Program.fs << 'EOF'
module Program = let [<EntryPoint>] main _ = 0
EOF
}

create_solution_file() {
    echo "📄 Creating solution file..."
    
    cat > FSharpFullStack.sln << 'EOF'
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
VisualStudioVersion = 17.0.31903.59
MinimumVisualStudioVersion = 10.0.40219.1

Project("{F2A71F9B-5D33-465A-A702-920D77279786}") = "App", "src\App\App.fsproj", "{11111111-1111-1111-1111-111111111111}"
EndProject
Project("{F2A71F9B-5D33-465A-A702-920D77279786}") = "Library", "src\Library\Library.fsproj", "{22222222-2222-2222-2222-222222222222}"
EndProject
Project("{F2A71F9B-5D33-465A-A702-920D77279786}") = "WebApp", "src\WebApp\WebApp.fsproj", "{33333333-3333-3333-3333-333333333333}"
EndProject
Project("{F2A71F9B-5D33-465A-A702-920D77279786}") = "App.Tests", "tests\App.Tests\App.Tests.fsproj", "{44444444-4444-4444-4444-444444444444}"
EndProject
Project("{F2A71F9B-5D33-465A-A702-920D77279786}") = "Library.Tests", "tests\Library.Tests\Library.Tests.fsproj", "{55555555-5555-5555-5555-555555555555}"
EndProject
Project("{F2A71F9B-5D33-465A-A702-920D77279786}") = "WebApp.Tests", "tests\WebApp.Tests\WebApp.Tests.fsproj", "{66666666-6666-6666-6666-666666666666}"
EndProject

Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Any CPU = Debug|Any CPU
		Release|Any CPU = Release|Any CPU
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{11111111-1111-1111-1111-111111111111}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{11111111-1111-1111-1111-111111111111}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{11111111-1111-1111-1111-111111111111}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{11111111-1111-1111-1111-111111111111}.Release|Any CPU.Build.0 = Release|Any CPU
		{22222222-2222-2222-2222-222222222222}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{22222222-2222-2222-2222-222222222222}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{22222222-2222-2222-2222-222222222222}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{22222222-2222-2222-2222-222222222222}.Release|Any CPU.Build.0 = Release|Any CPU
		{33333333-3333-3333-3333-333333333333}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{33333333-3333-3333-3333-333333333333}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{33333333-3333-3333-3333-333333333333}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{33333333-3333-3333-3333-333333333333}.Release|Any CPU.Build.0 = Release|Any CPU
		{44444444-4444-4444-4444-444444444444}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{44444444-4444-4444-4444-444444444444}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{44444444-4444-4444-4444-444444444444}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{44444444-4444-4444-4444-444444444444}.Release|Any CPU.Build.0 = Release|Any CPU
		{55555555-5555-5555-5555-555555555555}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{55555555-5555-5555-5555-555555555555}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{55555555-5555-5555-5555-555555555555}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{55555555-5555-5555-5555-555555555555}.Release|Any CPU.Build.0 = Release|Any CPU
		{66666666-6666-6666-6666-666666666666}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{66666666-6666-6666-6666-666666666666}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{66666666-6666-6666-6666-666666666666}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{66666666-6666-6666-6666-666666666666}.Release|Any CPU.Build.0 = Release|Any CPU
	EndGlobalSection
EndGlobal
EOF
}

# Setup build system
setup_build_system() {
    case "$BUILD_SYSTEM" in
        "fake"|"both")
            setup_fake_build
            ;;
    esac
    
    case "$BUILD_SYSTEM" in
        "dotnet"|"both")
            setup_dotnet_build
            ;;
    esac
}

setup_fake_build() {
    echo "🔨 Setting up FAKE build system..."
    
    if [ ! -f "build.fsx" ]; then
        cat > build.fsx << 'EOF'
#r "paket:
nuget Fake.Core.Target
nuget Fake.DotNet.Cli
nuget Fake.IO.FileSystem
nuget Fake.DotNet.Testing.XUnit2 //"

#load ".fake/build.fsx/intellisense.fsx"

open Fake.Core
open Fake.DotNet
open Fake.IO

let srcDir = "./src"
let testsDir = "./tests"
let outputDir = "./output"

Target.create "Clean" (fun _ ->
    !! "src/**/bin"
    ++ "src/**/obj"
    ++ "tests/**/bin"
    ++ "tests/**/obj"
    ++ outputDir
    |> Shell.cleanDirs
)

Target.create "Build" (fun _ ->
    !! "src/**/*.fsproj"
    |> Seq.iter (DotNet.build id)
)

Target.create "Test" (fun _ ->
    !! "tests/**/*.fsproj"
    |> Seq.iter (DotNet.test id)
)

Target.create "Package" (fun _ ->
    !! "src/**/*.fsproj"
    |> Seq.iter (DotNet.pack (fun p -> 
        { p with OutputPath = Some outputDir }))
)

Target.create "Default" ignore

"Clean"
  ==> "Build"
  ==> "Test"
  ==> "Default"

"Build"
  ==> "Package"

Target.runOrDefault "Default"
EOF
    fi
}

setup_dotnet_build() {
    echo "🔨 Setting up .NET build configuration..."
    
    if [ ! -f "Directory.Build.props" ]; then
        cat > Directory.Build.props << 'EOF'
<Project>
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <LangVersion>latest</LangVersion>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <WarningsAsErrors />
    <WarningsNotAsErrors>FS0025</WarningsNotAsErrors>
    <GenerateDocumentationFile>true</GenerateDocumentationFile>
  </PropertyGroup>
  
  <PropertyGroup Condition="'$(Configuration)' == 'Release'">
    <Optimize>true</Optimize>
    <DebugType>pdbonly</DebugType>
    <DebugSymbols>true</DebugSymbols>
  </PropertyGroup>
</Project>
EOF
    fi
}

# Setup package management
setup_package_management() {
    case "$PACKAGE_MANAGER" in
        "paket"|"both")
            setup_paket_config
            ;;
    esac
}

setup_paket_config() {
    echo "📦 Setting up Paket configuration..."
    
    if [ ! -f "paket.dependencies" ]; then
        cat > paket.dependencies << 'EOF'
source https://api.nuget.org/v3/index.json

framework: net8.0
storage: none

// Core dependencies
nuget FSharp.Core
nuget Microsoft.NET.Test.Sdk
nuget xunit
nuget xunit.runner.visualstudio
nuget FsUnit.xUnit

// Web dependencies
nuget Giraffe
nuget Microsoft.AspNetCore.OpenApi
nuget Swashbuckle.AspNetCore

group Build
  source https://api.nuget.org/v3/index.json
  
  nuget Fake.Core.Target
  nuget Fake.DotNet.Cli
  nuget Fake.IO.FileSystem
  nuget Fake.DotNet.Testing.XUnit2
EOF
    fi
}

# Main setup execution
if [ ! -d "src" ]; then
    setup_project_structure
    setup_build_system
    setup_package_management
fi

# Create comprehensive .gitignore
if [ ! -f ".gitignore" ]; then
    echo "📝 Creating comprehensive .gitignore..."
    cat > .gitignore << 'EOF'
# .NET
bin/
obj/
*.user
*.suo
*.cache
*.docstates
[Bb]in
[Oo]bj
[Tt]est[Rr]esults
*.vspscc
$tf/

# Build results
[Dd]ebug/
[Rr]elease/
x64/
output/

# NuGet & Paket
packages/
paket-files/
!packages/repositories.config
!packages/build/
*.nupkg

# FAKE
.fake/

# Visual Studio
.vs/
*.vscode/settings.json

# ASP.NET Core
appsettings.*.json
!appsettings.json
!appsettings.Development.json
wwwroot/dist/

# Database
*.db
*.db-*

# Frontend
node_modules/
dist/
.parcel-cache/

# OS
.DS_Store
Thumbs.db

# F# specific
.ionide/

# Certificates
*.pfx
*.p12
EOF
fi

# Create comprehensive README
if [ ! -f "README.md" ]; then
    echo "📝 Creating comprehensive README.md..."
    cat > README.md << 'EOF'
# F# Full Development Environment

A comprehensive F# development setup with modern tooling and best practices.

## Project Structure

```
├── src/
│   ├── App/           # Console application
│   ├── Library/       # Shared business logic
│   └── WebApp/        # Web application (Giraffe)
├── tests/
│   ├── App.Tests/
│   ├── Library.Tests/
│   └── WebApp.Tests/
├── build.fsx          # FAKE build script
└── paket.dependencies # Package dependencies
```

## Getting Started

### Development
```bash
# Build all projects
dotnet build

# Run console app
cd src/App && dotnet run

# Run web app
cd src/WebApp && dotnet run

# Run tests
dotnet test
```

### Using FAKE Build System
```bash
# Install FAKE tool (if not already installed)
dotnet tool install fake-cli -g

# Run build
fake build

# Clean and build
fake build -t Clean
fake build -t Build

# Run tests
fake build -t Test
```

### Package Management with Paket
```bash
# Install Paket (if not already installed)
dotnet tool install paket -g

# Install dependencies
paket install

# Add new package
paket add <package-name>

# Update packages
paket update
```

## Available Tools

- **Ionide**: F# language support in VS Code
- **Fantomas**: F# code formatter
- **Paket**: Predictable package management
- **FAKE**: F# build automation
- **xUnit + FsUnit**: Testing framework
- **Giraffe**: Functional web framework
- **OpenCode**: AI development assistant

## Web Application

The web application is available at:
- HTTP: http://localhost:5000
- HTTPS: https://localhost:5001
- Swagger: https://localhost:5001/swagger

## Testing

```bash
# Run all tests
dotnet test

# Run specific test project
dotnet test tests/Library.Tests/

# Run tests with coverage
dotnet test --collect:"XPlat Code Coverage"
```

## Build Configurations

### Debug (Default)
- Full debugging symbols
- No optimizations
- Detailed error messages

### Release
- Optimized code
- Minimal debug info
- Production ready

```bash
dotnet build -c Release
```

## Development Features

- **Comprehensive F# Setup**: Console, library, and web projects
- **Modern Testing**: xUnit with FsUnit for idiomatic F# tests
- **Build Automation**: FAKE build system with common tasks
- **Package Management**: Paket for reproducible builds
- **Code Quality**: Fantomas formatting, warnings as errors
- **VS Code Integration**: Optimized settings and extensions
- **Hot Reload**: ASP.NET Core development experience
- **OpenAPI**: Swagger documentation for web APIs

## Contributing

1. Follow F# coding conventions
2. Add tests for new functionality
3. Use Fantomas for code formatting
4. Ensure all builds pass before committing

```bash
# Format code
fantomas src/ tests/

# Verify build
fake build
```
EOF
fi

# Restore packages and build
if [ -f "paket.dependencies" ] && command -v paket >/dev/null 2>&1; then
    echo "📥 Installing Paket dependencies..."
    paket install
elif [ -f "FSharpFullStack.sln" ]; then
    echo "📥 Restoring NuGet packages..."
    dotnet restore
fi

echo "🎉 F# full development environment setup complete!"
echo ""
echo "🚀 Getting started:"
case "$PROJECT_TYPE" in
    "console")
        echo "  - Console app: cd src/App && dotnet run"
        ;;
    "library")
        echo "  - Library: cd src/Library && dotnet build"
        echo "  - Tests: dotnet test tests/Library.Tests/"
        ;;
    "web")
        echo "  - Web app: cd src/WebApp && dotnet run"
        echo "  - Visit: https://localhost:5001"
        ;;
    "mixed")
        echo "  - Console app: cd src/App && dotnet run"
        echo "  - Web app: cd src/WebApp && dotnet run"
        echo "  - All tests: dotnet test"
        echo "  - FAKE build: fake build"
        ;;
esac
echo ""
echo "🛠️  Available tools:"
echo "  - Format code: fantomas src/ tests/"
echo "  - Build system: fake build"
echo "  - Package manager: paket install"
echo "  - AI assistant: opencode"
echo ""