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

    app.register_blueprint(nutrition_bp)
    app.register_blueprint(workout_bp)
    app.register_blueprint(cardio_bp)
    app.register_blueprint(dashboard_bp)

    with app.app_context():
        db.create_all()

    return app
