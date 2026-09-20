from fastapi import FastAPI
from api.endpoints import api_router

app = FastAPI(
    title="AIIGT Rural Entrepreneur AI Microservice",
    description="Vector Intelligence & Task Router API",
    version="1.0.0"
)

app.include_router(api_router, prefix="/api/v1/ai")

@app.get("/api/v1/ai/health")
def health_check():
    return {"status": "healthy", "service": "ai"}
