from __future__ import annotations

import os
from flask import Blueprint, jsonify, send_file, Response

router = Blueprint("docs", __name__)


@router.get("/openapi.json")
def openapi_spec():
    spec_path = os.path.join(os.path.dirname(__file__), "..", "docs", "openapi.json")
    spec_path = os.path.abspath(spec_path)
    if not os.path.exists(spec_path):
        return jsonify({"detail": "OpenAPI spec not found"}), 404
    return send_file(spec_path, mimetype="application/json")


@router.get("/docs")
def swagger_ui():
    html = """
<!doctype html>
<html>
<head>
  <meta charset=\"utf-8\" />
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />
  <title>API Docs</title>
  <link rel=\"stylesheet\" href=\"https://unpkg.com/swagger-ui-dist@5/swagger-ui.css\" />
</head>
<body>
  <div id=\"swagger-ui\"></div>
  <script src=\"https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js\"></script>
  <script>
    window.onload = () => {
      window.ui = SwaggerUIBundle({
        url: '/openapi.json',
        dom_id: '#swagger-ui',
        presets: [SwaggerUIBundle.presets.apis],
        layout: 'BaseLayout'
      });
    };
  </script>
</body>
</html>
    """
    return Response(html, mimetype="text/html")
