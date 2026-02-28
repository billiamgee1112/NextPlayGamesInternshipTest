# Python Sample Service

This is a minimal Flask app used to test deployment automation.

Run locally:

- Install deps: python -m pip install -r requirements.txt
- Run: python app.py

Docker:
- Build: docker build -t python-app .
- Run: docker run -p 5000:5000 python-app

Tests:
- Run: pytest
