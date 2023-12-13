FROM node:20.10-alpine

WORKDIR /app

RUN npm config set registry https://registry.npmmirror.com \
    && npm i -g typescript \
    && npm i -g @nestjs/cli
