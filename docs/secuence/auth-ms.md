
<!-- Auth - Register user -->

title Registro de usuario

actor Client
participant "API Gateway" as APIGW
participant "Auth Microservice" as AuthMS
participant "Auth Service" as AuthSvc
participant "Database melodify_auth" as DB

Client->APIGW: POST /api/auth (RegisterAuth_Dto)
APIGW->AuthMS: NATS 'auth.register.user' (RegisterAuth_Dto)
AuthMS->AuthSvc: create_auth(RegisterAuth_Dto)
AuthSvc->DB: INSERT INTO auth (usuario)

alt Success
    DB-->AuthSvc: Registro guardado en auth
    AuthSvc->DB: INSERT INTO auth_requests (validación de usuario)
    DB-->AuthSvc: Registro guardado en auth_requests
    AuthSvc-->AuthMS: Usuario registrado
    AuthMS-->APIGW: Success response (HTTP 201) with user data
    APIGW-->Client: Success response (HTTP 201) with user data
else Error
    AuthSvc-->AuthMS: Validation/Error
    AuthMS-->APIGW: Error response (HTTP 400) with error message
    APIGW-->Client: Error response (HTTP 400) with error message
end

<!-- logiin -->
title Inicio de sesión de usuario

actor Client
participant "API Gateway" as APIGW
participant "Auth Microservice" as AuthMS
participant "Auth Service" as AuthSvc
participant "Database melodify_auth" as DB

Client->APIGW: POST /api/auth/login (LoginAuth_Dto)
APIGW->AuthMS: NATS 'auth.login.user' (LoginAuth_Dto)
AuthMS->AuthSvc: login(loginUserDto)

AuthSvc->DB: SELECT * FROM auth WHERE email = loginUserDto.email

alt Success
    DB-->AuthSvc: Registro encontrado
    AuthSvc->AuthSvc: Validar contraseña
    alt Contraseña válida
        AuthSvc->DB: UPDATE auth SET last_session = NOW() WHERE email = loginUserDto.email
        AuthSvc->AuthMS: Success, Generar JWT Token
        AuthMS->APIGW: Success response (HTTP 200) with user data + JWT token
        APIGW-->Client: Success response (HTTP 200) with user data + JWT token
    else Contraseña inválida
        AuthSvc-->AuthMS: Error response (HTTP 400) Contraseña incorrecta
        AuthMS-->APIGW: Error response (HTTP 400) Contraseña incorrecta
        APIGW-->Client: Error response (HTTP 400) Contraseña incorrecta
    end
else Error
    DB-->AuthSvc: Usuario no encontrado
    AuthSvc-->AuthMS: Error response (HTTP 400) Usuario no encontrado
    AuthMS-->APIGW: Error response (HTTP 400) Usuario no encontrado
    APIGW-->Client: Error response (HTTP 400) Usuario no encontrado
end

<!-- verificar token -->

title Verificar token

actor Client
participant "API Gateway" as APIGW
participant "Auth Microservice" as AuthMS
participant "Auth Service" as AuthSvc
participant "Database melodify_auth" as DB

Client->APIGW: GET /api/auth/verify\nAuthorization: Bearer Token
APIGW->AuthMS: NATS 'auth.verify.user' (token)
AuthMS->AuthSvc: verifyToken(token)

AuthSvc->DB: SELECT * FROM auth WHERE token = token

alt Token válido
    DB-->AuthSvc: Registro de usuario encontrado
    AuthSvc->AuthSvc: Verificar validez del token
    AuthSvc->AuthSvc: Renovar token JWT
    AuthSvc->AuthMS: Success, nueva sesión + token renovado
    AuthMS->APIGW: Success response (HTTP 200) with session info + new JWT token
    APIGW-->Client: Success response (HTTP 200) with session info + new JWT token
else Token inválido o expirado
    DB-->AuthSvc: Token no válido
    AuthSvc-->AuthMS: Error response (HTTP 401) Token inválido o expirado
    AuthMS-->APIGW: Error response (HTTP 401) Token inválido o expirado
    APIGW-->Client: Error response (HTTP 401) Token inválido o expirado
end



<!-- requests -->

<!-- accept request -->
actor Client
Client -> API Gateway: PUT /api/auth/requests/verify/:key_id
API Gateway -> Auth-MS: MessagePattern('auth.requests.verify')
Auth-MS -> RequestsService: verify_request(key)
RequestsService -> melodify_auth: Buscar solicitud en tabla auth_requests
melodify_auth --> RequestsService: Solicitud encontrada

alt Solicitud ya fue utilizada
    RequestsService --> Auth-MS: Retorna error 400 "Solicitud ya utilizada"
    Auth-MS --> API Gateway: Respuesta 400
    API Gateway --> Client: Retorna error 400 "Solicitud ya utilizada"
