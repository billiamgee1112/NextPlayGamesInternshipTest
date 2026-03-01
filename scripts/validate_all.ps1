<#
Run terraform init -backend=false and validate for all terraform folders in infra/terraform.
Usage: powershell -File .\scripts\validate_all.ps1
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = Join-Path -Path $PSScriptRoot -ChildPath "..\infra\terraform" | Resolve-Path -Relative
$folders = @(
    "backend_bootstrap",
    "aws"
)

foreach ($f in $folders) {
    $path = Join-Path -Path $root -ChildPath $f
    Write-Host "\n=== Validating $path ==="
    Push-Location $path
    try {
        if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
            Write-Error "terraform not found in PATH. Install Terraform or add it to PATH.";
            exit 1
        }
        terraform init -backend=false -input=false
        terraform validate
    } finally {
        Pop-Location
    }
}

Write-Host "All terraform folders validated."
