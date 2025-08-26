#!/bin/bash
set -euo pipefail

echo "🚀 Setting up F# minimal development environment..."

# Create sample F# console application if src directory doesn't exist
if [ ! -d "src" ]; then
    echo "📦 Creating sample F# console application..."
    
    # Create project structure
    mkdir -p src
    cd src
    
    # Create F# project file
    cat > App.fsproj << 'EOF'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net8.0</TargetFramework>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <WarningsAsErrors />
    <WarningsNotAsErrors>FS0025</WarningsNotAsErrors>
  </PropertyGroup>

  <ItemGroup>
    <Compile Include="Program.fs" />
  </ItemGroup>
</Project>
EOF
    
    # Create Program.fs
    cat > Program.fs << 'EOF'
// F# Console Application Template
// Learn more about F# at https://fsharp.org

open System

let greet name =
    sprintf "Hello, %s! Welcome to F# development." name

[<EntryPoint>]
let main args =
    match args with
    | [| name |] -> 
        printfn "%s" (greet name)
        0
    | _ -> 
        printfn "%s" (greet "World")
        0
EOF

    cd ..
    echo "✅ Created sample F# console application in src/"
fi

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    echo "📝 Creating .gitignore..."
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
[Bb]in/
[Oo]bj/

# NuGet
packages/
!packages/repositories.config
!packages/build/
*.nupkg

# Visual Studio
.vs/
*.vscode/settings.json

# OS
.DS_Store
Thumbs.db

# F# specific
.fake/
.ionide/
EOF
    echo "✅ Created .gitignore"
fi

# Restore packages if project exists
if [ -f "src/App.fsproj" ]; then
    echo "📥 Restoring NuGet packages..."
    cd src
    dotnet restore
    echo "✅ Packages restored"
    cd ..
fi

echo "🎉 F# minimal development environment setup complete!"
echo ""
echo "Getting started:"
echo "  - Open src/Program.fs to start coding"
echo "  - Run: cd src && dotnet run"
echo "  - Build: cd src && dotnet build"
echo "  - Test your setup: cd src && dotnet run YourName"
echo ""