# Hospital Backend API

Express + Prisma backend powering the AegisCare mobile app.

## Prerequisites

- Node.js 18+
- npm 9+
- Optional: Docker (for the bundled Postgres instance)

## Setup

1. Install dependencies:
   ```powershell
   cd c:\Users\User\calculator\hospital_backend
   cmd /c npm install
   ```
2. Copy `.env.example` to `.env` and set `JWT_SECRET` to a long random value.
   The server refuses to start without it (placeholders like `change-me` are rejected).
   In production also set `FRONTEND_URL` (allowed browser origins) and, behind a proxy, `TRUST_PROXY_HOPS`.
3. (Recommended) Start Postgres via Docker:
   ```powershell
   cd c:\Users\User\calculator\hospital_backend
   docker compose up -d
   ```
   > Alternatively, update `DATABASE_URL` to point at your own PostgreSQL server.
4. Run migrations and seed data:
   ```powershell
   cmd /c npm run prisma:migrate -- --name init
   cmd /c npm run prisma:seed
   ```
5. Start the dev server:
   ```powershell
   cmd /c npm run dev
   ```

## API quick reference

- `GET /health` – service heartbeat
- `GET /auth/roles` – list available roles for registration flows
- `POST /auth/register` – create user (requires role from `/auth/roles`)
- `POST /auth/login` – authenticate and receive access/refresh tokens
- `POST /auth/refresh` – rotate refresh token
- `GET /auth/me` – fetch authenticated user profile (requires bearer token)
- `GET /dashboard/options` – fetch dashboard cards for the logged-in user

## Testing

```powershell
cmd /c npm test
```

## Linting / Type-checking

```powershell
cmd /c npm run lint
```

## Seed Data

Run it with `npm run prisma:seed` (or `npx prisma db seed`; the command is configured in `prisma.config.ts`). It is safe to run repeatedly. It creates the roles from `src/constants/roles.ts`, dashboard shortcuts for each role, and one demo login per role (`admin@hospital.com` / `admin123`, `doctor@hospital.com` / `doctor123`, …; see `prisma/seed.ts`). The demo logins are marked `isDemo`, which is what Developer Mode may impersonate.

**Never seed a production database**: the demo passwords are public. Customize `prisma/seed.ts` to add more fixtures.
