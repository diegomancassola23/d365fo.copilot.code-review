# D365FO Copilot Code Review for Azure DevOps Pipelines

This extension adds an AI-assisted code review task to Azure DevOps pipelines for D365FO/X++ projects.

It is designed for end users who want to catch X++ best-practice and performance issues earlier, directly during gated check-in / PR validation.

## Why teams use it

In many projects, code review happens late and performance or scalability issues are discovered only after code reaches shared branches.

This task shifts review left:

- analyzes changed code during pipeline validation,
- classifies findings as warning or blocking,
- fails the build when critical issues are detected.

## How it works (high level)

1. A gated check-in / PR pipeline is triggered.
2. The pipeline runs the D365FO Copilot Code Review task.
3. The task invokes Copilot CLI and evaluates changed X++ scope.
4. The task returns ACCEPTED or REJECTED based on configured checks.

If blocking findings are detected, the pipeline is rejected.

## Install the extension

Install from Azure DevOps Marketplace:

- Dev listing: https://marketplace.visualstudio.com/items?itemName=DiegoMancassola.d365fo-copilot-code-review-dev

Then open Azure DevOps Organization Settings > Extensions and verify installation.

## Add the task to your pipeline

You can configure it in Classic editor or YAML.

## Task settings (UI labels)

### Required / authentication

- GitHub PAT: required token used to authenticate Copilot CLI.
- Azure DevOps PAT: optional in cloud, required on Azure DevOps Server (on-prem).
- Use System Access Token: recommended in Azure DevOps Services (cloud) instead of ADO PAT.

### Context settings

- Organization: Azure DevOps organization name.
- Collection URI: full collection URL (important for on-prem).
- Project: target project (default: $(System.TeamProject)).
- Repository: target repository (default: $(Build.Repository.Name)).

### Runtime settings

- Timeout (minutes): max review duration (default: 15).
- Copilot Model: optional model override.
- Author Filter: comma-separated emails to limit execution to specific PR authors.

### Prompt settings

- Custom Prompt File / Custom Prompt (legacy mode).
- Warning Checks Prompt / Warning Checks Prompt File (non-blocking checks).
- Blocking Checks Prompt / Blocking Checks Prompt File (build-blocking checks).
- Raw Prompt / Raw Prompt File (advanced direct mode).

## Prompt strategy (important)

Use one prompt mode per run:

- Legacy mode: Custom Prompt or Custom Prompt File
- Split mode: Warning Checks + Blocking Checks
- Raw mode: Raw Prompt or Raw Prompt File

Do not combine legacy mode with warning/blocking mode.

## Recommended warning vs blocking setup

- Warning Checks Prompt: style/maintainability findings with no runtime impact.
- Blocking Checks Prompt: performance/reliability/security findings with real runtime impact.

Typical policy:

- warning only -> ACCEPTED
- any blocking finding -> REJECTED

## Output behavior

The task writes a structured markdown review in pipeline logs and sets the task result accordingly:

- ACCEPTED: no blocking violations
- REJECTED: at least one blocking violation (or invalid review scope)

## Public repository note

This repository is public mainly as transparency/reference for teams and contributors who want to extend the component.

For day-to-day usage, focus on Marketplace installation and pipeline configuration.
