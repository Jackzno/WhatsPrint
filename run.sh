#!/bin/bash

echo "[INFO] Lade Konfiguration aus /data/options.json..."

# Direkt als JSON exportieren
ALLOWED_NUMBERS=$(jq -c '.allowed_numbers' /data/options.json)
ALLOWED_EXTENSIONS=$(jq -c '.allowed_extensions' /data/options.json)
PRINTER_NAME=$(jq -r '.printer_name' /data/options.json)
CUPS_HOST=$(jq -r '.cups_host' /data/options.json)

export WHATSAPP_ALLOWED_NUMBERS="$ALLOWED_NUMBERS"
export WHATSAPP_ALLOWED_EXTENSIONS="$ALLOWED_EXTENSIONS"
export WHATSAPP_PRINTER_NAME="$PRINTER_NAME"
export WHATSAPP_CUPS_HOST="$CUPS_HOST"

echo "[INFO] Konfiguration geladen: Drucker=$PRINTER_NAME, CUPS=$CUPS_HOST"

echo "[INFO] Starte WhatsApp-Client..."
node /app/index.js
