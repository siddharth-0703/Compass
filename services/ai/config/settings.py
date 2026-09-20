from pydantic import BaseSettings

class Settings(BaseSettings):
    app_name: str = "AIIGT Rural Entrepreneur AI"
    environment: str = "development"
    
    # Provider Toggles (Phase 4 uses mocks)
    use_mock_providers: bool = True
    
    # Model Configs
    chat_model: str = "gpt-4-mock"
    embedding_model: str = "bge-small-en-v1.5-mock"
    embedding_dimensions: int = 384
    
    class Config:
        env_file = ".env"

settings = Settings()
