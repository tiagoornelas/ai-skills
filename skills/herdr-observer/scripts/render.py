#!/usr/bin/env python3
"""Embeds a view's state.json into the panel template and writes index.html.

Usage: render.py <state.json> <index.html>
"""
import json
import sys
from pathlib import Path

PLACEHOLDER = "/*PANEL_DATA*/"
TEMPLATE = Path(__file__).resolve().parent.parent / "resources" / "panel.html"


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__.strip(), file=sys.stderr)
        return 2
    state_path, output_path = Path(sys.argv[1]), Path(sys.argv[2])
    data = json.loads(state_path.read_text(encoding="utf-8"))
    # Any "<" could close or comment out the <script> element that carries the data.
    payload = json.dumps(data, ensure_ascii=False).replace("<", "\\u003c")
    html = TEMPLATE.read_text(encoding="utf-8").replace(PLACEHOLDER, payload)
    output_path.write_text(html, encoding="utf-8")
    print(output_path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
