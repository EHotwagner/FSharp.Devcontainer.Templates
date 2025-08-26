# Agent Guidelines: Devcontainer Template Repository (.NET / F# Focus)

This repository's purpose: build and refine reusable Devcontainer templates (primarily .NET and F#) plus supporting research notes. Agents should prioritize creating high‑quality, configurable development container templates and related automation.

## Core Objectives
- Provide opinionated yet flexible .NET / F# devcontainers.
- Support template options (e.g., .NET version, ASP.NET Core inclusion, Fantomas, Paket).
- Ensure fast startup, reproducibility, and developer ergonomics (linting, formatting, testing tools installed).
- Maintain documentation describing application and publication of templates.
- Perform lightweight online research (via opencode.ai fetch capability) to validate best practices, versions, and upstream changes (e.g., new .NET SDK releases, devcontainer spec updates).

## Recommended Template Components
- devcontainer-template.json (metadata & options).
- .devcontainer/devcontainer.json (features, extensions, postCreate hooks).
- scripts/ (post-create, dependency install, validation utilities).
- Sample projects demonstrating usage (e.g., minimal F# console app, ASP.NET Core web app).

## Development Workflow (Agent Actions)
1. Design / update template structure (align with Research/DevcontainerTemplates.md guidance).
2. Add or adjust options (dotnetVersion, includeAspNetCore, includeFantomas, etc.).
3. Configure features list (use official dotnet feature as base, add custom features as needed).
4. Update VS Code extension list (C#, Ionide, test explorer, formatting tools).
5. Add / refine post-create script (restore, create sample project, install templates, set hooks).
6. Validate template with `devcontainer templates validate` (document command usage—actual execution may depend on environment tooling availability).
7. Provide README guidance: apply template, pass options, start container, common commands.
8. Version and prepare for publishing (semantic version tags once repository matures).

## Code & Config Style
- Pin explicit versions (avoid `latest` in production templates).
- Use feature-based approach with the official devcontainers/features/dotnet as base dependency.
- Prefer .NET SDK 8.0 (current LTS version). Track new SDK releases using online research before updating.
- Keep scripts idempotent (safe on re-run). Use checks before installing or generating.
- Provide informative echo statements in scripts (plain UTF-8, minimal emojis for portability).

## Online Research Usage (opencode.ai)
Agents may fetch public web pages to:
- Confirm current stable .NET SDK versions.
- Check Fantomas / Paket latest versions or breaking changes.
- Review Devcontainer spec evolution (containers.dev announcements).
When researching, capture source URL and date accessed inside commit messages or documentation updates if version bumps are performed.

## Quality Checklist Before Committing
- Metadata file validates (well-formed JSON, required fields present: id, version, name, description, options).
- devcontainer.json: features resolve, extension IDs valid, postCreateCommand path correct.
- Feature install scripts are implemented and functional.
- Scripts executable (add `chmod +x` note if needed) and shell-safe (`set -euo pipefail` recommended for future hardening).
- Sample F# project builds (`dotnet build`) and runs (`dotnet run`) inside container (document expected commands even if not executed here).
- Documentation references correct template IDs and option keys.

## Features Development (Combinable Components)
- Create reusable features in `features/src/` for mix-and-match capability across templates.
- Each feature should have `devcontainer-feature.json` (metadata + options) and `install.sh` (installation script).
- Use `dependsOn` / `installsAfter` for feature dependency management.
- Test features individually: `devcontainer features test ./features/src/feature-name`.
- Publish features separately for community reuse: `devcontainer features publish`.

## Expansion Roadmap (Future Tasks)
- Add ionide-extensions feature (VS Code F# extensions bundle).
- Add dotnet-tools feature (global .NET CLI tools: EF, outdated, etc.).
- Add aspnet-templates feature (web project templates, Giraffe, etc.).
- Introduce GitHub Actions workflow to lint template/feature JSON and attempt dry-run builds.
- Add additional language variants (C# focused, minimal runtime, slim test runner) as separate templates.
- Provide performance metrics (cold build time, container size) in README once measured.

## Commit Message Guidance
Use conventional, purpose-driven phrasing focusing on why:
- feat(template): add Fantomas option for F# formatting
- feat(feature): add paket package manager feature
- chore(deps): pin .NET SDK to 8.0 for stability
- docs: clarify template apply vs container startup sequence

Include research note lines when external version info prompts a change:
- research: confirmed .NET 8.0 as current LTS (MS release notes URL)

## Safety & Security
- Avoid embedding secrets or tokens in templates or scripts.
- Do not auto-run untrusted remote scripts (prefer package managers / official instructions).
- Keep tool installations deterministic (explicit versions where supported).

## When Using Online Research
Always:
- Prefer primary sources (Microsoft release notes, official GitHub repositories).
- Cross-check at least two sources for critical version/security info if feasible.
- Record date accessed in doc updates for longevity.

## Minimal Example (Reference)
(Simplified snippets—full examples in Research/DevcontainerTemplates.md)

### Template with Features
```
.devcontainer/devcontainer.json
{
  "name": ".NET F# Template",
  "features": {
    "ghcr.io/devcontainers/features/dotnet:2": { "version": "8.0" },
    "./features/src/fantomas": { "enableEditorConfig": true },
    "./features/src/fsharp-testing": { "framework": "xunit", "includeCoverage": true }
  },
  "customizations": { "vscode": { "extensions": ["ms-dotnettools.csharp", "ionide.ionide-fsharp"] } },
  "postCreateCommand": "bash .devcontainer/scripts/post-create.sh",
  "remoteUser": "vscode"
}
```

### Feature Structure
```
features/src/fantomas/
├── devcontainer-feature.json
└── install.sh
```

## Agent Priorities Summary
1. Maintain template correctness & clarity.
2. Keep .NET / F# tooling current (using verified research).
3. Develop reusable features for mix-and-match capability.
4. Optimize developer experience (speed, formatting, testing).
5. Document thoroughly and concisely.
6. Automate validation steps where possible.

Agents should now treat this file as the canonical operational guide for repository contributions.
