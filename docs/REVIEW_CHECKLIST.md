Reviewer checklist — Engineering Assessment: Automate Backend Deployment

Use this checklist when reviewing a candidate submission.

Services
- [ ] Unit tests present for both services and pass.
- [ ] Code is minimal, easy to understand, and well-organized.
- [ ] Dependencies are pinned and compatibility checks are present (e.g., `scripts/check_python_deps.sh`).

Docker
- [ ] Dockerfiles present for both services.
- [ ] Dockerfiles use small base images and avoid running as root where possible.

Terraform
- [ ] Terraform code validates with `terraform init -backend=false` and `terraform validate`.
- [ ] Sensitive variables are exposed as variables and marked `sensitive = true` where appropriate.
- [ ] Backend example or instructions provided for state storage and locking.

CI
- [ ] CI workflow runs unit tests for both services.
- [ ] CI workflow performs PR-safe Terraform checks (no credentials required).
- [ ] If plan posting is enabled, ensure secrets are required and not embedded in the PR.

Security
- [ ] No secrets committed to the repository.

Scoring guideline (optional)
- Functionality (30%), Security (25%), Code quality & tests (25%), Documentation & reproducibility (20%)
