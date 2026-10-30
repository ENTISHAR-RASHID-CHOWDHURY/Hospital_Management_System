import { defineConfig } from '@prisma/config';
import * as dotenv from 'dotenv';

// Load environment variables
dotenv.config();

export default defineConfig({
  schema: './prisma/schema.prisma',
  migrations: {
    // Run by `npx prisma db seed` / `npm run prisma:seed` (and after `prisma migrate reset`).
    seed: 'ts-node --transpile-only prisma/seed.ts',
  },
});