else Solicitud no encontrada
    RequestsService --> Auth-MS: Retorna error 404 "Solicitud no encontrada"
    Auth-MS --> API Gateway: Respuesta 404
    API Gateway --> Client: Retorna error 404 "Solicitud no encontrada"
else Usuario no existe
    RequestsService --> Auth-MS: Retorna error 404 "Usuario no existe"
    Auth-MS --> API Gateway: Respuesta 404
    API Gateway --> Client: Retorna error 404 "Usuario no existe"
else Solicitud válida
    RequestsService -> melodify_auth: Actualizar estado de solicitud a 'USED'
    melodify_auth --> RequestsService: Solicitud actualizada
    RequestsService --> Auth-MS: Solicitud aprobada
    Auth-MS --> API Gateway: Respuesta 200 OK
    API Gateway --> Client: Retorna información de la solicitud aprobada
end

<!-- accept pass request -->
actor Client
Client -> API Gateway: PUT /api/auth/requests/verify_pass/:key_id (Bearer Token)
API Gateway -> Auth-MS: MessagePattern('auth.requests.verify_pass')
Auth-MS -> RequestsService: verify_pass_request(key, Accept_Password_Request_Dto)
RequestsService -> melodify_auth: Buscar solicitud en tabla auth_requests
melodify_auth --> RequestsService: Solicitud encontrada

alt Solicitud ya fue utilizada
    RequestsService --> Auth-MS: Retorna error 400 "Solicitud ya utilizada"
    Auth-MS --> API Gateway: Respuesta 400
    API Gateway --> Client: Retorna error 400 "Solicitud ya utilizada"
else Solicitud no encontrada
    RequestsService --> Auth-MS: Retorna error 404 "Solicitud no encontrada"
    Auth-MS --> API Gateway: Respuesta 404
    API Gateway --> Client: Retorna error 404 "Solicitud no encontrada"
else Usuario no existe
    RequestsService --> Auth-MS: Retorna error 404 "Usuario no existe"
    Auth-MS --> API Gateway: Respuesta 404
    API Gateway --> Client: Retorna error 404 "Usuario no existe"
else Solicitud válida
    RequestsService -> melodify_auth: Actualizar estado de solicitud a 'USED'
    melodify_auth --> RequestsService: Solicitud actualizada
    RequestsService --> Auth-MS: Solicitud aprobada
    Auth-MS --> API Gateway: Respuesta 200 OK con información de la solicitud aprobada
    API Gateway --> Client: Retorna información de la solicitud aprobada
end
<!-- Get one request -->
actor Client
Client -> API Gateway: GET /api/auth/requests/:key_id (Bearer Token)
API Gateway -> Auth-MS: MessagePattern('auth.requests.get')
Auth-MS -> RequestsService: get_request(key)
RequestsService -> melodify_auth: Buscar solicitud en tabla auth_requests
melodify_auth --> RequestsService: Solicitud encontrada

alt Solicitud ya fue utilizada
    RequestsService --> Auth-MS: Retorna error 400 "Solicitud ya utilizada"
    Auth-MS --> API Gateway: Respuesta 400
    API Gateway --> Client: Retorna error 400 "Solicitud ya utilizada"
else Solicitud no encontrada
    RequestsService --> Auth-MS: Retorna error 404 "Solicitud no encontrada"
    Auth-MS --> API Gateway: Respuesta 404
    API Gateway --> Client: Retorna error 404 "Solicitud no encontrada"
else Usuario no existe
    RequestsService --> Auth-MS: Retorna error 404 "Usuario no existe"
    Auth-MS --> API Gateway: Respuesta 404
    API Gateway --> Client: Retorna error 404 "Usuario no existe"
else Solicitud válida
    RequestsService --> Auth-MS: Solicitud encontrada
    Auth-MS --> API Gateway: Respuesta 200 OK con información de la solicitud
    API Gateway --> Client: Retorna información de la solicitud
end


<!-- Users -->
<!-- Update users -->
actor Client
Client -> API Gateway: PUT /api/user/update/:user_id
note right of Client: Bearer Token en el header - Envía el cuerpo UpdateUser_Dto
API Gateway -> User-MS: MessagePattern('user.update')
User-MS -> UserService: update_user(user_id, UpdateUser_Dto)
UserService -> melodify_user: Buscar usuario en tabla user por ID
melodify_user --> UserService: Retorna información del usuario

