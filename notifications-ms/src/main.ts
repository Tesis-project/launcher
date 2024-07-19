
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { Logger, ValidationPipe } from '@nestjs/common';
import { envs } from './core/config/envs';

async function bootstrap() {

  const logger = new Logger('Profile-MS - Main')

    // const app = await NestFactory.createMicroservice<MicroserviceOptions>(
    //     AppModule,
    //     {
    //         transport: Transport.NATS,
    //         options: {
    //             servers: envs.natsServers
    //         }
    //     }
    // );

    // app.useGlobalPipes(new ValidationPipe({
    //     whitelist: true,
    //     forbidNonWhitelisted: true,
    //     transform: true,
    //     exceptionFactory: (errors) => {
    //         const formattedErrors = errors.map(err => {
    //             if (err.constraints) {
    //                 return Object.values(err.constraints);
    //             } else if (err.children && err.children.length > 0) {
    //                 return err.children.map(child => Object.values(child.constraints)).flat();
    //             } else {
    //                 return `Validation failed for property ${err.property}`;
    //             }
    //         }).flat();
    //         return new RpcException({
    //             statusCode: 400,
    //             message: [...formattedErrors],
    //             err: 'Bad Request',
    //         });
    //     }
    // }));

    // await app.listen();
    // logger.log(`Microservice is running`);

        const app = await NestFactory.create(AppModule);

    app.setGlobalPrefix('api');

    app.useGlobalPipes(
        new ValidationPipe({
            whitelist: true,
            forbidNonWhitelisted: true
        })
    )

    await app.listen(envs.port);

    logger.log(`Server is running on ${await app.getUrl()}`);


}
bootstrap();
