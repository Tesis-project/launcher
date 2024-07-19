

import 'dotenv/config';

import * as joi from 'joi';

enum NodeEnv {
    DEVELOPMENT = 'development',
    STAGING = 'staging',
    PRODUCTION = 'production'
}

interface EnvVars_I {
    PORT: number;

    NATS_SERVERS: string[];

    NODE_ENV: NodeEnv;

    DB_PASSWORD: string;
    DB_NAME: string;
    DB_HOST: string;
    DB_PORT: number;
    DB_USERNAME: string;

    // DB_URL: string;
}

const envsSchema = joi.object({
    PORT: joi.number().required(),

    NATS_SERVERS: joi.array().items(joi.string()),


    NODE_ENV: joi.string().valid(NodeEnv.DEVELOPMENT, NodeEnv.STAGING, NodeEnv.PRODUCTION).required(),

    DB_PASSWORD: joi.string().required(),
    DB_NAME: joi.string().required(),
    DB_HOST: joi.string().required(),
    DB_PORT: joi.number().required(),
    DB_USERNAME: joi.string().required(),

    // DB_URL: joi.string().required()

}).unknown(true);

const {
    error,
    value
} = envsSchema.validate({
    ...process.env,
    NATS_SERVERS: process.env.NATS_SERVERS?.split(',')
});

if (error) {

    throw new Error(`Config validation error: ${error.message}`);

}

const envVars: EnvVars_I = value;

export const envs = {
    port: envVars.PORT,

    natsServers: envVars.NATS_SERVERS,

    nodeEnv: envVars.NODE_ENV,

    db_password: envVars.DB_PASSWORD,
    db_name: envVars.DB_NAME,
    db_host: envVars.DB_HOST,
    db_port: envVars.DB_PORT,
    db_username: envVars.DB_USERNAME,

    // db_url: envVars.DB_URL
}