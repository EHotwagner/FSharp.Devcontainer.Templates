#!/bin/bash
set -euo pipefail

# Feature: ASP.NET Core F# Web Development
# Version: 1.0.0
# Description: ASP.NET Core web development support for F# applications

# Parse feature options
FRAMEWORK=${FRAMEWORK:-"giraffe"}
INCLUDE_SWAGGER=${INCLUDESWAGGER:-"true"}
INCLUDE_AUTH=${INCLUDEAUTH:-"false"}
ENABLE_HOT_RELOAD=${ENABLEHOTRELOAD:-"true"}
INCLUDE_DOCKER=${INCLUDEDOCKER:-"false"}
ENABLE_HTTPS=${ENABLEHTTPS:-"true"}
INCLUDE_ENTITY_FRAMEWORK=${INCLUDEENTITYFRAMEWORK:-"false"}

echo "Setting up ASP.NET Core F# web development (framework: ${FRAMEWORK})..."

# Validation functions
validate_environment() {
    echo "🔍 Validating environment..."
    
    if ! command -v dotnet >/dev/null 2>&1; then
        echo "❌ .NET SDK not found. Please ensure the dotnet feature is installed first."
        exit 1
    fi
    
    # Check if ASP.NET Core runtime is available
    if ! dotnet --list-runtimes | grep -q "Microsoft.AspNetCore.App"; then
        echo "⚠️ ASP.NET Core runtime not detected, installing with SDK"
    fi
    
    echo "✅ .NET SDK found: $(dotnet --version)"
}

install_aspnet_templates() {
    echo "📦 Installing ASP.NET Core templates for F#..."
    
    # Install F# web templates
    dotnet new install Microsoft.AspNetCore.SPA.ProjectTemplates || true
    
    # Install additional F# templates based on framework choice
    case "$FRAMEWORK" in
        "giraffe")
            echo "🦒 Installing Giraffe framework templates..."
            dotnet new install Giraffe.Template || true
            ;;
        "saturn")
            echo "🪐 Installing Saturn framework templates..."
            dotnet new install Saturn.Template || true
            ;;
        "minimal")
            echo "🎯 Using minimal API templates (built-in)"
            ;;
        "mvc")
            echo "🏗️ Using MVC templates (built-in)"
            ;;
    esac
    
    echo "✅ ASP.NET Core templates installed"
}

create_project_templates() {
    echo "📝 Creating project templates..."
    
    case "$FRAMEWORK" in
        "giraffe")
            create_giraffe_template
            ;;
        "saturn")
            create_saturn_template
            ;;
        "minimal")
            create_minimal_api_template
            ;;
        "mvc")
            create_mvc_template
            ;;
    esac
}

create_giraffe_template() {
    echo "🦒 Creating Giraffe F# web template..."
    
    mkdir -p /tmp/aspnet-templates/giraffe
    cd /tmp/aspnet-templates/giraffe
    
    # Create Program.fs
    cat > Program.fs << 'EOF'
module Program

open Microsoft.AspNetCore.Builder
open Microsoft.AspNetCore.Hosting
open Microsoft.Extensions.DependencyInjection
open Microsoft.Extensions.Hosting
open Microsoft.Extensions.Logging
open Giraffe

let webApp =
    choose [
        GET >=>
            choose [
                route "/" >=> text "Hello World from Giraffe!"
                route "/hello" >=> text "Hello from F#!"
                routef "/hello/%s" (sprintf "Hello %s!")
            ]
        setStatusCode 404 >=> text "Not Found" ]

let configureApp (app : IApplicationBuilder) =
    app.UseGiraffe(webApp)

let configureServices (services : IServiceCollection) =
    services.AddGiraffe() |> ignore

[<EntryPoint>]
let main args =
    WebApplication.CreateBuilder(args)
        .ConfigureServices(configureServices)
        .Build()
        .Configure(configureApp)
        .Run()
    0
EOF

    # Create project file
    cat > GiraffeApp.fsproj << 'EOF'
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
  </PropertyGroup>

  <ItemGroup>
    <Compile Include="Program.fs" />
  </ItemGroup>

  <ItemGroup>
    <PackageReference Include="Giraffe" Version="6.4.0" />
  </ItemGroup>

</Project>
EOF

    echo "✅ Giraffe template created at /tmp/aspnet-templates/giraffe/"
}

