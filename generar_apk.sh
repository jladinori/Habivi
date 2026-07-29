#!/bin/bash
set -e

echo ""
echo "============================================"
echo "    GENERADOR DE APK - HABIVI"
echo "============================================"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

OUTPUT_DIR="${SCRIPT_DIR}/apk_output"
APK_PATH="${SCRIPT_DIR}/build/app/outputs/flutter-apk/app-release.apk"

echo "[1/5] Verificando Flutter..."
if ! command -v flutter &> /dev/null; then
    echo "[ERROR] Flutter no encontrado. Verifica que Flutter este instalado y en el PATH."
    exit 1
fi
echo "[OK] Flutter encontrado."

echo ""
echo "[2/5] Limpiando build anterior..."
flutter clean
echo "[OK] Build anterior limpiado."

echo ""
echo "[3/5] Obteniendo dependencias..."
flutter pub get
echo "[OK] Dependencias obtenidas."

echo ""
echo "[4/5] Regenerando modelos Hive (build_runner)..."
flutter pub run build_runner build --delete-conflicting-outputs
echo "[OK] Modelos Hive regenerados."

echo ""
echo "[5/5] Compilando APK release..."
flutter build apk --release
echo "[OK] APK compilado."

echo ""
if [ -f "$APK_PATH" ]; then
    mkdir -p "$OUTPUT_DIR"

    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    DEST_APK="${OUTPUT_DIR}/Habivi_v1.0.0_${TIMESTAMP}.apk"

    cp "$APK_PATH" "$DEST_APK"

    SIZE=$(stat -c%s "$DEST_APK" 2>/dev/null || stat -f%z "$DEST_APK" 2>/dev/null)

    echo "============================================"
    echo "    APK GENERADO EXITOSAMENTE"
    echo "============================================"
    echo ""
    echo "  Archivo: ${DEST_APK}"
    echo "  Tamano: ${SIZE} bytes"
    echo ""
else
    echo "[ERROR] No se encontro el APK generado."
    exit 1
fi
