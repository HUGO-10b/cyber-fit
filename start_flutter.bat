@echo off
echo ========================================================
echo        CYBERFIT // OS - INICIANDO APP FLUTTER
echo ========================================================

:: Asegurar que Flutter este en el PATH en cualquier sesion
set PATH=C:\src\flutter\bin;%PATH%

cd /d "%~dp0frontend_flutter"

echo.
echo Selecciona como deseas abrir la aplicacion:
echo 1) En el Navegador Web (http://localhost:8080)
echo 2) En el Emulador de Android / Dispositivo conectado
echo.
set /p opt="Opcion (1 o 2) [Enter para Web]: "

if "%opt%"=="2" (
    echo Iniciando en Emulador / Dispositivo Android...
    flutter run
) else (
    echo Iniciando Servidor Web...
    start http://localhost:8080
    flutter run -d web-server --web-port=8080
)

pause
