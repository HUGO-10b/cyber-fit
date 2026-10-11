from datetime import datetime, date
from app.database import db

class NutritionEntry(db.Model):
    __tablename__ = "nutrition_entries"

    id = db.Column(db.Integer, primary_key=True)
    date = db.Column(db.Date, default=date.today, nullable=False, index=True)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
    meal_name = db.Column(db.String(120), nullable=True)
    image_path = db.Column(db.String(255), nullable=True)
    weight_grams = db.Column(db.Float, nullable=False)
    calories = db.Column(db.Float, nullable=False)
    protein_grams = db.Column(db.Float, default=0.0)
    carbs_grams = db.Column(db.Float, default=0.0)
    fat_grams = db.Column(db.Float, default=0.0)
    ai_analysis = db.Column(db.Text, nullable=True)

    def to_dict(self):
        return {
            "id": self.id,
            "date": self.date.isoformat(),
            "timestamp": self.timestamp.isoformat(),
            "meal_name": self.meal_name or "Comida analizada por Gemini",
            "image_path": self.image_path,
            "weight_grams": self.weight_grams,
            "calories": round(self.calories, 1),
            "protein_grams": round(self.protein_grams, 1),
            "carbs_grams": round(self.carbs_grams, 1),
            "fat_grams": round(self.fat_grams, 1),
            "ai_analysis": self.ai_analysis
        }


class WorkoutSession(db.Model):
    __tablename__ = "workout_sessions"

    id = db.Column(db.Integer, primary_key=True)
    date = db.Column(db.Date, default=date.today, nullable=False, index=True)
    day_name = db.Column(db.String(20), nullable=False)  # Lunes, Martes, etc.
    routine_focus = db.Column(db.String(60), nullable=False)  # Pierna, Pecho con tríceps, etc.
    photo_path = db.Column(db.String(255), nullable=True)
    notes = db.Column(db.String(255), nullable=True)
    completed_at = db.Column(db.DateTime, default=datetime.utcnow)

    sets = db.relationship("WorkoutSet", backref="session", cascade="all, delete-orphan", lazy=True)

    def to_dict(self):
        return {
            "id": self.id,
            "date": self.date.isoformat(),
            "day_name": self.day_name,
            "routine_focus": self.routine_focus,
            "photo_path": self.photo_path,
            "notes": self.notes,
            "completed_at": self.completed_at.isoformat(),
            "sets": [s.to_dict() for s in self.sets]
        }


class WorkoutSet(db.Model):
    __tablename__ = "workout_sets"

    id = db.Column(db.Integer, primary_key=True)
    session_id = db.Column(db.Integer, db.ForeignKey("workout_sessions.id"), nullable=False)
    exercise_name = db.Column(db.String(100), nullable=False)
    set_number = db.Column(db.Integer, default=1)
    weight_kg = db.Column(db.Float, nullable=False)
    reps = db.Column(db.Integer, nullable=False)

    def to_dict(self):
        return {
            "id": self.id,
            "exercise_name": self.exercise_name,
            "set_number": self.set_number,
            "weight_kg": self.weight_kg,
            "reps": self.reps
        }


class SupplementLog(db.Model):
    __tablename__ = "supplement_logs"

    id = db.Column(db.Integer, primary_key=True)
    date = db.Column(db.Date, default=date.today, nullable=False, index=True)
    product_name = db.Column(db.String(100), default="Whey Pro - Universe Nutrition")
    scoops = db.Column(db.Float, default=1.0)
    is_post_workout = db.Column(db.Boolean, default=True)
    is_lifting_day = db.Column(db.Boolean, default=True)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "date": self.date.isoformat(),
            "product_name": self.product_name,
            "scoops": self.scoops,
            "is_post_workout": self.is_post_workout,
            "is_lifting_day": self.is_lifting_day,
            "timestamp": self.timestamp.isoformat()
        }


class CardioSession(db.Model):
    __tablename__ = "cardio_sessions"

    id = db.Column(db.Integer, primary_key=True)
    date = db.Column(db.Date, default=date.today, nullable=False, index=True)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
    machine_type = db.Column(db.String(60), default="Life Fitness Treadmill/Bike")
    qr_payload = db.Column(db.Text, nullable=True)
    time_minutes = db.Column(db.Float, nullable=False)
    distance_km = db.Column(db.Float, nullable=False)
    calories_burned = db.Column(db.Float, default=0.0)

    def to_dict(self):
        return {
            "id": self.id,
            "date": self.date.isoformat(),
            "timestamp": self.timestamp.isoformat(),
            "machine_type": self.machine_type,
            "time_minutes": round(self.time_minutes, 1),
            "distance_km": round(self.distance_km, 2),
            "calories_burned": round(self.calories_burned, 1)
        }
