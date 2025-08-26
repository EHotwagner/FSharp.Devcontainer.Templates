#!/bin/bash
set -euo pipefail

# Feature options from environment variables
FRAMEWORK=${FRAMEWORK:-"xunit"}
INCLUDE_COVERAGE=${INCLUDECOVERAGE:-"true"}
INCLUDE_PROPERTY_TESTING=${INCLUDEPROPERTYBASED:-"false"}

echo "Installing F# testing tools (framework: ${FRAMEWORK})..."

# Install testing project templates
case "${FRAMEWORK}" in
    "xunit")
        echo "Installing xUnit templates..."
        dotnet new install "Microsoft.DotNet.Test.ProjectTemplates.2.1"
        ;;
    "expecto")
        echo "Installing Expecto templates..."
        dotnet new install "Expecto.Template"
        ;;
    "both")
        echo "Installing both xUnit and Expecto templates..."
        dotnet new install "Microsoft.DotNet.Test.ProjectTemplates.2.1"
        dotnet new install "Expecto.Template"
        ;;
esac

# Install code coverage tools if requested
if [ "${INCLUDE_COVERAGE}" = "true" ]; then
    echo "Installing code coverage tools..."
    dotnet tool install -g dotnet-reportgenerator-globaltool
    dotnet tool install -g coverlet.console
    
    # Create coverage script
    cat > /usr/local/bin/run-coverage << 'EOF'
#!/bin/bash
# Run tests with coverage and generate HTML report
dotnet test --collect:"XPlat Code Coverage" --settings coverage.runsettings
reportgenerator -reports:"**/coverage.cobertura.xml" -targetdir:"coverage-report" -reporttypes:Html
echo "Coverage report generated in coverage-report/index.html"
EOF
    chmod +x /usr/local/bin/run-coverage
    
    # Create basic coverage settings
    cat > /tmp/coverage.runsettings << 'EOF'
<?xml version="1.0" encoding="utf-8" ?>
<RunSettings>
  <DataCollectionRunSettings>
    <DataCollectors>
      <DataCollector friendlyName="XPlat code coverage" uri="datacollector://Microsoft/CodeCoverage/2.0" assemblyQualifiedName="Microsoft.CodeCoverage.CoreDataCollector, Microsoft.CodeCoverage, Version=16.9.4.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a">
        <Configuration>
          <Format>cobertura</Format>
          <Exclude>[*.Tests]*</Exclude>
        </Configuration>
      </DataCollector>
    </DataCollectors>
  </DataCollectionRunSettings>
</RunSettings>
EOF
    echo "Created coverage.runsettings template at /tmp/coverage.runsettings"
fi

# Install FsCheck if requested
if [ "${INCLUDE_PROPERTY_TESTING}" = "true" ]; then
    echo "Installing FsCheck templates..."
    # FsCheck doesn't have official templates, but we can create a helper script
    cat > /usr/local/bin/create-fscheck-test << 'EOF'
#!/bin/bash
# Creates a basic FsCheck test file
cat > Properties.fs << 'FSEOF'
module Properties

open FsCheck
open Xunit

[<Fact>]
let ``Addition is commutative`` () =
    let property (x: int) (y: int) = x + y = y + x
    Check.Quick property

[<Fact>]
let ``Reverse twice is identity`` () =
    let property (xs: int list) = List.rev (List.rev xs) = xs
    Check.Quick property
FSEOF
echo "Created Properties.fs with example FsCheck tests"
EOF
    chmod +x /usr/local/bin/create-fscheck-test
fi

# Verify installations
echo "✅ F# testing tools installed successfully"

echo "📋 Available commands:"
case "${FRAMEWORK}" in
    "xunit"|"both")
        echo "  - dotnet new xunit -lang F# -o MyTests (create xUnit test project)"
        ;;
esac
case "${FRAMEWORK}" in
    "expecto"|"both")
        echo "  - dotnet new expecto -o MyTests (create Expecto test project)"
        ;;
esac

if [ "${INCLUDE_COVERAGE}" = "true" ]; then
    echo "  - run-coverage (run tests with coverage report)"
fi

if [ "${INCLUDE_PROPERTY_TESTING}" = "true" ]; then
    echo "  - create-fscheck-test (create FsCheck property test template)"
fi

echo "🧪 F# testing environment is ready!"