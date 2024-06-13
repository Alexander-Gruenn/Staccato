FROM node:18

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

ENV PORT=1220

EXPOSE 1220

CMD ["npm", "start"]