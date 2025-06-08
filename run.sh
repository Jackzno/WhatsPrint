#!/bin/bash

# Lade Konfiguration aus /data/options.json oder nutze Defaults
if [ -f /data/options.json ]; then
  echo "[INFO] Lade Konfiguration aus /data/options.json..."
  ALLOWED_NUMBERS=$(jq -r '.allowed_numbers[]' /data/options.json | tr '\n' ' ')
  ALLOWED_EXTENSIONS=$(jq -r '.allowed_extensions[]' /data/options.json | tr '\n' ' ')
  PRINTER_NAME=$(jq -r '.printer_name' /data/options.json)
else
  echo "[WARN] /data/options.json nicht gefunden. Nutze Standardwerte."
  ALLOWED_NUMBERS=""
  ALLOWED_EXTENSIONS="pdf png jpg"
  PRINTER_NAME="MeinDrucker"
fi

export WHATSAPP_ALLOWED_NUMBERS="$ALLOWED_NUMBERS"
export WHATSAPP_ALLOWED_EXTENSIONS="$ALLOWED_EXTENSIONS"
export WHATSAPP_PRINTER_NAME="$PRINTER_NAME"

# CUPS Konfiguration und Spool-Verzeichnisse
mkdir -p /config/whatsapp-printer/cups/etc
mkdir -p /config/whatsapp-printer/cups/spool
mkdir -p /var/run/cups

rm -rf /etc/cups
ln -s /config/whatsapp-printer/cups/etc /etc/cups

rm -rf /var/spool/cups
ln -s /config/whatsapp-printer/cups/spool /var/spool/cups

# Standard-CUPS-Konfig erzeugen, wenn nicht vorhanden
if [ ! -f /etc/cups/cupsd.conf ]; then
  echo "[INFO] Erstelle cups-Konfiguration..."
  cat <<EOF > /etc/cups/cupsd.conf
Listen 0.0.0.0:631
Port 631
Browsing On
BrowseLocalProtocols dnssd
DefaultAuthType None

<Location />
  Order allow,deny
  Allow all
</Location>

<Location /admin>
  Order allow,deny
  Allow all
</Location>
EOF
fi

# Starte CUPS
echo "[INFO] Starte CUPS..."
cupsd -f &
sleep 2
pgrep cupsd > /dev/null && echo "[INFO] CUPS läuft." || echo "[ERROR] CUPS wurde nicht gestartet."

# Starte WhatsApp-Client
echo "[INFO] Starte WhatsApp-Client..."
node index.js

wait -n
