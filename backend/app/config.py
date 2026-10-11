import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    SECRET_KEY = os.getenv("SECRET_KEY", "cyberpunk-fitness-secret-key-2026")
    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URL", "sqlite:///cyberfit.db")
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # Gemini AI
    GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
    
    # User Profile Constraints
    USER_HEIGHT_M = 1.71
    USER_WEIGHT_KG = 90.8
    DAILY_CALORIE_TARGET_MIN = 1800
    DAILY_CALORIE_TARGET_MAX = 1900
    
    # Whey Pro Rule
    MAX_WHEY_SCOOPS_PER_LIFT_DAY = 1
    
    # Upload folder
    UPLOAD_FOLDER = os.path.join(os.path.dirname(__file__), "..", "uploads")