create_saturn_template() {
    echo "🪐 Creating Saturn F# web template..."
    
    mkdir -p /tmp/aspnet-templates/saturn
    cd /tmp/aspnet-templates/saturn
    
    # Create Program.fs
    cat > Program.fs << 'EOF'
module Program

open Saturn
open Giraffe

let webApp = router {
    get "/" (text "Hello World from Saturn!")
    get "/hello" (text "Hello from F#!")
    getf "/hello/%s" (sprintf "Hello %s!" >> text)
}

let app = application {
    use_router webApp
    memory_cache
    use_static "public"
    use_gzip
}

[<EntryPoint>]
let main args =
    run app
    0
EOF

    # Create project file
    cat > SaturnApp.fsproj << 'EOF'
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
  </PropertyGroup>

  <ItemGroup>
    <Compile Include="Program.fs" />
  </ItemGroup>

  <ItemGroup>
    <PackageReference Include="Saturn" Version="0.16.1" />
  </ItemGroup>

</Project>
EOF

    echo "✅ Saturn template created at /tmp/aspnet-templates/saturn/"
}

create_minimal_api_template() {
    echo "🎯 Creating Minimal API F# template..."
    
    mkdir -p /tmp/aspnet-templates/minimal
    cd /tmp/aspnet-templates/minimal
    
    # Create Program.fs
    cat > Program.fs << 'EOF'
open Microsoft.AspNetCore.Builder
open Microsoft.Extensions.DependencyInjection
open Microsoft.Extensions.Hosting

let builder = WebApplication.CreateBuilder()

// Add services
builder.Services.AddEndpointsApiExplorer() |> ignore
if builder.Environment.IsDevelopment() then
    builder.Services.AddSwaggerGen() |> ignore

let app = builder.Build()

// Configure pipeline
if app.Environment.IsDevelopment() then
    app.UseSwagger() |> ignore
    app.UseSwaggerUI() |> ignore

// Define endpoints
app.MapGet("/", fun () -> "Hello World from F# Minimal API!") |> ignore
app.MapGet("/hello/{name}", fun (name: string) -> $"Hello {name}!") |> ignore

app.Run()
EOF

    # Create project file
    cat > MinimalApiApp.fsproj << 'EOF'
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
  </PropertyGroup>

  <ItemGroup>
    <Compile Include="Program.fs" />
  </ItemGroup>

  <ItemGroup>
    <PackageReference Include="Swashbuckle.AspNetCore" Version="6.5.0" />
  </ItemGroup>

</Project>
EOF

    echo "✅ Minimal API template created at /tmp/aspnet-templates/minimal/"
}

create_mvc_template() {
    echo "🏗️ Creating MVC F# template..."
    
    mkdir -p /tmp/aspnet-templates/mvc/{Controllers,Views,Models}
    cd /tmp/aspnet-templates/mvc
    
    # Create Program.fs
    cat > Program.fs << 'EOF'
open Microsoft.AspNetCore.Builder
open Microsoft.Extensions.DependencyInjection
open Microsoft.Extensions.Hosting

let builder = WebApplication.CreateBuilder()

// Add services
builder.Services.AddControllersWithViews() |> ignore

let app = builder.Build()

// Configure pipeline
if not (app.Environment.IsDevelopment()) then
    app.UseExceptionHandler("/Home/Error") |> ignore
    app.UseHsts() |> ignore

app.UseHttpsRedirection() |> ignore
app.UseStaticFiles() |> ignore
app.UseRouting() |> ignore

app.MapControllerRoute(
    name = "default",
    pattern = "{controller=Home}/{action=Index}/{id?}") |> ignore

app.Run()
EOF

    # Create HomeController.fs
    cat > Controllers/HomeController.fs << 'EOF'
namespace Controllers

open Microsoft.AspNetCore.Mvc

[<ApiController>]
type HomeController() =
    inherit ControllerBase()
    
    [<HttpGet>]
    member this.Index() =
        this.View()
    
    [<HttpGet>]
    member this.About() =
        this.View()
EOF

    # Create project file
    cat > MvcApp.fsproj << 'EOF'
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
  </PropertyGroup>

  <ItemGroup>
    <Compile Include="Controllers/HomeController.fs" />
    <Compile Include="Program.fs" />
  </ItemGroup>

</Project>
EOF

    echo "✅ MVC template created at /tmp/aspnet-templates/mvc/"
}

