# Deployment Automation Internship Project

This repository contains a compact, runnable scaffold that demonstrates how to build, test, and validate a backend service and the Terraform infrastructure that would deploy it. It is intended as an engineering assessment — safe to run for review and local testing without cloud credentials.

What’s included
- Two minimal services: `services/python_app` (Flask) and `services/node_app` (TypeScript + Express), each with unit tests and Dockerfiles.
- Terraform skeletons under `infra/terraform` and a small backend bootstrap module to create remote state (S3 + DynamoDB).
- GitHub Actions workflows that run tests, validate Terraform in PRs, build container images, and a protected manual apply workflow.
- Helper scripts to validate and bootstrap Terraform locally.

Quick start (local, PowerShell)
1. Run service tests:
   - Python: `cd .\services\python_app; python -m pip install -r requirements.txt; python -m pytest -q`
   - Node: `cd .\services\node_app; npm ci; npm run dev &; npx wait-on http://localhost:3000; npm test`
2. Validate Terraform (no cloud creds required):
   - `cd .\infra\terraform\aws; terraform init -backend=false; terraform validate`
3. (Optional) Bootstrap remote state (one-time, requires AWS creds):
   - Export AWS creds in PowerShell: `$env:AWS_ACCESS_KEY_ID='<id>' ; $env:AWS_SECRET_ACCESS_KEY='<secret>' ; $env:AWS_DEFAULT_REGION='us-east-1'`
   - Run `.\scripts\bootstrap_backend.ps1 -BucketName <unique> -DynamoTable <unique>` and review `infra/terraform/aws/backend.tf`.

MVP demo (end-to-end)
1. Create remote backend (optional, one-time) using the bootstrap script above.
2. Push a branch and open a PR — CI will run tests and build images, pushing them to GitHub Container Registry.
3. In Actions, run the `Terraform Apply (protected)` workflow.
   - Provide the `python_image` and `node_image` URIs from the build job as inputs.
   - Approve the protected environment when prompted to allow the apply.
4. After apply completes, obtain the ALB DNS (terraform output) and verify `/python` and `/node` endpoints.

Security note
- Do NOT commit secrets. Use repository secrets for CI (AWS and registry credentials) and a protected environment for apply approvals.

More details and assessment instructions: `docs/ASSESSMENT_ENGINEERING.md`.
