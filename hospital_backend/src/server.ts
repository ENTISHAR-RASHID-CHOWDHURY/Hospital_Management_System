import { createApp } from './app';
import { env } from './config/env';

const app = createApp();
const port = env.port;

const server = app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`Server ready on port ${port}`);
});

type ShutdownSignal = 'SIGINT' | 'SIGTERM';

function handleShutdown(signal: ShutdownSignal) {
  // eslint-disable-next-line no-console
  console.log(`Received ${signal}, shutting down gracefully...`);
  server.close(() => {
    // eslint-disable-next-line no-console
    console.log('HTTP server closed');
    process.exit(0);
  });
}

process.on('SIGINT', handleShutdown);
process.on('SIGTERM', handleShutdown);

export { app, server };
