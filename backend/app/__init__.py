from flask import Flask
from flask_cors import CORS
from app.config import Config
from app.database import db

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    # Enable CORS for Flutter mobile / web requests
    CORS(app, resources={r"/api/*": {"origins": "*"}})

    db.init_app(app)

    # Register Blueprints
    from app.routes.nutrition import nutrition_bp
    from app.routes.workout import workout_bp
    from app.routes.cardio import cardio_bp
    from app.routes.dashboard import dashboard_bp
    from app.routes.app_update import update_bp

    app.register_blueprint(nutrition_bp)
    app.register_blueprint(workout_bp)
    app.register_blueprint(cardio_bp)
    app.register_blueprint(dashboard_bp)
    app.register_blueprint(update_bp)

    @app.before_request
    def check_private_access():
        # Allow CORS preflight requests
        from flask import request, jsonify
        if request.method == "OPTIONS":
            return
        
        # Check Authorization header on all /api/ endpoints
        if request.path.startswith("/api/"):
            auth_header = request.headers.get("Authorization", "")
            api_key_header = request.headers.get("X-API-KEY", "")
            expected_token = app.config.get("APP_SECRET_TOKEN", "")

            valid_bearer = auth_header == f"Bearer {expected_token}"
            valid_api_key = api_key_header == expected_token

            if not (valid_bearer or valid_api_key):
                return jsonify({
                    "error": "Acceso Denegado // Servidor Privado Exclusivo.",
                    "status": "unauthorized"
                }), 401

    with app.app_context():
        db.create_all()

    return app
