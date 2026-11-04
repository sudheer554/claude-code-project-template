---
paths:
  - "**/*.py"
---

# Python rules (load only when Python files are touched)

- uv only: `uv add`, `uv run`. Never `pip install` or a hand-made venv.
- Type hints on every public function. Prefer `X | None` over `Optional[X]`.
- Settings only through `app.config.get_settings()`; never `os.environ` elsewhere.
- Secrets typed as `SecretStr`; call `.get_secret_value()` only at the point of use.
- FastAPI: request/response bodies are Pydantic models; route handlers stay thin and call
  functions in other modules that hold the logic.
- Blocking calls (requests, time.sleep, heavy CPU) never run inside `async def` handlers.
- Logging via `logging.getLogger(__name__)`, never `print`.
