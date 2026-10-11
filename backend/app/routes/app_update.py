import os
from flask import Blueprint, jsonify, send_file, current_app

update_bp = Blueprint("app_update", __name__, url_prefix="/api/app")

@update_bp.route("/version", methods=["GET"])
def get_app_version():
    """
    Informa a la app móvil si existe una nueva versión disponible en el servidor.
    """
    apk_path = os.path.join(current_app.config["UPLOAD_FOLDER"], "cyberfit-release.apk")
    has_apk = os.path.exists(apk_path)
    
    return jsonify({
        "current_server_version": "1.0.1",
        "has_apk_download": has_apk,
        "download_url": "/api/app/download-apk" if has_apk else None,
        "notes": "Actualización OTA: Reglas optimizadas de déficit 1,800 kcal y telemetría Life Fitness."
    })


@update_bp.route("/download-apk", methods=["GET"])
def download_apk():
    """
    Permite descargar el APK directamente desde tu servidor a tu celular.
    """
    apk_path = os.path.join(current_app.config["UPLOAD_FOLDER"], "cyberfit-release.apk")
    if not os.path.exists(apk_path):
        return jsonify({"error": "No hay APK cargado en el servidor aún."}), 404

    return send_file(
        apk_path,
        as_attachment=True,
        download_name="CyberFit.apk",
        mimetype="application/vnd.android.package-archive"
    )
