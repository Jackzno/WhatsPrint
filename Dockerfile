FROM node:18

# Install dependencies
RUN apt-get update && \
    apt-get install -y libreoffice cups cups-filters ghostscript jq && \
    npm install -g npm && \
    mkdir -p /app /data /config/whatsapp-printer/cups

# Copy and install node dependencies
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

RUN chmod +x /app/run.sh
CMD [ "bash", "/app/run.sh" ]
