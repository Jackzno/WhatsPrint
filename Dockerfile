FROM node:18

RUN apt-get update &&     apt-get install -y libreoffice cups cups-filters ghostscript jq &&     mkdir -p /app /data &&     npm install -g npm

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN chmod +x /app/run.sh
CMD [ "bash", "/app/run.sh" ]
