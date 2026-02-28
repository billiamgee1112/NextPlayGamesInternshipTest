#!/usr/bin/env bash
set -e
# Detect dependency conflicts
python -m pip check
# Ensure Werkzeug is pinned to <3 to remain compatible with Flask 2.2.x
python - <<'PY'
import importlib, sys
w = importlib.import_module('werkzeug')
v = w.__version__.split('.')
if int(v[0]) >= 3:
    sys.exit('Incompatible Werkzeug version detected: ' + w.__version__ + '. Pin to Werkzeug<3.0.0 in requirements.txt')
print('Werkzeug version OK:', w.__version__)
PY
