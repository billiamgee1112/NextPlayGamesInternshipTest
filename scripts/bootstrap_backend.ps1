<#
Bootstrap Terraform backend helper

Usage (PowerShell):
  .\scripts\bootstrap_backend.ps1 -BucketName my-unique-bucket-123 -DynamoTable my-locks -Region us-east-1
  Add -NoWriteBackend to skip writing `infra/terraform/aws/backend.tf`.

This script runs `terraform init` and `terraform apply` for the backend_bootstrap module.
It can optionally write a populated backend.tf for `infra/terraform/aws` using outputs from the module.
It does NOT store credentials; you must set AWS env vars before running.

Do NOT commit credentials to source control. Use repository secrets in CI.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$BucketName,

    [Parameter(Mandatory=$true)]
    [string]$DynamoTable,

    [string]$Region = 'us-east-1',

    [switch]$PreventDestroy,

    # When present, do NOT write the populated backend.tf file into infra/terraform/aws.
    [switch]$NoWriteBackend
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Error "terraform not found in PATH. Install Terraform or add it to PATH.";
    exit 1
}

if (-not $env:AWS_ACCESS_KEY_ID -or -not $env:AWS_SECRET_ACCESS_KEY) {
    Write-Warning "AWS environment variables not found. Please export AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY before running this script."
}

$modulePath = Join-Path -Path $PSScriptRoot -ChildPath "..\infra\terraform\backend_bootstrap" | Resolve-Path -Relative
Push-Location $modulePath
try {
    Write-Host "Initializing Terraform in $modulePath"
    terraform init -input=false

    $prevent = $PreventDestroy.IsPresent ? 'true' : 'false'

    Write-Host "Applying backend bootstrap with bucket='$BucketName' dynamodb_table='$DynamoTable' region='$Region' prevent_destroy=$prevent"
    terraform apply -auto-approve -input=false -var "bucket_name=$BucketName" -var "dynamodb_table_name=$DynamoTable" -var "region=$Region" -var "prevent_destroy=$prevent"

    Write-Host "Bootstrap complete. Outputs:" 
    terraform output

    # Read outputs as JSON to populate backend.tf
    try {
        $outputsJsonRaw = terraform output -json
        $outputs = $outputsJsonRaw | ConvertFrom-Json
    } catch {
        Write-Warning "Failed to read terraform outputs as JSON. Skipping backend.tf write.";
        return
    }

    $bucketOut = $null
    $dynamoOut = $null

    if ($outputs.PSObject.Properties.Name -contains 'bucket_name') {
        $bucketOut = $outputs.bucket_name.value
    }
    if ($outputs.PSObject.Properties.Name -contains 'dynamodb_table') {
        $dynamoOut = $outputs.dynamodb_table.value
    }

    if (-not $bucketOut) {
        Write-Warning "No 'bucket_name' output found from the bootstrap module. Skipping backend.tf write.";
        return
    }

    if ($NoWriteBackend.IsPresent) {
        Write-Host "-NoWriteBackend specified; skipping writing infra/terraform/aws/backend.tf"
        return
    }

    # Build backend.tf content
    $backendContent = @"terraform {
  backend "s3" {
    bucket         = "$bucketOut"
    key            = "project/terraform.tfstate"
    region         = "$Region"
    dynamodb_table = "${dynamoOut}"
    encrypt        = true
  }
}
"@

    $targetPath = Join-Path -Path $PSScriptRoot -ChildPath "..\infra\terraform\aws\backend.tf" | Resolve-Path -Relative
    $absTarget = Join-Path -Path (Get-Location) -ChildPath $targetPath

    # Backup existing backend.tf if present
    $fullTargetPath = Resolve-Path -Path $absTarget -ErrorAction SilentlyContinue
    if ($fullTargetPath) {
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $backupPath = "$absTarget.bak.$timestamp"
        Copy-Item -Path $absTarget -Destination $backupPath -Force
        Write-Host "Existing backend.tf backed up to: $backupPath"
    }

    # Ensure directory exists
    $dir = Split-Path -Path $absTarget -Parent
    if (-not (Test-Path -Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }

    # Write the backend file
    Write-Host "Writing populated backend.tf to: $absTarget"
    $backendContent | Out-File -FilePath $absTarget -Encoding utf8 -Force

    Write-Host "Wrote backend.tf. Review the file before committing. Do NOT commit credentials."

} finally {
    Pop-Location
}

Write-Host "Done."
