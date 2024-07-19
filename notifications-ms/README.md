
<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://nestjs.com/img/logo-small.svg" width="200" alt="Nest Logo" /></a>
</p>

[circleci-image]: https://img.shields.io/circleci/build/github/nestjs/nest/master?token=abc123def456
[circleci-url]: https://circleci.com/gh/nestjs/nest

  <p align="center">
    Blank project Nestjs - Pre Micro service - Mikro ORM default 
  </p>

<hr>

# Installation

### 1. Clone project and install - Run project

```bash
$ yarn install
$ yarn dev
```

### 2. Set .env file

```
For dev in localhost, Copy the .env.template file and rename it
as .env to initialize your environment variables
```

### 3. Create and initialize the database with docker

```bash
$ docker compose up -d
```

# Migrations

### Create migration
```
$ npx mikro-orm migration:create -n name
```
### Load migration
```
$ npx mikro-orm migration:up
```