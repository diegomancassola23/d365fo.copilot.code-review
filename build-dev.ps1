<#
.SYNOPSIS
    Builds and packages the dev extension for testing.

.DESCRIPTION
    This script builds the TypeScript source, copies the compiled output and dependencies
    to the dev task folder, and packages the dev extension.

.EXAMPLE
    .\build-dev.ps1
    Builds and packages the dev extension.

.EXAMPLE
    .\build-dev.ps1 -SkipBuild
    Packages the dev extension without rebuilding (uses existing compiled files).

.NOTES
    Author: Little Fort Software
    Date: December 2025
#>

[CmdletBinding()]
param(
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot
$prodTaskDir = Join-Path $repoRoot "d356foCodeReview"
$devTaskDir = Join-Path $repoRoot "d356foCodeReviewDevV1"

if (Test-Path $devTaskDir) {
    $devTaskItem = Get-Item $devTaskDir
    if (-not $devTaskItem.PSIsContainer) {
        Remove-Item $devTaskDir -Force
        New-Item -ItemType Directory -Path $devTaskDir -Force | Out-Null
    }
}
else {
    New-Item -ItemType Directory -Path $devTaskDir -Force | Out-Null
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Building Dev Extension" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n[Version] Incrementing extension/task version..." -ForegroundColor Yellow
node (Join-Path $repoRoot "scripts\bump-version.js")
if ($LASTEXITCODE -ne 0) {
    throw "Version bump failed"
}

# Step 1: Build TypeScript (unless skipped)
if (-not $SkipBuild) {
    Write-Host "`n[Step 1/4] Building TypeScript..." -ForegroundColor Yellow
    Push-Location $prodTaskDir
    try {
        npm run build
        if ($LASTEXITCODE -ne 0) {
            throw "TypeScript build failed"
        }
    }
    finally {
        Pop-Location
    }
    Write-Host "TypeScript build completed." -ForegroundColor Green
}
else {
    Write-Host "`n[Step 1/4] Skipping TypeScript build (using existing files)." -ForegroundColor Yellow
}

# Step 2: Copy compiled files to dev task folder
Write-Host "`n[Step 2/4] Copying files to dev task folder..." -ForegroundColor Yellow

# Copy task.json
$taskJson = Join-Path $prodTaskDir "task.json"
if (Test-Path $taskJson) {
    $devTaskJson = Join-Path $devTaskDir "task.json"
    Copy-Item $taskJson -Destination $devTaskJson -Force
    Write-Host "  Copied: task.json" -ForegroundColor Gray
}
else {
    throw "task.json not found in d356foCodeReview."
}

# Copy index.js
$indexJs = Join-Path $prodTaskDir "index.js"
if (Test-Path $indexJs) {
    $devIndexJs = Join-Path $devTaskDir "index.js"
    Copy-Item $indexJs -Destination $devIndexJs -Force
    Write-Host "  Copied: index.js" -ForegroundColor Gray
}
else {
    throw "index.js not found. Run build first."
}

# Copy scripts folder
$scriptsDir = Join-Path $prodTaskDir "scripts"
$devScriptsDir = Join-Path $devTaskDir "scripts"
if (Test-Path $scriptsDir) {
    if (Test-Path $devScriptsDir) {
        Remove-Item $devScriptsDir -Recurse -Force
    }
    Copy-Item $scriptsDir -Destination $devTaskDir -Recurse -Force
    Write-Host "  Copied: scripts/" -ForegroundColor Gray
}

# Copy node_modules folder
$nodeModulesDir = Join-Path $prodTaskDir "node_modules"
$devNodeModulesDir = Join-Path $devTaskDir "node_modules"
if (Test-Path $nodeModulesDir) {
    if (Test-Path $devNodeModulesDir) {
        Remove-Item $devNodeModulesDir -Recurse -Force
    }
    Copy-Item $nodeModulesDir -Destination $devTaskDir -Recurse -Force
    Write-Host "  Copied: node_modules/" -ForegroundColor Gray
}
else {
    throw "node_modules not found. Run 'npm install' in d356foCodeReview first."
}

Write-Host "Files copied to dev task folder." -ForegroundColor Green

# Step 3: Install tfx-cli if not present
Write-Host "`n[Step 3/4] Checking tfx-cli installation..." -ForegroundColor Yellow
$tfxInstalled = Get-Command tfx -ErrorAction SilentlyContinue
if (-not $tfxInstalled) {
    Write-Host "Installing tfx-cli globally..." -ForegroundColor Gray
    npm install -g tfx-cli
}
else {
    Write-Host "tfx-cli is already installed." -ForegroundColor Gray
}

# Step 4: Package the dev extension
Write-Host "`n[Step 4/4] Packaging dev extension..." -ForegroundColor Yellow
Push-Location $repoRoot
try {
    tfx extension create --manifest-globs vss-extension.dev.json
    if ($LASTEXITCODE -ne 0) {
        throw "Extension packaging failed"
    }
}
finally {
    Pop-Location
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Dev extension packaged successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nNext steps:" -ForegroundColor White
Write-Host "1. Upload the .vsix file to the Marketplace management portal" -ForegroundColor Gray
Write-Host "2. Share the extension with your test organization" -ForegroundColor Gray
Write-Host "3. Install and test in your pipelines using 'd356foCodeReview@0'" -ForegroundColor Gray
