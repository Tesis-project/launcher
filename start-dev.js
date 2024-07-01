const concurrently = require('concurrently');

concurrently(
    [
        { command: 'pnpm --filter client-gateway dev', name: 'client-gateway', prefixColor: 'bgRed.black' },
        { command: 'pnpm --filter auth-ms dev', name: 'auth-ms', prefixColor: 'bgCyan.black' },
        { command: 'pnpm --filter user-ms dev', name: 'user-ms', prefixColor: 'bgGreen.black' },
        { command: 'pnpm --filter profile-ms dev', name: 'profile-ms', prefixColor: 'bgYellow.black' },
    ],
    {
        prefix: 'name',
        killOthers: ['failure', 'success'],
        successCondition: 'first'
    }
).result.then(
    () => console.log('Done!'),
    () => console.log('Failed!')
);
