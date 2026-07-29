#!/bin/bash
echo ""
echo "============================================"
echo "  REGENERAR BUILD COMPLETO - HABIVI"
echo "============================================"
echo ""
echo "Este script regenera los modelos Hive y compila el APK."
echo ""

bash "$(dirname "${BASH_SOURCE[0]}")/generar_apk.sh"
