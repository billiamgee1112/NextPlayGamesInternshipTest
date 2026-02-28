Security checklist:

- Do not store secrets in repo. Use environment variables or secret managers (AWS Secrets Manager, Azure Key Vault, GitHub Secrets).
- Use least privilege IAM roles for resources.
- Enable TLS for services.
- Rotate credentials regularly.
- Scan images for vulnerabilities before deploy.