alt Usuario encontrado
    UserService -> melodify_user: Actualizar datos del usuario
    melodify_user --> UserService: Retorna información del usuario actualizado
    UserService --> User-MS: Retorna información del usuario actualizado
    User-MS --> API Gateway: Respuesta 200 OK con información del usuario actualizado
    API Gateway --> Client: Retorna 200 OK con información del usuario actualizado
else Usuario no encontrado
    UserService --> User-MS: Retorna 404 Not Found
    User-MS --> API Gateway: Respuesta 404 Not Found
    API Gateway --> Client: Retorna 404 Not Found
else Error en la actualización
    UserService --> User-MS: Retorna error 400
    User-MS --> API Gateway: Respuesta 400 Bad Request
    API Gateway --> Client: Retorna error 400 con información del error
end


<!-- Hiring data -->
<!-- Get hiring data -->
actor Client
Client -> API Gateway: GET /api/user/hiring-data/:hiring_data_id
note right of Client: Bearer Token en el header - No se requiere body, se pasa el ID en la URL
API Gateway -> User-MS: MessagePattern('user.hiring_data.get_one')
User-MS -> Hiring_Data_Service: get_hiring_data(_id, user_auth)
Hiring_Data_Service -> melodify_user: Buscar en tabla user_hiring_data
melodify_user --> Hiring_Data_Service: Retorna datos de contratación

alt Datos de contratación encontrados
    Hiring_Data_Service --> User-MS: Retorna datos de contratación
    User-MS --> API Gateway: Respuesta 200 OK con información de contratación
    API Gateway --> Client: Retorna 200 OK con la información de contratación
else No se encontraron datos de contratación
    Hiring_Data_Service --> User-MS: Retorna error 404
    User-MS --> API Gateway: Respuesta 404 Not Found
    API Gateway --> Client: Retorna error 404 con mensaje de error
else Error en la búsqueda
    Hiring_Data_Service --> User-MS: Retorna error 400
    User-MS --> API Gateway: Respuesta 400 Bad Request
    API Gateway --> Client: Retorna error 400 con mensaje de error
end
<!-- Save bank data -->
actor Client
Client -> API Gateway: POST /api/user/hiring-data/bank/:hiring_data_id
note right of Client: Bearer Token en el header - Envía el cuerpo Update_Bank_Data_Dto
API Gateway -> User-MS: MessagePattern('user.hiring_data.bank.save')
User-MS -> Bank_Info_Service: save_bank_data(hiring_id, user_auth, Update_Bank_Data_Dto)
Bank_Info_Service -> melodify_user: Buscar y añadir información bancaria en tabla user_bank_data
melodify_user --> Bank_Info_Service: Confirma información añadida

alt Hiring_id encontrado y datos añadidos
    Bank_Info_Service --> User-MS: Retorna confirmación de información bancaria añadida
    User-MS --> API Gateway: Respuesta 200 OK con confirmación
    API Gateway --> Client: Retorna 200 OK confirmando que la información bancaria fue añadida
else Hiring_id no encontrado
    Bank_Info_Service --> User-MS: Retorna error 404 Not Found
    User-MS --> API Gateway: Respuesta 404 Not Found
    API Gateway --> Client: Retorna error 404 con mensaje de error
else Error en el proceso
    Bank_Info_Service --> User-MS: Retorna error 400 Bad Request
    User-MS --> API Gateway: Respuesta 400 Bad Request
    API Gateway --> Client: Retorna error 400 con mensaje de error
end

<!-- delete bank data -->
actor Client
Client -> API Gateway: DELETE /api/user/hiring-data/bank/:bank_id
note right of Client:  Bearer Token en el header - No requiere cuerpo en la solicitud
API Gateway -> User-MS: MessagePattern('user.hiring_data.bank.delete_paymentInfo')
User-MS -> Bank_Info_Service: delete_paymentInfo(bank_id, user_auth)
Bank_Info_Service -> melodify_user: Elimina la información bancaria en la tabla user_bank_data
melodify_user --> Bank_Info_Service: Confirma eliminación de información bancaria

alt Bank_id encontrado y datos eliminados
    Bank_Info_Service --> User-MS: Retorna confirmación de eliminación
    User-MS --> API Gateway: Respuesta 200 OK con confirmación de eliminación
    API Gateway --> Client: Retorna 200 OK confirmando que la información bancaria fue eliminada
else Bank_id no encontrado
    Bank_Info_Service --> User-MS: Retorna error 404 Not Found
    User-MS --> API Gateway: Respuesta 404 Not Found
    API Gateway --> Client: Retorna error 404 con mensaje de error
else Error en el proceso
    Bank_Info_Service --> User-MS: Retorna error 400 Bad Request
    User-MS --> API Gateway: Respuesta 400 Bad Request
    API Gateway --> Client: Retorna error 400 con mensaje de error
end
