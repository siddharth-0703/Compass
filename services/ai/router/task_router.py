from typing import Dict, Type
from providers.base import BaseProvider
from providers.mock_openai import MockOpenAIProvider
from providers.mock_bge import MockBGEProvider
from config.settings import settings

# Registry Pattern mapping Tasks -> Providers
class TaskRouter:
    def __init__(self):
        # We can dynamically inject real vs mock based on settings
        self.providers: Dict[str, BaseProvider] = {}
        self._init_providers()

    def _init_providers(self):
        if settings.use_mock_providers:
            self.providers = {
                "chat": MockOpenAIProvider(),
                "embedding": MockBGEProvider(dimensions=settings.embedding_dimensions),
                # Add mock translation, OCR, etc. later
            }
        else:
            # Future real SDK initializations go here
            pass

    def get_provider(self, task: str) -> BaseProvider:
        provider = self.providers.get(task)
        if not provider:
            raise ValueError(f"No AI Provider configured for task: {task}")
        return provider

# Singleton instance
router = TaskRouter()
