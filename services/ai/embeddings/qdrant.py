import os
from qdrant_client import QdrantClient
from qdrant_client.http.models import Distance, VectorParams

QDRANT_HOST = os.getenv("QDRANT_HOST", "localhost")
QDRANT_PORT = int(os.getenv("QDRANT_PORT", "6333"))

client = QdrantClient(host=QDRANT_HOST, port=QDRANT_PORT)

COLLECTIONS = [
    "business_profiles",
    "mentor_profiles",
    "government_schemes",
    "marketplace_listings",
    "learning_resources",
    "community_posts",
    "chat_memory"
]

def init_qdrant(dimensions: int = 384):
    """Initialize Qdrant collections if they do not exist."""
    existing_collections = [c.name for c in client.get_collections().collections]
    
    for name in COLLECTIONS:
        if name not in existing_collections:
            client.create_collection(
                collection_name=name,
                vectors_config=VectorParams(size=dimensions, distance=Distance.COSINE),
            )
            print(f"Created Qdrant collection: {name}")

def get_qdrant_client() -> QdrantClient:
    return client
