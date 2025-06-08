#!/bin/bash

echo "[INFO] Lade Konfiguration aus /data/options.json..."

ALLOWED_NUMBERS=$(jq -r '.allowed_numbers[]' /data/options.json | tr '\n' ' ')
ALLOWED_EXTENSIONS=$(jq -r '.allowed_extensions[]' /data/options.json | tr '\n' ' ')
PRINTER_NAME=$(jq -r '.printer_name' /data/options.json)
CUPS_HOST=$(jq -r '.cups_host' /data/options.json)

export WHATSAPP_ALLOWED_NUMBERS="$ALLOWED_NUMBERS"
export WHATSAPP_ALLOWED_EXTENSIONS="$ALLOWED_EXTENSIONS"
export WHATSAPP_PRINTER_NAME="$PRINTER_NAME"
export WHATSAPP_CUPS_HOST="$CUPS_HOST"

echo "[INFO] Konfiguration geladen: Drucker=$PRINTER_NAME, CUPS=$CUPS_HOST"

echo "[INFO] Starte WhatsApp-Client..."
node index.js
