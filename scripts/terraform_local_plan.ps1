<#
PowerShell helper to run terraform validate and optionally terraform plan locally.
Usage:
  .\scripts\terraform_local_plan.ps1           # run init -backend=false and validate
  .\scripts\terraform_local_plan.ps1 -Plan     # run full init, plan and write plan.txt (requires AWS env vars)

Note: Do NOT hardcode credentials. Export them in your shell before running the script:
  $env:AWS_ACCESS_KEY_ID = '<id>' ; $env:AWS_SECRET_ACCESS_KEY = '<secret>' ; $env:AWS_DEFAULT_REGION = 'us-east-1'
#>
param(
    [switch]$Plan
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$tfDir = Join-Path -Path $PSScriptRoot -ChildPath "..\infra\terraform\aws" | Resolve-Path -Relative
Write-Host "Terraform directory: $tfDir"

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Error "terraform not found in PATH. Install Terraform or add it to PATH.";
    exit 1
}

Push-Location $tfDir
try {
    Write-Host "Running: terraform init -backend=false"
    terraform init -backend=false -input=false

    Write-Host "Running: terraform validate"
    terraform validate

    if ($Plan) {
        if (-not $env:AWS_ACCESS_KEY_ID -or -not $env:AWS_SECRET_ACCESS_KEY -or -not $env:AWS_DEFAULT_REGION) {
            Write-Error "AWS env vars missing. Set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_DEFAULT_REGION to run plan.";
            exit 2
        }

        Write-Host "Running: terraform init (with backend)"
        terraform init -input=false

        Write-Host "Running: terraform plan -out=tfplan"
        terraform plan -out=tfplan -input=false

        Write-Host "Exporting plan to plan.txt"
        terraform show -no-color tfplan | Out-File -FilePath plan.txt -Encoding utf8

        Write-Host "Plan written to: $(Join-Path (Get-Location) 'plan.txt')"
    }
} finally {
    Pop-Location
}

Write-Host "Done."
exit 0
