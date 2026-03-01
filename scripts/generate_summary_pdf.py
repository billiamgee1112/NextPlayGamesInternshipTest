from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.lib.units import inch

doc_path = "docs/PROJECT_SUMMARY.pdf"

def build_pdf(path):
    doc = SimpleDocTemplate(path, pagesize=letter,
                            rightMargin=72, leftMargin=72,
                            topMargin=72, bottomMargin=72)
    styles = getSampleStyleSheet()
    story = []

    title = Paragraph("Deployment Automation — Project Summary", styles['Title'])
    story.append(title)
    story.append(Spacer(1, 12))

    intro = Paragraph(
        "This is a compact demo project that demonstrates an automated pipeline for building, testing, and validating backend services and Terraform infrastructure. It is safe to run for local review and does not require cloud credentials for PR validation.",
        styles['Normal'])
    story.append(intro)
    story.append(Spacer(1, 12))

    sections = [
        ("What’s included",
         "- Two minimal services: services/python_app (Flask) and services/node_app (TypeScript + Express), each with unit tests and Dockerfiles.\n"
         "- Terraform skeletons under infra/terraform and a backend_bootstrap module for S3 + DynamoDB.\n"
         "- GitHub Actions workflows: tests, PR-safe terraform validate, image build/push, and a protected apply workflow.\n"
         "- Helper scripts to validate and bootstrap Terraform locally.") ,

        ("Quick local steps", 
         "1) Run Python tests: cd services/python_app; python -m pip install -r requirements.txt; python -m pytest -q\n"
         "2) Run Node tests: cd services/node_app; npm ci; npm run dev &; npx wait-on http://localhost:3000; npm test\n"
         "3) Validate Terraform: cd infra/terraform/aws; terraform init -backend=false; terraform validate") ,

        ("MVP end-to-end demo", 
         "1) Optionally bootstrap remote backend (one-time) using scripts/bootstrap_backend.ps1 to create S3 + DynamoDB.\n"
         "2) Push a branch / open a PR — CI will run tests and build images to GHCR.\n"
         "3) Run the protected apply workflow (Actions -> Terraform Apply (protected)) and provide python_image/node_image URIs from CI.\n"
         "4) After apply completes, retrieve ALB DNS from terraform outputs and verify /python and /node endpoints.") ,

        ("Security & Caveats",
         "- Do NOT commit cloud credentials to the repository. Use repository secrets for CI and protected environment approvals.\n"
         "- Terraform and IAM examples are minimal; harden before any production use (least privilege, secure networking, state lifecycle).\n"
         "- The protected apply workflow performs a post-apply smoke test against the ALB.")
    ]

    for heading, text in sections:
        story.append(Paragraph(heading, styles['Heading2']))
        # preserve newlines
        for line in text.split("\\n"):
            story.append(Paragraph(line, styles['Normal']))
        story.append(Spacer(1, 12))

    doc.build(story)

if __name__ == '__main__':
    import os
    out_dir = os.path.dirname(doc_path)
    os.makedirs(out_dir, exist_ok=True)
    build_pdf(doc_path)
    print(f"Wrote PDF to: {doc_path}")
