from datetime import date, timedelta
from flask import Blueprint, jsonify
from app.database import db
from app.models import NutritionEntry, WorkoutSession, CardioSession, SupplementLog
from app.config import Config

dashboard_bp = Blueprint("dashboard", __name__, url_prefix="/api/dashboard")

@dashboard_bp.route("/summary", methods=["GET"])
def get_dashboard_summary():
    today = date.today()
    start_of_week = today - timedelta(days=today.weekday())  # Lunes de esta semana

    # Today stats
    today_nutrition = NutritionEntry.query.filter_by(date=today).all()
    today_calories = sum(n.calories for n in today_nutrition)
    today_protein = sum(n.protein_grams for n in today_nutrition)
    today_carbs = sum(n.carbs_grams for n in today_nutrition)
    today_fat = sum(n.fat_grams for n in today_nutrition)

    today_cardio = CardioSession.query.filter_by(date=today).all()
    today_cardio_minutes = sum(c.time_minutes for c in today_cardio)
    today_cardio_km = sum(c.distance_km for c in today_cardio)
    today_cardio_cals = sum(c.calories_burned for c in today_cardio)

    today_workout = WorkoutSession.query.filter_by(date=today).first()
    today_whey = SupplementLog.query.filter_by(date=today).first()

    # Weekly chart data (last 7 days)
    days_data = []
    day_labels = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"]

    for i in range(7):
        current_date = start_of_week + timedelta(days=i)
        nut_list = NutritionEntry.query.filter_by(date=current_date).all()
        day_cals = sum(n.calories for n in nut_list)
        
        cardio_list = CardioSession.query.filter_by(date=current_date).all()
        cardio_km = sum(c.distance_km for c in cardio_list)

        has_workout = WorkoutSession.query.filter_by(date=current_date).first() is not None

        days_data.append({
            "day_index": i,
            "day_label": day_labels[i],
            "date": current_date.isoformat(),
            "calories": round(day_cals, 1),
            "target_calories": Config.DAILY_CALORIE_TARGET_MIN,
            "cardio_km": round(cardio_km, 2),
            "workout_completed": has_workout,
            "is_today": current_date == today
        })

    completed_workouts_count = sum(1 for d in days_data if d["workout_completed"])

    return jsonify({
        "user_profile": {
            "height_m": Config.USER_HEIGHT_M,
            "current_weight_kg": Config.USER_WEIGHT_KG,
            "goal": "Pérdida de grasa corporal & Recomposición",
            "daily_calorie_target": Config.DAILY_CALORIE_TARGET_MIN,
            "calorie_range": f"{Config.DAILY_CALORIE_TARGET_MIN} - {Config.DAILY_CALORIE_TARGET_MAX} kcal"
        },
        "today": {
            "date": today.isoformat(),
            "calories_consumed": round(today_calories, 1),
            "calories_target": Config.DAILY_CALORIE_TARGET_MIN,
            "remaining_calories": max(0.0, round(Config.DAILY_CALORIE_TARGET_MIN - today_calories, 1)),
            "is_caloric_surplus": today_calories > Config.DAILY_CALORIE_TARGET_MIN,
            "macros": {
                "protein_g": round(today_protein, 1),
                "carbs_g": round(today_carbs, 1),
                "fat_g": round(today_fat, 1)
            },
            "cardio": {
                "time_minutes": round(today_cardio_minutes, 1),
                "distance_km": round(today_cardio_km, 2),
                "burned_calories": round(today_cardio_cals, 1)
            },
            "workout_completed": today_workout is not None,
            "workout_focus": today_workout.routine_focus if today_workout else None,
            "whey_pro_taken": today_whey is not None
        },
        "weekly_progress": {
            "workouts_completed": completed_workouts_count,
            "target_workouts": 5,
            "days": days_data
        }
    })
