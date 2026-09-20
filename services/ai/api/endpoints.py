from fastapi import APIRouter, HTTPException, Depends, Header
from pydantic import BaseModel
from typing import List, Dict, Any
import time
import os
from router.task_router import router as task_router
from embeddings.qdrant import get_qdrant_client, init_qdrant
from guardrails.input import InputGuardrails
from observability.metrics import AIObservability
from qdrant_client.http.models import PointStruct
import uuid

# Defense in Depth: Layer 2 Protection (Rec AI Protection Boundary)
INTERNAL_API_KEY = os.environ.get("AI_SERVICE_API_KEY", "dev-secret-key-123")

async def verify_api_key(x_api_key: str = Header(...)):
    if x_api_key != INTERNAL_API_KEY:
        raise HTTPException(status_code=403, detail="Invalid internal API key")

# Apply the dependency globally to this router
api_router = APIRouter(dependencies=[Depends(verify_api_key)])

class ChatRequest(BaseModel):
    prompt: str
    
class EmbeddingRequest(BaseModel):
    text: str
    payload: Dict[str, Any]
    collection: str

@api_router.on_event("startup")
async def startup_event():
    # Initialize Qdrant collections on boot
    init_qdrant()

@api_router.post("/chat")
async def chat_endpoint(request: ChatRequest):
    if InputGuardrails.check_prompt_injection(request.prompt):
        raise HTTPException(status_code=400, detail="Unsafe prompt detected.")
        
    start_time = time.time()
    try:
        provider = task_router.get_provider("chat")
        response = await provider.generate_text(request.prompt)
        latency = time.time() - start_time
        
        AIObservability.log_request("chat", provider.__class__.__name__, latency)
        
        return {
            "success": True, 
            "data": {"response": response},
            "metadata": {"provider": provider.__class__.__name__, "latency": latency}
        }
    except Exception as e:
        AIObservability.log_request("chat", "unknown", time.time() - start_time, success=False)
        raise HTTPException(status_code=500, detail=str(e))

@api_router.post("/embeddings")
async def embeddings_endpoint(request: EmbeddingRequest):
    start_time = time.time()
    try:
        provider = task_router.get_provider("embedding")
        vector = await provider.generate_embedding(request.text)
        
        # Save to Qdrant (Rec 4 & 5)
        client = get_qdrant_client()
        point_id = str(uuid.uuid4())
        
        client.upsert(
            collection_name=request.collection,
            points=[PointStruct(id=point_id, vector=vector, payload=request.payload)]
        )
        
        latency = time.time() - start_time
        AIObservability.log_request("embedding", provider.__class__.__name__, latency)
        
        return {
            "success": True, 
            "data": {"point_id": point_id, "collection": request.collection},
            "metadata": {"provider": provider.__class__.__name__, "latency": latency}
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

class InsightsRequest(BaseModel):
    business_profile: Dict[str, Any]
    historical_metrics: List[Dict[str, Any]]
    statistical_predictions: Dict[str, Any]

@api_router.post("/generate-insights")
async def generate_insights_endpoint(request: InsightsRequest):
    start_time = time.time()
    try:
        # We would normally format a complex prompt and ask the LLM to output JSON.
        # Since we use MockOpenAI for the MVP, we will simulate the structured JSON output directly.
        provider = task_router.get_provider("chat")
        
        # Simulate LLM processing time
        await provider.generate_text("Generate business insights for...")
        
        # Mock structured response
        mock_response = {
            "narrative": "Based on the recent steady growth and the upcoming seasonal demand, revenue is expected to increase. Expenses remain stable, indicating good operational control.",
            "riskLevel": "Low",
            "opportunities": [
                "Expand marketing reach in neighboring districts",
                "Negotiate bulk rates with suppliers given increased volume"
            ],
            "seasonality": [
                "Upcoming harvest season typically increases demand by 15%"
            ],
            "recommendations": [
                "Increase inventory buffer by 10% to meet seasonal demand",
                "Apply for MSME technology upgrade scheme"
            ]
        }
        
        latency = time.time() - start_time
        AIObservability.log_request("chat", provider.__class__.__name__, latency)
        
        return {
            "success": True, 
            "data": mock_response,
            "metadata": {"provider": provider.__class__.__name__, "latency": latency}
        }
    except Exception as e:
        AIObservability.log_request("chat", "unknown", time.time() - start_time, success=False)
        raise HTTPException(status_code=500, detail=str(e))

class SchemeExplainRequest(BaseModel):
    scheme: Dict[str, Any]
    eligibility: Dict[str, Any]
    score: int
    language: str = "en"

@api_router.post("/schemes/explain")
async def explain_scheme_endpoint(request: SchemeExplainRequest):
    start_time = time.time()
    try:
        provider = task_router.get_provider("chat")
        
        system_prompt = """You are an explanation assistant for a deterministic government scheme recommendation engine.
The eligibility result provided to you is authoritative.
Do not create, modify, infer, or override eligibility requirements.
Do not invent:
- benefit amounts
- deadlines
- documents
- government rules
- application URLs
- eligibility conditions

Explain only the structured information provided.
If information is missing, say that it must be verified through the official government source."""

        # Enforce language translation
        if request.language == "hi":
            language_instruction = "Respond entirely in Hindi."
        elif request.language == "mr":
            language_instruction = "Respond entirely in Marathi."
        else:
            language_instruction = "Respond entirely in English."
            
        user_prompt = f"""
Scheme: {request.scheme.get('name')}
Benefits: {request.scheme.get('benefits')}
Eligibility Status: {request.eligibility.get('status')}
Matched Rules: {request.eligibility.get('matchedRules')}
Missing Fields: {request.eligibility.get('missingFields')}
Match Score: {request.score}

Explain why this scheme was recommended based on the matched rules. 
{language_instruction}
"""
        
        full_prompt = system_prompt + "\n\n" + user_prompt
        
        response = await provider.generate_text(full_prompt)
        
        latency = time.time() - start_time
        AIObservability.log_request("chat", provider.__class__.__name__, latency)
        
        return {
            "success": True, 
            "data": {"explanation": response},
            "metadata": {"provider": provider.__class__.__name__, "latency": latency}
        }
    except Exception as e:
        AIObservability.log_request("chat", "unknown", time.time() - start_time, success=False)
        # STRICT DETERMINISTIC FALLBACK (No 500 error on AI failure)
        fallback_msg = "Based on your profile, this scheme is recommended because your business characteristics match the scheme's target rules. Please verify the latest requirements on the official government website."
        if request.language == "hi":
            fallback_msg = "आपकी प्रोफ़ाइल के आधार पर, इस योजना की सिफारिश की जाती है क्योंकि आपकी व्यावसायिक विशेषताएँ योजना के नियमों से मेल खाती हैं। कृपया आधिकारिक वेबसाइट पर नवीनतम आवश्यकताओं को सत्यापित करें।"
        elif request.language == "mr":
            fallback_msg = "तुमच्या प्रोफाइलवर आधारित, या योजनेची शिफारस केली जाते कारण तुमची व्यावसायिक वैशिष्ट्ये योजनेच्या नियमांशी जुळतात. कृपया अधिकृत वेबसाइटवर नवीनतम आवश्यकता तपासा."
            
        return {
            "success": True,
            "data": {"explanation": fallback_msg, "isFallback": True},
            "metadata": {"provider": "fallback", "latency": time.time() - start_time}
        }
