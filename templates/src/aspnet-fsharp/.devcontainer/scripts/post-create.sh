#!/bin/bash
set -euo pipefail

echo "🚀 Setting up ASP.NET Core F# web development environment..."

# Read template options (these would be passed by devcontainer CLI)
WEB_FRAMEWORK="${WEB_FRAMEWORK:-giraffe}"
INCLUDE_DATABASE="${INCLUDE_DATABASE:-false}"
INCLUDE_OPENAPI="${INCLUDE_OPENAPI:-true}"

# Function to create Giraffe-based web app
create_giraffe_app() {
    # Create project file
    cat > WebApp.fsproj << 'EOF'
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <TreatWarningsAsErrors>true</TreatWarningsAsErrors>
    <WarningsAsErrors />
    <WarningsNotAsErrors>FS0025</WarningsNotAsErrors>
  </PropertyGroup>

  <ItemGroup>
    <Compile Include="Models.fs" />
    <Compile Include="Views.fs" />
    <Compile Include="Handlers.fs" />
    <Compile Include="Program.fs" />
  </ItemGroup>

  <ItemGroup>
    <PackageReference Include="Giraffe" Version="6.4.0" />
    <PackageReference Include="Microsoft.AspNetCore.Authentication.JwtBearer" Version="8.0.0" />
EOF

    if [ "$INCLUDE_OPENAPI" = "true" ]; then
        cat >> WebApp.fsproj << 'EOF'
    <PackageReference Include="Microsoft.AspNetCore.OpenApi" Version="8.0.0" />
    <PackageReference Include="Swashbuckle.AspNetCore" Version="6.5.0" />
EOF
    fi

    if [ "$INCLUDE_DATABASE" = "true" ]; then
        cat >> WebApp.fsproj << 'EOF'
    <PackageReference Include="Microsoft.EntityFrameworkCore.Sqlite" Version="8.0.0" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.Design" Version="8.0.0" />
EOF
    fi

    cat >> WebApp.fsproj << 'EOF'
  </ItemGroup>
</Project>
EOF

    # Create Models.fs
    cat > Models.fs << 'EOF'
namespace WebApp.Models

open System
open System.ComponentModel.DataAnnotations

[<CLIMutable>]
type Todo = {
    Id: int
    Title: string
    IsCompleted: bool
    CreatedAt: DateTime
}

[<CLIMutable>]
type CreateTodoRequest = {
    Title: string
}

[<CLIMutable>]
type UpdateTodoRequest = {
    Title: string option
    IsCompleted: bool option
}
EOF

    # Create Views.fs
    cat > Views.fs << 'EOF'
namespace WebApp.Views

open Giraffe.ViewEngine
open WebApp.Models

module Layout =
    let layout (content: XmlNode list) =
        html [] [
            head [] [
                title [] [ encodedText "F# Web App" ]
                meta [ _name "viewport"; _content "width=device-width, initial-scale=1.0" ]
                link [ _rel "stylesheet"; _href "https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" ]
            ]
            body [] [
                div [ _class "container mt-4" ] content
                script [ _src "https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" ] []
            ]
        ]

module Pages =
    let index (todos: Todo list) =
        [
            h1 [] [ encodedText "F# Todo App" ]
            div [ _class "row" ] [
                div [ _class "col-md-6" ] [
                    h3 [] [ encodedText "Add New Todo" ]
                    form [ _method "post"; _action "/todos" ] [
                        div [ _class "mb-3" ] [
                            input [ _type "text"; _name "title"; _class "form-control"; _placeholder "Enter todo title"; _required ]
                        ]
                        button [ _type "submit"; _class "btn btn-primary" ] [ encodedText "Add Todo" ]
                    ]
                ]
                div [ _class "col-md-6" ] [
                    h3 [] [ encodedText "Todos" ]
                    ul [ _class "list-group" ] [
                        for todo in todos do
                            li [ _class "list-group-item d-flex justify-content-between align-items-center" ] [
                                span [] [ encodedText todo.Title ]
                                span [ _class (if todo.IsCompleted then "badge bg-success" else "badge bg-warning") ] [
                                    encodedText (if todo.IsCompleted then "Done" else "Pending")
                                ]
                            ]
                    ]
                ]
            ]
        ] |> Layout.layout
EOF

    # Create Handlers.fs
    cat > Handlers.fs << 'EOF'
namespace WebApp.Handlers

open Microsoft.AspNetCore.Http
open Giraffe
open WebApp.Models
open WebApp.Views

module TodoHandlers =
    // In-memory storage for demo purposes
    let mutable todos: Todo list = [
        { Id = 1; Title = "Learn F#"; IsCompleted = false; CreatedAt = System.DateTime.Now.AddDays(-1.0) }
        { Id = 2; Title = "Build web app"; IsCompleted = false; CreatedAt = System.DateTime.Now }
    ]
    
    let mutable nextId = 3

    let getAllTodos: HttpHandler =
        fun next ctx ->
            json todos next ctx

    let getTodoById (id: int): HttpHandler =
        fun next ctx ->
            match todos |> List.tryFind (fun t -> t.Id = id) with
            | Some todo -> json todo next ctx
            | None -> RequestErrors.NOT_FOUND "Todo not found" next ctx

    let createTodo: HttpHandler =
        fun next ctx ->
            task {
                let! request = ctx.BindJsonAsync<CreateTodoRequest>()
                let newTodo = {
                    Id = nextId
                    Title = request.Title
                    IsCompleted = false
                    CreatedAt = System.DateTime.Now
                }
                todos <- newTodo :: todos
                nextId <- nextId + 1
                return! json newTodo next ctx
            }

    let indexPage: HttpHandler =
        Pages.index todos |> htmlView

    let createTodoForm: HttpHandler =
        fun next ctx ->
            task {
                let! form = ctx.BindFormAsync<CreateTodoRequest>()
                let newTodo = {
                    Id = nextId
                    Title = form.Title
                    IsCompleted = false
                    CreatedAt = System.DateTime.Now
                }
                todos <- newTodo :: todos
                nextId <- nextId + 1
                return! redirectTo false "/" next ctx
            }
EOF

    # Create Program.fs
    cat > Program.fs << 'EOF'
open Microsoft.AspNetCore.Builder
open Microsoft.AspNetCore.Hosting
open Microsoft.Extensions.DependencyInjection
open Microsoft.Extensions.Hosting
open Giraffe
open WebApp.Handlers

let webApp =
    choose [
        GET >=> choose [
            route "/" >=> TodoHandlers.indexPage
            route "/api/todos" >=> TodoHandlers.getAllTodos
            routef "/api/todos/%i" TodoHandlers.getTodoById
        ]
        POST >=> choose [
            route "/api/todos" >=> TodoHandlers.createTodo
            route "/todos" >=> TodoHandlers.createTodoForm
        ]
        RequestErrors.NOT_FOUND "Page not found"
    ]

let configureServices (services: IServiceCollection) =
EOF

    if [ "$INCLUDE_OPENAPI" = "true" ]; then
        cat >> Program.fs << 'EOF'
    services.AddEndpointsApiExplorer() |> ignore
    services.AddSwaggerGen() |> ignore
EOF
    fi

    cat >> Program.fs << 'EOF'
    services.AddGiraffe() |> ignore

let configureApp (app: IApplicationBuilder) =
    app.UseRouting() |> ignore
EOF

    if [ "$INCLUDE_OPENAPI" = "true" ]; then
        cat >> Program.fs << 'EOF'
    app.UseSwagger() |> ignore
    app.UseSwaggerUI() |> ignore
EOF
    fi

    cat >> Program.fs << 'EOF'
    app.UseGiraffe(webApp)

[<EntryPoint>]
let main args =
    let builder = WebApplication.CreateBuilder(args)
    
    configureServices builder.Services
    
    let app = builder.Build()
    
    if app.Environment.IsDevelopment() then
        app.UseDeveloperExceptionPage() |> ignore
    
    configureApp app
    
    app.Run()
    
    0
EOF
}

