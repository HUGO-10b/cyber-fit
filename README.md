# CYBERFIT // OS 🦾⚡

Aplicación móvil de fitness y nutrición de alto rendimiento con estética **Cyberpunk / Moderna** (fondo negro profundo, acentos en verde neón, glow dinámico y micro-interacciones).

---

## 📋 Perfil del Atleta y Reglas de Negocio
- **Estatura:** 1.71 m
- **Peso Actual:** 90.8 kg
- **Objetivo Primario:** Pérdida de grasa corporal / Recomposición muscular hacia déficit.
- **Dieta / Límite Calórico:** 1,800 a 1,900 kcal diarias.
- **Suplemento Obligatorio:** *Whey Pro de Universe Nutrition* (alto en carbohidratos).
  - **Regla Estricta:** Máximo **1 scoop post-entrenamiento exclusivamente los días de pesas** para evitar acumulación calórica/carbohidratos en días de descanso.

---

## 🛠️ Stack Tecnológico
- **Frontend Móvil:** Flutter (Android / iOS).
  - Tema Cyberpunk en `lib/config/theme.dart` (Background `#08080A`, Acentos Verde Neón `#00FF66` y `#39FF14`).
  - Gráficos interactivos con `fl_chart`.
  - Escaneo de cámara y QR con `mobile_scanner`.
  - Cliente HTTP/REST con `dio`.
- **Backend:** Python con Flask.
  - Arquitectura modular basada en Blueprints (`/api/nutrition`, `/api/workout`, `/api/cardio`, `/api/dashboard`).
- **Base de Datos:** SQLite embebida / contenerizada con volumen persistente.
- **IA Multimodal:** Google Gemini (`gemini-2.5-flash` Multimodal Vision).
- **Integración Gym:** Life Fitness QR Telemetry Parser (Treadmills, Bikes, Cross-Trainers).
- **Infraestructura:** Docker & Docker Compose (`docker-compose.yml`).

---

## 🚀 Despliegue Rápido del Backend

### Opción 1: Con Docker (Recomendado)
```bash
# En la raíz del proyecto (c:\bot-fitnes)
docker compose up --build -d
```
El contenedor expondrá la API en `http://localhost:5000` con la base de datos persistida en `./data/cyberfit.db`.

### Opción 2: Local con Python
```bash
cd backend
python -m pip install -r requirements.txt
python run.py
```

### Configuración del API Key de Gemini
Copia `backend/.env.example` a `backend/.env` y coloca tu API Key:
```env
GEMINI_API_KEY=tu_api_key_de_gemini
PORT=5000
DATABASE_URL=sqlite:///cyberfit.db
```

---

## 🏋️‍♂️ Rutina Semanal de 5 Días
| Día | Enfoque | Ejercicios Clave |
|---|---|---|
| **Lunes** | Pierna | Sentadilla con Barra, Prensa 45°, Extensión de Cuádriceps, Femoral |
| **Martes** | Pecho con tríceps | Press Plano, Press Inclinado, Fondos, Katana / Extensiones |
| **Miércoles** | Espalda con bíceps | Jalón al Pecho, Remo con Barra, Remo Gironda, Curl Z, Martillo |
| **Jueves** | Pierna | Sentadilla Búlgara, Peso Muerto Rumano, Hack Squat, Gemelos |
| **Viernes** | Pecho con tríceps | Press Superior, Cruces en Polea, Press Francés, Flexiones |
| **Sábado** | Cardio Ligero | Escaneo Life Fitness + Caminata |
| **Domingo** | Recuperación | Descanso Total |

---

## 📱 Ejecución del Frontend Flutter
```bash
cd frontend_flutter
flutter pub get
flutter run
```
*Tip:* Si pruebas en el emulador de Android, el host predeterminado es `http://10.0.2.2:5000`. Si pruebas en un dispositivo físico, puedes configurar tu IP local en `lib/config/constants.dart`.
