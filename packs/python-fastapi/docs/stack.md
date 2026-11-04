<!-- Loaded every session via CLAUDE.md. Installed by: scripts/apply-pack.sh python-fastapi -->
Stack: Python 3.12+ · FastAPI · Pydantic Settings · pytest · Ruff · uv (never bare pip or venv).
App package: `src/app/` · settings: `src/app/config.py` · tests: `tests/`.

| Task | Command |
|---|---|
| Install | `uv sync` |
| Run (dev) | `uv run uvicorn app.main:app --app-dir src --reload` |
| Test | `uv run pytest` (one file: `uv run pytest tests/test_x.py -q`) |
| Lint / format | `uv run ruff check --fix . && uv run ruff format .` (the hook does this per file) |
| Add a dependency | `uv add <pkg>` (dev only: `uv add --dev <pkg>`) |
| Check the Claude setup | `scripts/check.sh` |