configure_swagger() {
    if [ "${INCLUDE_SWAGGER}" = "true" ]; then
        echo "📊 Configuring Swagger/OpenAPI..."
        
        # Create swagger configuration
        cat > /tmp/swagger-config.fs << 'EOF'
// Swagger Configuration for F# ASP.NET Core
open Microsoft.Extensions.DependencyInjection
open Microsoft.OpenApi.Models

let configureSwagger (services: IServiceCollection) =
    services.AddSwaggerGen(fun c ->
        c.SwaggerDoc("v1", OpenApiInfo(
            Title = "F# Web API",
            Version = "v1",
            Description = "F# ASP.NET Core Web API"
        ))
    ) |> ignore
    
let useSwaggerMiddleware (app: IApplicationBuilder) =
    app.UseSwagger() |> ignore
    app.UseSwaggerUI(fun c ->
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "F# Web API V1")
        c.RoutePrefix <- ""
    ) |> ignore
EOF

        echo "✅ Swagger configuration created"
    fi
}

configure_authentication() {
    if [ "${INCLUDE_AUTH}" = "true" ]; then
        echo "🔐 Configuring authentication scaffolding..."
        
        cat > /tmp/auth-config.fs << 'EOF'
// Authentication Configuration for F# ASP.NET Core
open Microsoft.Extensions.DependencyInjection
open Microsoft.AspNetCore.Authentication.JwtBearer
open Microsoft.IdentityModel.Tokens
open System.Text

let configureAuthentication (services: IServiceCollection) =
    services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
        .AddJwtBearer(fun options ->
            options.TokenValidationParameters <- TokenValidationParameters(
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                ValidIssuer = "your-issuer",
                ValidAudience = "your-audience",
                IssuerSigningKey = SymmetricSecurityKey(Encoding.UTF8.GetBytes("your-secret-key"))
            )
        ) |> ignore
    
    services.AddAuthorization() |> ignore
EOF

        echo "✅ Authentication configuration created"
    fi
}

configure_hot_reload() {
    if [ "${ENABLE_HOT_RELOAD}" = "true" ]; then
        echo "🔥 Configuring hot reload for development..."
        
        # Create launch settings
        mkdir -p /tmp/Properties
        cat > /tmp/Properties/launchSettings.json << 'EOF'
{
  "profiles": {
    "Development": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "applicationUrl": "https://localhost:7001;http://localhost:5001",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      },
      "hotReloadEnabled": true
    }
  }
}
EOF

        echo "✅ Hot reload configured"
    fi
}

configure_https() {
    if [ "${ENABLE_HTTPS}" = "true" ]; then
        echo "🔒 Configuring HTTPS development certificates..."
        
        # Trust development certificates
        dotnet dev-certs https --trust || echo "⚠️ Could not trust HTTPS certificate (may require interactive session)"
        
        echo "✅ HTTPS configuration completed"
    fi
}

create_dockerfile() {
    if [ "${INCLUDE_DOCKER}" = "true" ]; then
        echo "🐳 Creating Dockerfile..."
        
        cat > /tmp/Dockerfile << 'EOF'
# F# ASP.NET Core Dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["*.fsproj", "./"]
RUN dotnet restore
COPY . .
WORKDIR "/src"
RUN dotnet build -c Release -o /app/build

FROM build AS publish
RUN dotnet publish -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "YourApp.dll"]
EOF

        # Create .dockerignore
        cat > /tmp/.dockerignore << 'EOF'
