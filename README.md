# D365FO Copilot Code Review (Azure DevOps Extension)

Automated pull request code reviews for Azure DevOps pipelines, powered by the official GitHub Copilot CLI.

This extension is designed for gated PR validation in D365FO/X++ repositories and can classify findings as:

- `BLOCKING` (build-rejecting)
- `WARNING` (non-blocking)

## What it does

The pipeline task:

1. Detects PR/gated context and changed files.
2. Builds a structured prompt (including optional warning/blocking custom checks).
3. Runs GitHub Copilot CLI on the build agent.
4. Publishes a markdown review summary in the pipeline logs.
5. Fails the task when blocking findings are detected.

## Repository structure

- `d356foCodeReview/` → production task source and scripts.
- `d356foCodeReviewDevV1/` → packaged dev task payload.
- `images/` → marketplace icon assets.
- `vss-extension.json` → production extension manifest.
- `vss-extension.dev.json` → development extension manifest.

## Prerequisites

- Azure DevOps pipeline agent with Node.js support.
- PowerShell 7 (`pwsh`) available on the agent.
- GitHub PAT with Copilot access.
- For Azure DevOps Services (cloud): either
	- `useSystemAccessToken: true` plus mapped `SYSTEM_ACCESSTOKEN`, or
	- an explicit Azure DevOps PAT.
- For Azure DevOps Server (on-prem): Azure DevOps PAT is required.

The task auto-checks (and attempts to install) the Copilot CLI if missing.

## Quick start (YAML)

```yaml
trigger: none

pr:
	autoCancel: true
	branches:
		include:
			- main

pool:
	vmImage: ubuntu-latest

steps:
	- checkout: self
		fetchDepth: 0

	- task: d356foCodeReview@1
		displayName: D365FO Copilot Code Review (PR Gated)
		condition: eq(variables['Build.Reason'], 'PullRequest')
		inputs:
			githubPat: $(GITHUB_PAT)
			useSystemAccessToken: true
			timeout: '20'
		env:
			SYSTEM_ACCESSTOKEN: $(System.AccessToken)
```

## Key task inputs

Authentication and context:

- `githubPat` (required)
- `azureDevOpsPat` (optional in cloud, required on-prem)
- `useSystemAccessToken` (optional, cloud only)
- `organization`, `collectionUri`, `project`, `repository`

Runtime:

- `timeout`
- `model`
- `authors` (optional author filter)

Prompt options:

- Legacy:
	- `prompt`
	- `promptFile`
- Split checks:
	- `warningPrompt` / `warningPromptFile`
	- `blockingPrompt` / `blockingPromptFile`
- Raw mode:
	- `promptRaw`
	- `promptFileRaw`

Important: legacy prompt inputs cannot be combined with split warning/blocking inputs.

## Warning vs Blocking behavior

- Any `BLOCKING` finding must produce `REJECTED` and fail the task.
- If only `WARNING` findings exist, result is `ACCEPTED`.
- If no findings exist, result is `ACCEPTED`.
- If scope cannot be validated, result is `REJECTED`.

## Build and packaging

From repository root:

```bash
npm install
cd d356foCodeReview
npm install
cd ..
```

Production package:

```bash
npm run build
npm run package:prod
```

Development package:

```powershell
npm run package:dev
```

This generates a `.vsix` extension package using the selected manifest.

## Publishing notes

- Ensure `images/extension-icon.png` exists (minimum 128x128).
- Keep version values aligned across:
	- root `package.json`
	- `d356foCodeReview/package.json`
	- `d356foCodeReview/task.json`
	- `vss-extension.json` and `vss-extension.dev.json`

The repository includes `scripts/bump-version.js` and npm scripts to automate version bump + build flow.

## License

GPL-3.0 (repository level).
