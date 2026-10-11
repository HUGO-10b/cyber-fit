from datetime import date
from flask import Blueprint, request, jsonify
from app.database import db
from app.models import CardioSession
from app.services.life_fitness_service import LifeFitnessService

cardio_bp = Blueprint("cardio", __name__, url_prefix="/api/cardio")

@cardio_bp.route("/scan-qr", methods=["POST"])
def scan_life_fitness_qr():
    """
    Sincronización automática vía escaneo de código QR de la máquina Life Fitness
    para extraer tiempo, distancia y calorías.
    """
    data = request.get_json() or {}
    qr_payload = data.get("qr_payload", "")

    if not qr_payload:
        return jsonify({"error": "No se recibió payload del código QR."}), 400

    parsed_stats = LifeFitnessService.parse_qr_data(qr_payload)

    session = CardioSession(
        date=date.today(),
        machine_type=parsed_stats["machine_type"],
        qr_payload=qr_payload,
        time_minutes=parsed_stats["time_minutes"],
        distance_km=parsed_stats["distance_km"],
        calories_burned=parsed_stats["calories_burned"]
    )
    db.session.add(session)
    db.session.commit()

    return jsonify({
        "status": "success",
        "message": "Sesión de Life Fitness sincronizada exitosamente.",
        "session": session.to_dict()
    }), 201


@cardio_bp.route("/today", methods=["GET"])
def get_today_cardio():
    today = date.today()
    sessions = CardioSession.query.filter_by(date=today).all()
    
    total_time = sum(s.time_minutes for s in sessions)
    total_dist = sum(s.distance_km for s in sessions)
    total_cal = sum(s.calories_burned for s in sessions)

    return jsonify({
        "date": today.isoformat(),
        "total_time_minutes": round(total_time, 1),
        "total_distance_km": round(total_dist, 2),
        "total_calories_burned": round(total_cal, 1),
        "sessions": [s.to_dict() for s in sessions]
    })