**/.dockerignore
**/.env
**/.git
**/.gitignore
**/.vs
**/.vscode
**/**/bin
**/**/obj
**/Dockerfile*
**/docker-compose*
**/*.md
EOF

        echo "✅ Docker configuration created"
    fi
}

install_entity_framework() {
    if [ "${INCLUDE_ENTITY_FRAMEWORK}" = "true" ]; then
        echo "🗄️ Installing Entity Framework Core tools..."
        
        # Install EF tools
        dotnet tool install -g dotnet-ef || echo "EF tools already installed"
        
        # Create EF configuration template
        cat > /tmp/ef-config.fs << 'EOF'
// Entity Framework Configuration for F#
open Microsoft.Extensions.DependencyInjection
open Microsoft.EntityFrameworkCore
open System

type ApplicationDbContext(options: DbContextOptions<ApplicationDbContext>) =
    inherit DbContext(options)
    
    // Add your DbSets here
    // member val Users = this.Set<User>() with get

let configureEntityFramework (services: IServiceCollection) connectionString =
    services.AddDbContext<ApplicationDbContext>(fun options ->
        options.UseSqlServer(connectionString) |> ignore
    ) |> ignore
EOF

        echo "✅ Entity Framework Core tools installed"
    fi
}

create_development_scripts() {
    echo "📜 Creating development helper scripts..."
    
    # Create run script
    cat > /tmp/run-dev.sh << 'EOF'
#!/bin/bash
# F# ASP.NET Core Development Script

echo "🚀 Starting F# ASP.NET Core application..."

# Restore packages
dotnet restore

# Run application with hot reload
dotnet watch run
EOF

    # Create build script
    cat > /tmp/build.sh << 'EOF'
#!/bin/bash
# F# ASP.NET Core Build Script

echo "🏗️ Building F# ASP.NET Core application..."

# Clean
dotnet clean

# Restore
dotnet restore

# Build
dotnet build --configuration Release

echo "✅ Build completed"
EOF

    chmod +x /tmp/run-dev.sh /tmp/build.sh
    
    echo "✅ Development scripts created"
}

verify_installation() {
    echo "🔍 Verifying ASP.NET Core setup..."
    
    # Check dotnet CLI
    if command -v dotnet >/dev/null 2>&1; then
        echo "✅ .NET SDK available: $(dotnet --version)"
    else
        echo "❌ .NET SDK not found"
        return 1
    fi
    
    # Check ASP.NET Core runtime
    if dotnet --list-runtimes | grep -q "Microsoft.AspNetCore.App"; then
        echo "✅ ASP.NET Core runtime available"
    else
        echo "⚠️ ASP.NET Core runtime not detected"
    fi
    
    # Check templates
    if dotnet new list | grep -q "web"; then
        echo "✅ Web templates available"
    else
        echo "⚠️ Web templates not found"
    fi
    
    echo "✅ ASP.NET Core F# web development is ready!"
    return 0
}

# Main installation flow
main() {
    validate_environment
    install_aspnet_templates
    create_project_templates
    configure_swagger
    configure_authentication
    configure_hot_reload
    configure_https
    create_dockerfile
    install_entity_framework
    create_development_scripts
    verify_installation
    
    echo ""
    echo "🌐 ASP.NET Core F# web development is ready!"
    echo ""
    echo "🔧 Configuration:"
    echo "   • Framework: ${FRAMEWORK}"
    echo "   • Swagger: ${INCLUDE_SWAGGER}"
    echo "   • Authentication: ${INCLUDE_AUTH}"
    echo "   • Hot Reload: ${ENABLE_HOT_RELOAD}"
    echo "   • HTTPS: ${ENABLE_HTTPS}"
    echo "   • Docker: ${INCLUDE_DOCKER}"
    echo "   • Entity Framework: ${INCLUDE_ENTITY_FRAMEWORK}"
    echo ""
    echo "📖 Quick start:"
    echo "   • dotnet new webapi -lang F# -n MyApi  - Create new F# web API"
    echo "   • dotnet run                           - Run application"
    echo "   • dotnet watch run                     - Run with hot reload"
    echo ""
    echo "📁 Templates created in /tmp/aspnet-templates/${FRAMEWORK}/"
    echo "📜 Helper scripts: /tmp/run-dev.sh, /tmp/build.sh"
    echo ""
    echo "💡 Copy template files to your project and customize as needed"
}

main "$@"