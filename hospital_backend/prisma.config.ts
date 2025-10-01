import { defineConfig } from '@prisma/config';
import * as dotenv from 'dotenv';

// Load environment variables
dotenv.config();

export default defineConfig({
  schema: './prisma/schema.prisma'
});
