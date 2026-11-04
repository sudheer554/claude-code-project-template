# Pack: python-fastapi

Adds a minimal Python + FastAPI skeleton managed by [uv](https://docs.astral.sh/uv/).

| File | Purpose |
|---|---|
| `docs/stack.md` | Replaces the neutral one: stack and commands Claude loads every session |
| `pyproject.toml` | Dependencies, pytest, and Ruff config |
| `src/app/config.py` | The one validated settings object |
| `src/app/main.py` | App with a `/health` route |
| `tests/test_health.py` | Proves the test setup works |
| `.claude/rules/python.md` | Python rules, loaded only when `.py` files are touched |

Install: `scripts/apply-pack.sh python-fastapi`, then `uv sync && uv run pytest`.
