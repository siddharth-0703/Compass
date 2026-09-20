from fastapi import APIRouter

router = APIRouter()

@router.post("/chat")
def chat_endpoint(message: str):
    # This will route to GPT-4o or Claude based on the Task Router
    return {"task": "Chat", "model_used": "GPT-4", "reply": "This is a stub response."}

@router.post("/ocr")
def ocr_endpoint():
    # This will route to Tesseract or PaddleOCR
    return {"task": "OCR", "model_used": "Tesseract", "extracted": "Stub extracted text."}

@router.post("/embeddings")
def embeddings_endpoint(text: str):
    # Routes to BGE or E5
    return {"task": "Embeddings", "model_used": "BGE", "vector": [0.1, 0.2, 0.3]}
