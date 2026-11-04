from fastapi import FastAPI

from app.config import get_settings

app = FastAPI(title=get_settings().app_name)


@app.get("/health")
def health() -> dict[str, str]:
    """Liveness check for the deploy platform. No dependencies, so it never costs money."""
    return {"status": "ok"}
