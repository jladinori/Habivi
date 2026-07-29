@echo off
setlocal enabledelayedexpansion

echo.
echo ============================================
echo     GENERADOR DE APK - HABIVI
echo ============================================
echo.

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

set "OUTPUT_DIR=%SCRIPT_DIR%apk_output"
set "APK_PATH=%SCRIPT_DIR%build\app\outputs\flutter-apk\app-release.apk"

echo [1/5] Verificando Flutter...
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter no encontrado. Verifica que Flutter este instalado y en el PATH.
    pause
    exit /b 1
)
echo [OK] Flutter encontrado.

echo.
echo [2/5] Limpiando build anterior...
flutter clean
if %errorlevel% neq 0 (
    echo [ERROR] Fallo al limpiar el build.
    pause
    exit /b 1
)
echo [OK] Build anterior limpiado.

echo.
echo [3/5] Obteniendo dependencias...
flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Fallo al obtener dependencias.
    pause
    exit /b 1
)
echo [OK] Dependencias obtenidas.

echo.
echo [4/5] Regenerando modelos Hive (build_runner)...
flutter pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo [ERROR] Fallo al regenerar modelos Hive.
    pause
    exit /b 1
)
echo [OK] Modelos Hive regenerados.

echo.
echo [5/5] Compilando APK release...
flutter build apk --release
if %errorlevel% neq 0 (
    echo [ERROR] Fallo al compilar el APK.
    pause
    exit /b 1
)
echo [OK] APK compilado.

echo.
if exist "%APK_PATH%" (
    if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

    for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "TIMESTAMP=%%I"
    set "TIMESTAMP=!TIMESTAMP:~0,8!_!TIMESTAMP:~8,6!"

    set "DEST_APK=%OUTPUT_DIR%\Habivi_v1.0.0_!TIMESTAMP!.apk"
    copy /y "%APK_PATH%" "!DEST_APK!" >nul

    echo ============================================
    echo     APK GENERADO EXITOSAMENTE
    echo ============================================
    echo.
    echo   Archivo: !DEST_APK!
    echo   Tamano : 
    for %%A in ("!DEST_APK!") do echo            %%~zA bytes
    echo.
) else (
    echo [ERROR] No se encontro el APK generado.
    pause
    exit /b 1
)

endlocal
