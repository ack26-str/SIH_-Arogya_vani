import os
import mimetypes
from pathlib import Path
from PIL import Image
from pydantic import BaseModel, TypeAdapter
from typing import List, Dict, Any

from google import genai
from google.genai import types

from app.core.config import settings
from app.models.schemas import MedicalExtraction

# Initialize the Gemini client using the API key from settings
client = genai.Client(api_key=settings.GEMINI_API_KEY)


class DocumentProcessor:
    """Service to process medical documents using Gemini Multimodal OCR."""

    @staticmethod
    def _preprocess_image(file_path: str) -> str:
        """
        Preprocess image for better OCR (e.g., resizing if too large, converting format).
        Returns the path to the preprocessed image.
        """
        # For this prototype, we'll just ensure it's a valid RGB image and save as JPEG
        # if it's not a PDF. If it's a PDF, we leave it as is.
        path = Path(file_path)
        if path.suffix.lower() == ".pdf":
            return file_path
            
        try:
            with Image.open(file_path) as img:
                # Convert to RGB if necessary (e.g., for PNG with alpha channel)
                if img.mode in ("RGBA", "P"):
                    img = img.convert("RGB")
                    
                # Resize if the image is extremely large (to save API limits/latency)
                max_size = 2048
                if max(img.width, img.height) > max_size:
                    ratio = max_size / max(img.width, img.height)
                    new_size = (int(img.width * ratio), int(img.height * ratio))
                    img = img.resize(new_size, Image.Resampling.LANCZOS)
                
                out_path = str(path.with_suffix(".jpg"))
                img.save(out_path, "JPEG", quality=85)
                return out_path
        except Exception as e:
            print(f"Warning: Image preprocessing failed: {e}")
            return file_path

    @classmethod
    def extract_medical_entities(cls, file_path: str, mime_type: str) -> MedicalExtraction:
        """
        Extract structured medical entities from a document using Gemini.
        Supports PDF, JPG, PNG.
        Uses inline bytes for fast processing of images under 15MB.
        """
        processed_path = cls._preprocess_image(file_path)
        gemini_file = None
        
        prompt = """
        You are an expert medical data extractor.
        Analyze this medical document (prescription, lab report, discharge summary, or clinical note).
        Extract the information into the requested structured JSON format.
        
        Important instructions:
        1. Extract only information explicitly present in the document.
        2. If a field is not present, leave it null or as an empty list.
        3. For lab results, transcribe the exact test name, result value, reference range, and date.
        4. Transcribe medication names, doses, and frequencies accurately.
        5. The document may contain handwritten text or printed tables. Read it carefully.
        """

        file_size = os.path.getsize(processed_path) if os.path.exists(processed_path) else 0
        is_image = mime_type.startswith("image/") or Path(processed_path).suffix.lower() in [".jpg", ".jpeg", ".png", ".webp"]

        contents = []
        if is_image and file_size < 15 * 1024 * 1024:
            # Inline bytes is significantly faster than Files API upload/delete
            with open(processed_path, "rb") as f:
                img_bytes = f.read()
            actual_mime = "image/jpeg" if Path(processed_path).suffix.lower() in [".jpg", ".jpeg"] else mime_type
            contents = [
                types.Part.from_bytes(data=img_bytes, mime_type=actual_mime),
                prompt
            ]
        else:
            # Upload larger files/PDFs via Gemini Files API
            gemini_file = client.files.upload(
                file=processed_path,
                config={'mime_type': mime_type}
            )
            contents = [gemini_file, prompt]

        models_to_try = ['gemini-3.5-flash-lite', 'gemini-3.1-flash-lite']
        extraction = None

        for model_name in models_to_try:
            try:
                response = client.models.generate_content(
                    model=model_name,
                    contents=contents,
                    config=types.GenerateContentConfig(
                        response_mime_type="application/json",
                        response_schema=MedicalExtraction,
                        temperature=0.1,
                    ),
                )
                if response.text:
                    extraction = MedicalExtraction.model_validate_json(response.text)
                    cls._post_process_lab_results(extraction)
                    break
            except Exception as e:
                print(f"Extraction failed on {model_name}: {e}")
                continue

        # Clean up Gemini file if one was uploaded
        if gemini_file:
            try:
                client.files.delete(name=gemini_file.name)
            except Exception as e:
                print(f"Warning: Failed to delete Gemini file {gemini_file.name}: {e}")
                
        # Clean up temporary preprocessed image if created
        if processed_path != file_path and os.path.exists(processed_path):
            try:
                os.remove(processed_path)
            except Exception:
                pass

        return extraction if extraction is not None else MedicalExtraction()

    @staticmethod
    def _post_process_lab_results(extraction: MedicalExtraction):
        """
        Basic post-processing to flag abnormal lab values if the model missed it,
        based on simple heuristics (for demonstration).
        """
        for lab in extraction.lab_results:
            if lab.is_abnormal is None and lab.reference_range and lab.result_value:
                # A very rudimentary check: if there's a range like "10 - 20"
                try:
                    val = float(lab.result_value.replace(',', ''))
                    parts = lab.reference_range.split('-')
                    if len(parts) == 2:
                        low = float(parts[0].strip().replace(',', ''))
                        high = float(parts[1].strip().replace(',', ''))
                        if val < low or val > high:
                            lab.is_abnormal = True
                        else:
                            lab.is_abnormal = False
                except ValueError:
                    pass

    @classmethod
    def build_timeline(cls, extractions: List[MedicalExtraction]) -> List[Dict[str, Any]]:
        """
        Take multiple extractions and order medical events chronologically.
        (This will be expanded when we do cross-document synthesis)
        """
        timeline = []
        for ext in extractions:
            # Add lab results to timeline
            for lab in ext.lab_results:
                if lab.date:
                    timeline.append({
                        "date": lab.date,
                        "type": "Lab Result",
                        "title": lab.test_name,
                        "details": f"Value: {lab.result_value} {lab.reference_range or ''}"
                    })
        
        # Sort if they follow a parseable format, but for now just return the list
        return timeline
