import os
import uuid
from datetime import date, datetime
from flask import Blueprint, request, jsonify
from werkzeug.utils import secure_filename
from app.database import db
from app.models import WorkoutSession, WorkoutSet
from app.config import Config

workout_bp = Blueprint("workout", __name__, url_prefix="/api/workout")

WEEKLY_SPLIT = {
    0: {"day": "Lunes", "focus": "Pierna", "exercises": ["Sentadilla con Barra", "Prensa 45°", "Extensión de Cuádriceps", "Curl Femoral Tumbado", "Elevación de Talones"]},
    1: {"day": "Martes", "focus": "Pecho con tríceps", "exercises": ["Press de Banca Plano", "Press Inclinado con Mancuernas", "Aperturas en Polea", "Fondos en Paralelas", "Extensión de Tríceps en Polea"]},
    2: {"day": "Miércoles", "focus": "Espalda con bíceps", "exercises": ["Jalón al Pecho", "Remo con Barra", "Remo Gironda", "Curl de Bíceps con Barra Z", "Curl Martillo"]},
    3: {"day": "Jueves", "focus": "Pierna", "exercises": ["Sentadilla Búlgara", "Peso Muerto Rumano", "Hack Squat", "Abductores en Máquina", "Gemelos en Prensa"]},
    4: {"day": "Viernes", "focus": "Pecho con tríceps", "exercises": ["Press Superior con Barra", "Cruces en Polea Alta", "Press Francés", "Extensiones Katana", "Flexiones al fallo"]},
    5: {"day": "Sábado", "focus": "Descanso Activo / Cardio Ligero", "exercises": ["Caminata en pendiente", "Movilidad articular"]},
    6: {"day": "Domingo", "focus": "Descanso Total / Recuperación", "exercises": ["Estiramientos pasivos", "Hidratación"]}
}

@workout_bp.route("/routine/today", methods=["GET"])
def get_today_routine():
    weekday_idx = datetime.now().weekday()
    routine_info = WEEKLY_SPLIT.get(weekday_idx, WEEKLY_SPLIT[0])
    
    # Check if user already completed or logged today's workout
    today_session = WorkoutSession.query.filter_by(date=date.today()).first()
    
    return jsonify({
        "weekday_index": weekday_idx,
        "day_name": routine_info["day"],
        "routine_focus": routine_info["focus"],
        "recommended_exercises": routine_info["exercises"],
        "already_logged_today": today_session is not None,
        "today_session": today_session.to_dict() if today_session else None
    })


@workout_bp.route("/routine/schedule", methods=["GET"])
def get_full_schedule():
    return jsonify({
        "split": [
            {"day": v["day"], "focus": v["focus"], "exercises": v["exercises"]}
            for k, v in WEEKLY_SPLIT.items() if k < 5
        ],
        "notes": "Plan de hipertrofia y preservación muscular de 5 días para déficit calórico (90.8 kg -> definición)."
    })


@workout_bp.route("/log", methods=["POST"])
def log_workout():
    """
    Registra sesión de entrenamiento con peso levantado, repeticiones
    y foto opcional de la máquina o foto de progreso en el espejo.
    """
    photo_file = request.files.get("photo")
    photo_path = None

    if photo_file and photo_file.filename != "":
        os.makedirs(Config.UPLOAD_FOLDER, exist_ok=True)
        filename = f"gym_{uuid.uuid4().hex}_{secure_filename(photo_file.filename)}"
        save_path = os.path.join(Config.UPLOAD_FOLDER, filename)
        photo_file.save(save_path)
        photo_path = save_path

    # Extract JSON payload or form values
    day_name = request.form.get("day_name")
    routine_focus = request.form.get("routine_focus")
    notes = request.form.get("notes", "")

    weekday_idx = datetime.now().weekday()
    default_info = WEEKLY_SPLIT.get(weekday_idx, WEEKLY_SPLIT[0])

    if not day_name:
        day_name = default_info["day"]
    if not routine_focus:
        routine_focus = default_info["focus"]

    session = WorkoutSession(
        date=date.today(),
        day_name=day_name,
        routine_focus=routine_focus,
        photo_path=photo_path,
        notes=notes
    )
    db.session.add(session)
    db.session.flush()

    # Sets parsing (JSON string or form array)
    import json
    sets_data = request.form.get("sets_json")
    if sets_data:
        try:
            parsed_sets = json.loads(sets_data)
            for idx, item in enumerate(parsed_sets, start=1):
                workout_set = WorkoutSet(
                    session_id=session.id,
                    exercise_name=item.get("exercise_name", "Ejercicio"),
                    set_number=item.get("set_number", idx),
                    weight_kg=float(item.get("weight_kg", 0.0)),
                    reps=int(item.get("reps", 10))
                )
                db.session.add(workout_set)
        except Exception:
            pass

    db.session.commit()

    return jsonify({
        "status": "success",
        "message": f"Entrenamiento de {routine_focus} registrado exitosamente.",
        "session": session.to_dict()
    }), 201


@workout_bp.route("/history", methods=["GET"])
def get_workout_history():
    sessions = WorkoutSession.query.order_by(WorkoutSession.date.desc()).limit(20).all()
    return jsonify({
        "sessions": [s.to_dict() for s in sessions]
    })
