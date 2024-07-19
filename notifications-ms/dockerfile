



FROM node:21-alpine3.19

ARG GITHUB_TOKEN

WORKDIR /usr/src/app

RUN echo "@tesis-project:registry=https://npm.pkg.github.com/" > .npmrc \
    && echo "//npm.pkg.github.com/:_authToken=${GITHUB_TOKEN}" >> .npmrc

COPY package*.json ./
COPY yarn.lock ./

RUN yarn install

RUN rm -f .npmrc

COPY . .

EXPOSE 3002

CMD ["yarn", "dev"]
