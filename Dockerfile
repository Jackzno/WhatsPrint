FROM node:18

RUN apt-get update && \
    apt-get install -y libreoffice jq curl && \
    npm install -g npm && \
    mkdir -p /app /data

WORKDIR /app

COPY package*.json ./
RUN npm install
COPY . .

RUN chmod +x /app/run.sh
CMD [ "bash", "/app/run.sh" ]
