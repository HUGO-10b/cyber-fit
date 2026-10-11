import os
import uuid
from datetime import date
from flask import Blueprint, request, jsonify, current_app
from werkzeug.utils import secure_filename
from app.database import db
from app.models import NutritionEntry, SupplementLog, WorkoutSession
from app.services.gemini_service import GeminiNutritionService
from app.config import Config

nutrition_bp = Blueprint("nutrition", __name__, url_prefix="/api/nutrition")
gemini_service = GeminiNutritionService()

@nutrition_bp.route("/analyze", methods=["POST"])
def analyze_plate():
    """
    Subida de foto del plato + peso en gramos.
    Gemini analiza imagen + gramos y calcula macros/calorías exactas.
    Compara el resultado acumulado con el límite de 1,800 kcal.
    """
    if "weight_grams" not in request.form:
        return jsonify({"error": "El peso en gramos (weight_grams) es obligatorio."}), 400

    try:
        weight_grams = float(request.form["weight_grams"])
    except ValueError:
        return jsonify({"error": "El peso en gramos debe ser numérico."}), 400

    image_file = request.files.get("image")
    image_path = None

    if image_file and image_file.filename != "":
        os.makedirs(Config.UPLOAD_FOLDER, exist_ok=True)
        filename = f"{uuid.uuid4().hex}_{secure_filename(image_file.filename)}"
        save_path = os.path.join(Config.UPLOAD_FOLDER, filename)
        image_file.save(save_path)
        image_path = save_path

    # Process with Gemini AI
    analysis = gemini_service.analyze_food_plate(image_path or "", weight_grams)

    # Calculate today's existing calories
    today = date.today()
    today_entries = NutritionEntry.query.filter_by(date=today).all()
    calories_already_consumed = sum(e.calories for e in today_entries)
    
    new_calories = analysis.get("calories", 0.0)
    total_projected_calories = calories_already_consumed + new_calories
    
    # Validation against 1,800 kcal limit
    daily_limit = Config.DAILY_CALORIE_TARGET_MIN
    limit_exceeded = total_projected_calories > daily_limit
    remaining_kcal = max(0.0, daily_limit - total_projected_calories)

    # Persist in DB
    entry = NutritionEntry(
        date=today,
        meal_name=analysis.get("meal_name", "Comida Analizada"),
        image_path=image_path,
        weight_grams=weight_grams,
        calories=new_calories,
        protein_grams=analysis.get("protein_grams", 0.0),
        carbs_grams=analysis.get("carbs_grams", 0.0),
        fat_grams=analysis.get("fat_grams", 0.0),
        ai_analysis=analysis.get("fat_loss_verdict", "") + " | " + analysis.get("tips", "")
    )
    db.session.add(entry)
    db.session.commit()

    return jsonify({
        "status": "success",
        "entry": entry.to_dict(),
        "today_summary": {
            "consumed_calories": round(total_projected_calories, 1),
            "target_limit_kcal": daily_limit,
            "remaining_kcal": round(remaining_kcal, 1),
            "is_exceeded": limit_exceeded,
            "warning_message": (
                f"ALERTA: Superaste la meta diaria ({total_projected_calories:.1f} / {daily_limit} kcal). "
                "Ajusta tu próxima comida para mantener el déficit."
            ) if limit_exceeded else None
        },
        "gemini_details": analysis
    }), 201


@nutrition_bp.route("/today", methods=["GET"])
def get_today_nutrition():
    today = date.today()
    entries = NutritionEntry.query.filter_by(date=today).all()
    
    total_calories = sum(e.calories for e in entries)
    total_protein = sum(e.protein_grams for e in entries)
    total_carbs = sum(e.carbs_grams for e in entries)
    total_fat = sum(e.fat_grams for e in entries)

    daily_target = Config.DAILY_CALORIE_TARGET_MIN
    remaining = max(0.0, daily_target - total_calories)

    # Check Whey intake today
    whey_logs = SupplementLog.query.filter_by(date=today).all()
    total_whey_scoops = sum(w.scoops for w in whey_logs)

    return jsonify({
        "date": today.isoformat(),
        "total_calories": round(total_calories, 1),
        "target_calories": daily_target,
        "remaining_calories": round(remaining, 1),
        "is_exceeded": total_calories > daily_target,
        "macros": {
            "protein_g": round(total_protein, 1),
            "carbs_g": round(total_carbs, 1),
            "fat_g": round(total_fat, 1)
        },
        "whey_pro_summary": {
            "scoops_taken": total_whey_scoops,
            "max_allowed": Config.MAX_WHEY_SCOOPS_PER_LIFT_DAY,
            "rule": "Máximo 1 scoop post-entrenamiento los días de pesas (Universe Nutrition)"
        },
        "entries": [e.to_dict() for e in entries]
    })


@nutrition_bp.route("/log-whey", methods=["POST"])
def log_whey():
    """
    Regla estricta:
    Whey Pro de Universe Nutrition (alto en carbohidratos).
    Regla: Máximo 1 scoop post-entrenamiento los días de pesas.
    """
    data = request.get_json() or {}
    scoops = float(data.get("scoops", 1.0))
    is_post_workout = bool(data.get("is_post_workout", True))
    
    today = date.today()
    # Check if today has a workout session registered
    lifting_session = WorkoutSession.query.filter_by(date=today).first()
    is_lifting_day = lifting_session is not None or data.get("is_lifting_day", False)

    existing_logs = SupplementLog.query.filter_by(date=today).all()
    current_scoops = sum(l.scoops for l in existing_logs)

    # Validations according to user profile rules
    if not is_lifting_day:
        return jsonify({
            "status": "rejected",
            "reason": "Regla violada: Whey Pro (Universe Nutrition) solo está permitido los días de pesas para evitar acumulación de carbohidratos.",
            "allowed": False
        }), 400

    if not is_post_workout:
        return jsonify({
            "status": "warning",
            "message": "Nota: Se recomienda tomarlo estrictamente POST-ENTRENAMIENTO para aprovechar la ventana anabólica."
        })

    if (current_scoops + scoops) > Config.MAX_WHEY_SCOOPS_PER_LIFT_DAY:
        return jsonify({
            "status": "rejected",
            "reason": f"Regla violada: Ya has consumido {current_scoops} scoop(s) hoy. El límite estricto es {Config.MAX_WHEY_SCOOPS_PER_LIFT_DAY} scoop por día de pesas.",
            "allowed": False
        }), 400

    # Add supplement calories & carbs (approx 140 kcal, 24g protein, 8-10g carbs for Universe Nutrition Whey Pro)
    supp_log = SupplementLog(
        date=today,
        product_name="Whey Pro Universe Nutrition",
        scoops=scoops,
        is_post_workout=is_post_workout,
        is_lifting_day=True
    )
    db.session.add(supp_log)

    # Also log as a nutrition entry so it counts towards the 1,800 kcal
    nut_entry = NutritionEntry(
        date=today,
        meal_name="Whey Pro (Universe Nutrition) - 1 Scoop",
        weight_grams=35.0,
        calories=145.0,
        protein_grams=24.0,
        carbs_grams=9.0,
        fat_grams=1.5,
        ai_analysis="Suplementación post-entrenamiento autorizada bajo regla de 1 scoop."
    )
    db.session.add(nut_entry)
    db.session.commit()

    return jsonify({
        "status": "success",
        "message": "1 Scoop de Whey Pro registrado exitosamente post-entrenamiento.",
        "log": supp_log.to_dict()
    }), 201
