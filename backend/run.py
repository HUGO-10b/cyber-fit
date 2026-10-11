import os
from app import create_app

app = create_app()

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    # Runs on all interfaces so emulator / physical mobile device can access via LAN IP
    app.run(host="0.0.0.0", port=port, debug=True)
