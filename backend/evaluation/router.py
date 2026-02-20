import os
import uuid
import json
import base64
# from openai import OpenAI
from dotenv import load_dotenv
from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from pydantic import BaseModel
from typing import List

from config import UPLOAD_DIR

# --- SECURE CONFIGURATION ---
# load_dotenv()
# OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

# if not OPENAI_API_KEY:
#     print("FATAL ERROR: OPENAI_API_KEY not found in .env file.")
#     OPENAI_API_KEY = "MISSING"

# client = OpenAI(api_key=OPENAI_API_KEY)

# # Use GPT-4o-mini for cost-effective, high-quality vision
# MODEL_NAME = "gpt-4o-mini"

router = APIRouter(tags=["AI Evaluation"])

class EvaluationResult(BaseModel):
    score: int
    total_marks: int
    extracted_text: str
    missing_keywords: List[str]
    matched_keywords: List[str]
    feedback: str


@router.post("/evaluate", response_model=EvaluationResult)
async def evaluate_answer_sheet(
    file: UploadFile = File(...),
    keywords: str = Form(..., description="Comma separated keywords"),
    total_marks: int = Form(10)
):
    # 1. Save the student's answer sheet locally
    filename = f"{uuid.uuid4()}_{file.filename}"
    file_path = os.path.join(UPLOAD_DIR, filename)

    try:
        content = await file.read()
        with open(file_path, "wb") as f:
            f.write(content)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save upload: {str(e)}")

    # 2. Process with OpenAI GPT-4o-mini
    try:
        # Convert image to base64
        base64_image = base64.b64encode(content).decode('utf-8')
        
        prompt = (
            f"You are an academic evaluator. Analyze the handwriting in this student answer sheet. "
            f"Evaluate the content based on these required keywords: {keywords}. "
            f"The total possible marks are {total_marks}. "
            f"Return ONLY a JSON object with these keys: "
            f"'score' (int), 'missing_keywords' (list), 'matched_keywords' (list), and 'feedback' (string)."
        )

        response = client.chat.completions.create(
            model=MODEL_NAME,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": prompt},
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:{file.content_type or 'image/jpeg'};base64,{base64_image}"
                            }
                        }
                    ]
                }
            ],
            max_tokens=1000
        )

        # 3. Clean and parse JSON response
        text_response = response.choices[0].message.content.strip()
        
        if "```json" in text_response:
            text_response = text_response.split("```json")[1].split("```")[0]
        elif "```" in text_response:
            text_response = text_response.split("```")[1].split("```")[0]

        result_payload = json.loads(text_response)

        return EvaluationResult(
            score=result_payload.get("score", 0),
            total_marks=total_marks,
            extracted_text="Handwriting analyzed via OpenAI GPT-4o-mini",
            missing_keywords=result_payload.get("missing_keywords", []),
            matched_keywords=result_payload.get("matched_keywords", []),
            feedback=result_payload.get("feedback", "Evaluation complete.")
        )

    except Exception as e:
        print(f"AI ERROR: {str(e)}")
        raise HTTPException(status_code=500, detail=f"AI Evaluation Failed: {str(e)}")