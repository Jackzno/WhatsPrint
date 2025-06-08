FROM node:18

# Install dependencies
RUN apt-get update && \
    apt-get install -y libreoffice cups cups-filters ghostscript jq && \
    npm install -g npm && \
    mkdir -p /app /data /config/whatsapp-printer/cups /var/run/cups

# Set workdir and install Node dependencies
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# Make run.sh executable
RUN chmod +x /app/run.sh

# Start script
CMD [ "bash", "/app/run.sh" ]
