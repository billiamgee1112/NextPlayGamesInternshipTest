# Deployment Automation Internship Project

This workspace contains templates and example code to automate backend deployment for a sample application. It includes:

- Terraform modules for AWS and Azure (skeletons)
- Dockerfiles and Docker Compose for local testing
- GitHub Actions workflows for build, test, and deploy
- Two example services: a Python Flask app and a Node.js TypeScript app
- VS Code tasks for common operations
- Documentation and unit test templates

Choose a service to develop and run deployments using the infra templates. Follow the README sections for setup.

## Quick start
1. Pick a service: `services/python_app` or `services/node_app`.
2. Follow the service README for local dev.
3. Configure cloud credentials and secrets before running Terraform.

For more details see the `docs` folder.

## CI & Terraform (required secrets)

The GitHub Actions workflow runs unit tests and performs a Terraform plan. To allow the workflow to run a full Terraform init/plan on pushes to protected branches, set the following repository secrets (do NOT store credentials in the repo):

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_DEFAULT_REGION`

For pull requests the workflow runs a PR-safe terraform flow (terraform init -backend=false, validate, and terraform plan -refresh=false) which does not require these secrets.

Local testing tips:

- Run the Python service tests:
  - python -m pip install -r services/python_app/requirements.txt
  - cd services/python_app && python -m pytest -q

- Run the Node service tests (dev server must be running for tests):
  - cd services/node_app
  - npm ci
  - npm run dev &
  - npx wait-on http://localhost:3000
  - npm test

- To run Terraform plan locally without affecting remote state:
  - cd infra/terraform/aws
  - terraform init -backend=false
  - terraform validate
  - terraform plan -refresh=false -input=false
