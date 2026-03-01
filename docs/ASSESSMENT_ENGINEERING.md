# Automating Backend Deployment — Personal Project

Purpose

This repository is a personal project that demonstrates a minimal, safe automation pipeline for building, testing, and validating backend services and the Terraform infrastructure that would deploy them. It was developed as a learning/demo project and is not intended as a public candidate assessment.

Overview

The project shows how to:
- Run unit tests for small services (Python Flask and Node TypeScript).
- Containerize services with Docker and publish images from CI.
- Provide a Terraform skeleton that validates in CI without cloud credentials.
- Protect destructive or credentialed operations behind manual, protected workflows.

What’s included

- services/python_app — minimal Flask app, tests, Dockerfile.
- services/node_app — minimal Express TypeScript app, tests, Dockerfile.
- infra/terraform — Terraform skeletons (aws, backend_bootstrap) and variables.
- .github/workflows — CI that runs tests, builds/pushes images, PR-safe Terraform validate, and a manual protected apply workflow.
- scripts/ — helper scripts: backend bootstrap and local Terraform helpers.

How to use this repo (quick)

1. Run service tests (PowerShell):
   - Python: `cd .\services\python_app; python -m pip install -r requirements.txt; python -m pytest -q`
   - Node: `cd .\services\node_app; npm ci; npm run dev &; npx wait-on http://localhost:3000; npm test`

2. Validate Terraform locally (no cloud credentials required):
   - `cd .\infra\terraform\aws`
   - `terraform init -backend=false`
   - `terraform validate`

3. (Optional) Bootstrap a remote backend (one-time; requires AWS credentials):
   - Export AWS creds in PowerShell:
     `$env:AWS_ACCESS_KEY_ID = '<id>' ; $env:AWS_SECRET_ACCESS_KEY = '<secret>' ; $env:AWS_DEFAULT_REGION = 'us-east-1'`
   - Run the bootstrap script to create S3 + DynamoDB for Terraform state:
     `.\scripts\bootstrap_backend.ps1 -BucketName <unique> -DynamoTable <unique>`
   - Review `infra/terraform/aws/backend.tf` (the script backs up any existing file). Do not commit credentials.

4. Demonstrate the end-to-end flow (manual protected apply):
   - Push a branch / open a PR — CI will run tests and build images, pushing them to GHCR.
   - In Actions, run `Terraform Apply (protected)` and provide the `python_image` and `node_image` URIs produced by CI.
   - Approve the protected environment when prompted; the workflow will run plan, apply, and a post-apply smoke test against the ALB.

Notes and caveats

- This project is a demo. The Terraform configuration and IAM policies are intentionally minimal and require hardening before any real production use (least-privilege IAM, parameterization, secure networking, state lifecycle, and reviews).
- Do NOT store cloud credentials in the repository. Use repository secrets for CI and protected environments for manual applies.
- The repository includes helper examples: `infra/terraform/backend_bootstrap` (S3 + DynamoDB) and `scripts/validate_all.ps1` / `scripts/terraform_local_plan.ps1` for local validation.

If you want, I can produce a short CONTRIBUTING.md with exact commands and a one-page summary for sharing the demo. Let me know which format you prefer.
