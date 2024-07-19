
import { HttpStatus } from "@nestjs/common";
import { RpcException } from "@nestjs/microservices";
import { _Response_I } from "@tesis-project/dev-globals/dist/core/interfaces";


export class ExceptionsHandler {

    constructor() {

    }

    EmitException(error: any, context?: string) {

        if (this.isResponseStructure(error?.error)) {

              throw new RpcException({
                ...error.error,
                context: context || 'ExceptionsHandler'
              });

        } else {

            // Manejar otros tipos de errores o transformar el error en la estructura deseada
            const response: _Response_I = {
                ok: false,
                statusCode: error.statusCode || HttpStatus.BAD_REQUEST || 500,
                message: error.message || 'An unexpected error occurred',
                err: error,
                data: null,
                context: context || 'ExceptionsHandler'
            };
            throw new RpcException(response);

        }

    }

    // Función de validación para la estructura de respuesta
    isResponseStructure(obj: any): obj is _Response_I {
        return (
            typeof obj === 'object' &&
            obj !== null &&
            (typeof obj.ok === 'boolean' || obj.ok === undefined) &&
            (typeof obj.statusCode === 'number' || obj.statusCode === undefined) &&
            (typeof obj.path === 'string' || obj.path === undefined) &&
            (obj.data !== undefined) &&
            (typeof obj.message === 'string' || obj.message === undefined) &&
            (typeof obj.paginator === 'object' || obj.paginator === undefined) &&
            (typeof obj.err === 'object' || obj.err === undefined) &&
            (typeof obj.context === 'string' || obj.context === undefined)
        );
    }


}