# Function to create minimal API app (placeholder)
create_minimal_api_app() {
    echo "Creating minimal API app..."
    # Implementation would go here
    create_giraffe_app  # Fallback for now
}

# Function to create MVC app (placeholder)
create_mvc_app() {
    echo "Creating MVC app..."
    # Implementation would go here
    create_giraffe_app  # Fallback for now
}

# Create web application if src directory doesn't exist
if [ ! -d "src" ]; then
    echo "📦 Creating ASP.NET Core F# web application..."
    
    # Create project structure
    mkdir -p src
    cd src
    
    case "$WEB_FRAMEWORK" in
        "giraffe")
            create_giraffe_app
            ;;
        "minimal-api")
            create_minimal_api_app
            ;;
        "mvc")
            create_mvc_app
            ;;
        *)
            echo "Unknown web framework: $WEB_FRAMEWORK, defaulting to Giraffe"
            create_giraffe_app
            ;;
    esac
    
    cd ..
    echo "✅ Created ASP.NET Core F# web application in src/"
fi

# Create appsettings files
if [ ! -f "src/appsettings.json" ]; then
    echo "⚙️ Creating appsettings.json..."
    cat > src/appsettings.json << 'EOF'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "Urls": "http://localhost:5000;https://localhost:5001"
}
EOF
fi

