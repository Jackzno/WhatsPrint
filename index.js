const { Client, MessageMedia } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

// TEMP-Verzeichnis für Dateien
const tmpDir = '/app/tmp';
if (!fs.existsSync(tmpDir)) fs.mkdirSync(tmpDir);

// Lade Konfiguration aus Umgebungsvariablen
let whitelist = [];
try {
  whitelist = JSON.parse(process.env.WHATSAPP_ALLOWED_NUMBERS || '[]');
} catch (e) {
  console.error('Fehler beim Parsen der WHATSAPP_ALLOWED_NUMBERS:', e);
}

let allowedExtensions = [];
try {
  allowedExtensions = JSON.parse(process.env.WHATSAPP_ALLOWED_EXTENSIONS || '[]');
} catch (e) {
  console.error('Fehler beim Parsen der WHATSAPP_ALLOWED_EXTENSIONS:', e);
}

const printerName = process.env.WHATSAPP_PRINTER_NAME || 'HP_DeskJet_3630_series';
const cupsHost = process.env.WHATSAPP_CUPS_HOST || 'localhost:631';

const client = new Client({
  authStrategy: new (require('whatsapp-web.js').LocalAuth)(),
  puppeteer: { args: ['--no-sandbox', '--disable-setuid-sandbox'] }
});

client.on('qr', qr => qrcode.generate(qr, { small: true }));
client.on('ready', () => console.log('Client is ready!'));

client.on('message', async msg => {
  if (!whitelist.includes(msg.from)) {
    console.log(`Nicht erlaubt: ${msg.from}`);
    return;
  }

  if (msg.hasMedia) {
    const media = await msg.downloadMedia();
    if (!media) return await msg.reply('Download fehlgeschlagen.');

    const extension = media.mimetype.split('/')[1];
    if (!allowedExtensions.includes(extension)) {
      return await msg.reply('Dateityp nicht erlaubt.');
    }

    const filename = `file_${Date.now()}.${extension}`;
    const filepath = path.join(tmpDir, filename);
    fs.writeFileSync(filepath, media.data, 'base64');

    const convertable = ['odt', 'docx', 'xlsx', 'pptx', 'doc', 'xls', 'ppt'];
    if (convertable.includes(extension)) {
      const pdfPath = filepath.replace(/\.[^/.]+$/, '.pdf');
      exec(`libreoffice --headless --convert-to pdf "${filepath}" --outdir "${tmpDir}"`, (err) => {
        if (err || !fs.existsSync(pdfPath)) {
          msg.reply('Konvertierung fehlgeschlagen.');
          return;
        }
        sendToPrinter(pdfPath, msg, [filepath, pdfPath]);
      });
    } else {
      sendToPrinter(filepath, msg, [filepath]);
    }
  } else {
    msg.reply('Sende bitte eine Datei.');
  }
});

function sendToPrinter(filepath, msg, toDelete = []) {
  exec(`lp -h ${cupsHost} -d ${printerName} "${filepath}"`, async (err) => {
    if (err) await msg.reply('Druckfehler.');
    else await msg.reply('Datei wurde gedruckt.');
    toDelete.forEach(f => fs.unlink(f, () => {}));
  });
}

client.initialize();
