
class Settings:
    PROJECT_NAME: str = "Electronics Shop API"

    DATABASE_URL: str = (
        "postgresql+asyncpg://erikantonov:naNcon-9rimno-tawfyc@localhost:5432/electronic_store"
    )

    JWT_SECRET_KEY: str = "secret_key_erik_antonov"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24


settings = Settings()