if [ ! -f "src/appsettings.Development.json" ]; then
    echo "⚙️ Creating appsettings.Development.json..."
    cat > src/appsettings.Development.json << 'EOF'
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "DetailedErrors": true
}
EOF
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

# ASP.NET Core
appsettings.*.json
!appsettings.json
!appsettings.Development.json
wwwroot/dist/

# Database
*.db
*.db-*

# OS
.DS_Store
Thumbs.db

# F# specific
.fake/
.ionide/

# Certificates
*.pfx
*.p12
EOF
    echo "✅ Created .gitignore"
fi

# Create README for the project
if [ ! -f "README.md" ]; then
    echo "📝 Creating README.md..."
    cat > README.md << 'EOF'
# ASP.NET Core F# Web Application

A modern F# web application built with ASP.NET Core and Giraffe framework.

## Getting Started

### Development
```bash
cd src
dotnet run
```

The application will be available at:
- HTTP: http://localhost:5000
- HTTPS: https://localhost:5001

### Building
```bash
cd src
dotnet build
```

### Features
- F# with Giraffe web framework
- RESTful API endpoints
- HTML views with server-side rendering
- Bootstrap UI styling
- Development environment optimized

### API Endpoints
- `GET /` - Web interface
- `GET /api/todos` - Get all todos
- `GET /api/todos/{id}` - Get todo by ID
- `POST /api/todos` - Create new todo

### Project Structure
- `Models.fs` - Data models and DTOs
- `Views.fs` - HTML views using Giraffe.ViewEngine
- `Handlers.fs` - HTTP request handlers
- `Program.fs` - Application startup and configuration
EOF

    if [ "$INCLUDE_OPENAPI" = "true" ]; then
        cat >> README.md << 'EOF'

### API Documentation
When running in development mode, Swagger UI is available at:
- https://localhost:5001/swagger
EOF
    fi

    cat >> README.md << 'EOF'

### Development Tools
- Ionide for F# language support
- Fantomas for code formatting
- ASP.NET Core development certificates for HTTPS
EOF
    echo "✅ Created README.md"
fi

# Restore packages if project exists
if [ -f "src/WebApp.fsproj" ]; then
    echo "📥 Restoring NuGet packages..."
    cd src
    dotnet restore
    echo "✅ Packages restored"
    cd ..
fi

echo "🎉 ASP.NET Core F# web development environment setup complete!"
echo ""
echo "Getting started:"
echo "  - Open src/ to start coding"
echo "  - Run: cd src && dotnet run"
echo "  - Visit: https://localhost:5001"
if [ "$INCLUDE_OPENAPI" = "true" ]; then
echo "  - API docs: https://localhost:5001/swagger"
fi
echo "  - Build: cd src && dotnet build"
echo ""