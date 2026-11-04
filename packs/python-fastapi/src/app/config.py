"""The one place the app reads settings: environment variables, plus .env in development.

Every setting added here also gets a line in .env.example.
Secrets use SecretStr, which prints as '**********' in logs, errors, and reprs.
"""

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    app_name: str = "app"
    environment: str = "development"
    # Example secret (no default, so a missing value fails at startup, not at first use):
    # api_key: SecretStr


@lru_cache
def get_settings() -> Settings:
    return Settings()
