@echo off
echo ========================================================
echo        CYBERFIT // OS - COMPILAR APK PARA ANDROID
echo ========================================================

set PATH=C:\src\flutter\bin;%PATH%
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr

cd /d "%~dp0frontend_flutter"

echo.
echo Compilando APK de lanzamiento (Release APK)...
echo.
flutter build apk --release

echo.
echo ========================================================
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo  APK COMPILADO EXITOSAMENTE EN:
    echo  %~dp0frontend_flutter\build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo  Pasa este archivo a tu celular (por WhatsApp, USB o Google Drive) e instalalo.
) else (
    echo  Si fallo por cmdline-tools:
    echo  Abre Android Studio ^> Settings ^> Languages ^& Frameworks ^> Android SDK ^> SDK Tools.
    echo  Marca la casilla "Android SDK Command-line Tools (latest)" y dale Apply.
)
echo ========================================================
pause
