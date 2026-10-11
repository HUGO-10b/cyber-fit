import re
import json
import urllib.parse

class LifeFitnessService:
    @staticmethod
    def parse_qr_data(raw_payload: str) -> dict:
        """
        Parses Life Fitness QR code strings or telemetry payloads.
        Supports:
        1. JSON strings: {"machine": "Treadmill", "time_min": 30.5, "dist_km": 4.2, "cal": 280}
        2. Pipe / Colon delimited strings: LF:TM|T=32.0|D=4.5|C=315
        3. URL strings: https://lifefitness.com/workout?time=25.0&dist=3.8&cal=240
        """
        payload = raw_payload.strip()

        # Try JSON
        if payload.startswith("{") and payload.endswith("}"):
            try:
                data = json.loads(payload)
                return {
                    "machine_type": data.get("machine", data.get("type", "Life Fitness Cardio")),
                    "time_minutes": float(data.get("time_min", data.get("time", 20.0))),
                    "distance_km": float(data.get("dist_km", data.get("distance", 3.0))),
                    "calories_burned": float(data.get("cal", data.get("calories", 200.0))),
                    "status": "success"
                }
            except Exception:
                pass

        # Try URL query params
        if "time=" in payload or "dist=" in payload:
            parsed_url = urllib.parse.urlparse(payload)
            params = urllib.parse.parse_qs(parsed_url.query)
            if not params and "?" in payload:
                query_str = payload.split("?", 1)[1]
                params = urllib.parse.parse_qs(query_str)
            
            time_val = float(params.get("time", [25.0])[0])
            dist_val = float(params.get("dist", params.get("distance", [3.5]))[0])
            cal_val = float(params.get("cal", params.get("calories", [220.0]))[0])
            machine = params.get("machine", ["Life Fitness Synrgy / Cardio"])[0]
            return {
                "machine_type": machine,
                "time_minutes": time_val,
                "distance_km": dist_val,
                "calories_burned": cal_val,
                "status": "success"
            }

        # Try Pipe / Key-Value: LF:TM|TIME=30|DIST=4.2|CAL=290
        time_match = re.search(r'(?:TIME|T)=([0-9\.]+)', payload, re.IGNORECASE)
        dist_match = re.search(r'(?:DIST|D)=([0-9\.]+)', payload, re.IGNORECASE)
        cal_match = re.search(r'(?:CAL|C)=([0-9\.]+)', payload, re.IGNORECASE)
        machine_match = re.search(r'(?:MACHINE|M)=([A-Za-z0-9_\-\s]+)', payload, re.IGNORECASE)

        time_min = float(time_match.group(1)) if time_match else 25.0
        dist_km = float(dist_match.group(1)) if dist_match else 3.2
        cal_burn = float(cal_match.group(1)) if cal_match else 230.0
        mach = machine_match.group(1) if machine_match else "Life Fitness Elevation Series"

        return {
            "machine_type": mach,
            "time_minutes": time_min,
            "distance_km": dist_km,
            "calories_burned": cal_burn,
            "status": "success"
        }
