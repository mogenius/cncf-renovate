FROM node:26.13.0-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .

EXPOSE 3000
CMD ["node", "index.js"]
