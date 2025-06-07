#!/bin/bash

# Lade Konfiguration
ALLOWED_NUMBERS=$(jq -r '.allowed_numbers[]' /data/options.json | tr '\n' ' ')
ALLOWED_EXTENSIONS=$(jq -r '.allowed_extensions[]' /data/options.json | tr '\n' ' ')
PRINTER_NAME=$(jq -r '.printer_name' /data/options.json)

export WHATSAPP_ALLOWED_NUMBERS="$ALLOWED_NUMBERS"
export WHATSAPP_ALLOWED_EXTENSIONS="$ALLOWED_EXTENSIONS"
export WHATSAPP_PRINTER_NAME="$PRINTER_NAME"

# CUPS: persistente Konfiguration und Spool-Verzeichnis
mkdir -p /config/whatsapp-printer/cups/etc
mkdir -p /config/whatsapp-printer/cups/spool
rm -rf /etc/cups
ln -s /config/whatsapp-printer/cups/etc /etc/cups
rm -rf /var/spool/cups
ln -s /config/whatsapp-printer/cups/spool /var/spool/cups

# Konfig-Datei erstellen, wenn nicht vorhanden
if [ ! -f /etc/cups/cupsd.conf ]; then
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
cupsd

# Starte WhatsApp-Client
echo "[INFO] Starte WhatsApp-Client..."
node index.js
