# Node.js + Express Reference

## Research Queries
- "Node.js best practices 2025 2026"
- "Express.js vs Fastify vs Hono 2025"
- "Prisma vs Drizzle ORM 2025"
- "Railway Node.js deployment 2025"
- "MinIO S3 Node.js integration"

## Package Manager
**Bun** - Faster runtime, built-in TypeScript, native .env support.

```bash
bun init
bun add express @types/express typescript
```

---

## Database Selection

| Database | Use Case | Driver |
|----------|----------|--------|
| **PostgreSQL** | Production apps, complex queries, ACID compliance | `postgres`, `pg` |
| **MongoDB** | Document-based, flexible schema, rapid prototyping | `mongodb`, `mongoose` |
| **SQLite** | Prototyping, embedded, local-first apps, edge | `better-sqlite3`, `libsql` |
| **Redis** | Caching, sessions, queues, real-time | `ioredis` |

### When to Use What
- **PostgreSQL**: Default choice for production. Relational data, transactions, complex queries.
- **MongoDB**: Flexible schemas, document storage, when structure evolves rapidly.
- **SQLite**: Local-first apps, edge deployments (Turso), prototyping, single-file database.

---

## ORM Selection

| Tool | Philosophy | Best For | Type Safety |
|------|-----------|----------|-------------|
| **Prisma** | Schema-first, declarative | Most projects, rapid dev | Excellent |
| **Drizzle** | SQL-like, lightweight | Performance, SQL lovers | Excellent |
| **Mongoose** | MongoDB ODM | MongoDB projects | Good |

### Prisma vs Drizzle

```typescript
// Prisma - Declarative, auto-generated types
const user = await prisma.user.findUnique({
  where: { id },
  include: { posts: true }
});

// Drizzle - SQL-like, explicit, faster
const user = await db.query.users.findFirst({
  where: eq(users.id, id),
  with: { posts: true }
});
```

**Choose Prisma** for: Rapid development, schema visualization, simpler APIs
**Choose Drizzle** for: Performance-critical, complex queries, SQL control

---

## Database Setup

### PostgreSQL with Prisma

```bash
bun add prisma @prisma/client
bunx prisma init
```

**schema.prisma:**
```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  avatarUrl String?
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  published Boolean  @default(false)
  author    User     @relation(fields: [authorId], references: [id], onDelete: Cascade)
  authorId  String
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([authorId])
}
```

**Prisma Client Singleton:**
```typescript
// src/lib/prisma.ts
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient };

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
});

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
```

### PostgreSQL with Drizzle

```bash
bun add drizzle-orm postgres
bun add -D drizzle-kit
```

**src/db/schema.ts:**
```typescript
import { pgTable, text, timestamp, boolean, index } from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

export const users = pgTable('users', {
  id: text('id').primaryKey().$defaultFn(() => crypto.randomUUID()),
  email: text('email').notNull().unique(),
  name: text('name'),
  avatarUrl: text('avatar_url'),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
});

export const posts = pgTable('posts', {
  id: text('id').primaryKey().$defaultFn(() => crypto.randomUUID()),
  title: text('title').notNull(),
  content: text('content'),
  published: boolean('published').default(false).notNull(),
  authorId: text('author_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
}, (t) => [index('posts_author_idx').on(t.authorId)]);

export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));

export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, { fields: [posts.authorId], references: [users.id] }),
}));
```

**src/db/index.ts:**
```typescript
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema';

const client = postgres(process.env.DATABASE_URL!, { max: 10 });
export const db = drizzle(client, { schema });
```

### MongoDB with Mongoose

```bash
bun add mongoose
```

**src/db/models/user.ts:**
```typescript
import mongoose, { Schema, Document } from 'mongoose';

export interface IUser extends Document {
  email: string;
  name?: string;
  avatarUrl?: string;
  createdAt: Date;
  updatedAt: Date;
}

const userSchema = new Schema<IUser>({
  email: { type: String, required: true, unique: true },
  name: String,
  avatarUrl: String,
}, { timestamps: true });

export const User = mongoose.model<IUser>('User', userSchema);
```

---

## Object Storage: MinIO

MinIO provides S3-compatible object storage for files, images, documents.

```bash
bun add @aws-sdk/client-s3 @aws-sdk/s3-request-presigner
```

**src/lib/storage.ts:**
```typescript
import { S3Client, PutObjectCommand, GetObjectCommand, DeleteObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

const s3 = new S3Client({
  region: 'us-east-1',
  endpoint: process.env.MINIO_ENDPOINT,        // http://localhost:9000
  credentials: {
    accessKeyId: process.env.MINIO_ACCESS_KEY!,
    secretAccessKey: process.env.MINIO_SECRET_KEY!,
  },
  forcePathStyle: true, // Required for MinIO
});

const BUCKET = process.env.MINIO_BUCKET || 'uploads';

export const storage = {
  async upload(key: string, body: Buffer, contentType: string) {
    await s3.send(new PutObjectCommand({
      Bucket: BUCKET,
      Key: key,
      Body: body,
      ContentType: contentType,
    }));
    return `${process.env.MINIO_ENDPOINT}/${BUCKET}/${key}`;
  },

  async getSignedUploadUrl(key: string, contentType: string, expiresIn = 3600) {
    const command = new PutObjectCommand({
      Bucket: BUCKET,
      Key: key,
      ContentType: contentType,
    });
    return getSignedUrl(s3, command, { expiresIn });
  },

  async getSignedDownloadUrl(key: string, expiresIn = 3600) {
    const command = new GetObjectCommand({ Bucket: BUCKET, Key: key });
    return getSignedUrl(s3, command, { expiresIn });
  },

  async delete(key: string) {
    await s3.send(new DeleteObjectCommand({ Bucket: BUCKET, Key: key }));
  },
};
```

**File Upload Endpoint:**
```typescript
import multer from 'multer';
import { storage } from '../lib/storage';

const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 10 * 1024 * 1024 } });

router.post('/upload', upload.single('file'), async (req, res, next) => {
  try {
    const file = req.file!;
    const key = `${Date.now()}-${file.originalname}`;
    const url = await storage.upload(key, file.buffer, file.mimetype);
    res.json({ success: true, url, key });
  } catch (error) {
    next(error);
  }
});
```

---

## Migrations & Seeding

### Prisma
```bash
bunx prisma migrate dev --name init     # Create migration
bunx prisma migrate deploy              # Production
bunx prisma db seed                     # Run seed
```

**prisma/seed.ts:**
```typescript
import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  await prisma.user.upsert({
    where: { email: 'admin@example.com' },
    update: {},
    create: {
      email: 'admin@example.com',
      name: 'Admin',
      posts: {
        create: [{ title: 'Welcome', content: 'First post!', published: true }],
      },
    },
  });
}

main().finally(() => prisma.$disconnect());
```

### Drizzle
```bash
bunx drizzle-kit generate    # Generate migration
bunx drizzle-kit migrate     # Apply migrations
```

---

## Project Structure

```
src/
├── index.ts                  # Entry point
├── app.ts                    # Express setup
├── config/
│   └── env.ts                # Environment validation
├── db/
│   ├── index.ts              # Database client
│   ├── schema.ts             # Schema (Drizzle)
│   └── seed.ts
├── lib/
│   ├── prisma.ts             # Prisma client (if using)
│   └── storage.ts            # MinIO client
├── api/
│   ├── routes/
│   ├── controllers/
│   ├── middleware/
│   └── validators/
├── services/
├── repositories/
└── utils/
    ├── logger.ts
    └── errors.ts
```

---

## Essential Libraries

```bash
# Core
bun add express cors helmet compression zod
bun add @types/express @types/cors typescript

# Database (choose one)
bun add prisma @prisma/client                    # Prisma
bun add drizzle-orm postgres                     # Drizzle + PostgreSQL
bun add mongoose                                 # MongoDB

# Object Storage
bun add @aws-sdk/client-s3 @aws-sdk/s3-request-presigner multer
bun add @types/multer

# Auth
bun add jsonwebtoken bcryptjs
bun add @types/jsonwebtoken @types/bcryptjs

# Logging
bun add pino pino-pretty

# Dev
bun add -D @types/node tsx drizzle-kit
```

---

## Deployment: Railway

### railway.json
```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "bun run src/index.ts",
    "healthcheckPath": "/health",
    "healthcheckTimeout": 30,
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 3
  }
}
```

### Environment Variables (Railway)
```bash
DATABASE_URL=postgresql://...          # Railway PostgreSQL
MINIO_ENDPOINT=https://...             # Railway MinIO or external
MINIO_ACCESS_KEY=...
MINIO_SECRET_KEY=...
MINIO_BUCKET=uploads
JWT_SECRET=...
NODE_ENV=production
```

### Deploy Commands
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login and deploy
railway login
railway init
railway up

# Add PostgreSQL
railway add -d postgresql

# Add Redis (optional)
railway add -d redis
```

### Dockerfile (Alternative)
```dockerfile
FROM oven/bun:1 AS base
WORKDIR /app

FROM base AS deps
COPY package.json bun.lockb ./
RUN bun install --frozen-lockfile

FROM base AS runner
COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NODE_ENV=production
EXPOSE 3000

CMD ["bun", "run", "src/index.ts"]
```

---

## Code Patterns

### Environment Validation
```typescript
// src/config/env.ts
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.string().default('3000'),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  MINIO_ENDPOINT: z.string().url().optional(),
  MINIO_ACCESS_KEY: z.string().optional(),
  MINIO_SECRET_KEY: z.string().optional(),
});

export const env = envSchema.parse(process.env);
```

### Service Layer
```typescript
// src/services/user.service.ts
import { prisma } from '../lib/prisma';
import { AppError } from '../utils/errors';

export const userService = {
  async getAll(page = 1, limit = 20) {
    return prisma.user.findMany({
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { createdAt: 'desc' },
    });
  },

  async getById(id: string) {
    const user = await prisma.user.findUnique({ where: { id } });
    if (!user) throw AppError.notFound('User not found');
    return user;
  },

  async create(data: { email: string; name?: string }) {
    const existing = await prisma.user.findUnique({ where: { email: data.email } });
    if (existing) throw AppError.conflict('Email already exists');
    return prisma.user.create({ data });
  },
};
```

### Error Handling
```typescript
// src/utils/errors.ts
export class AppError extends Error {
  constructor(message: string, public statusCode = 500, public code?: string) {
    super(message);
  }
  static badRequest(msg: string) { return new AppError(msg, 400, 'BAD_REQUEST'); }
  static unauthorized(msg = 'Unauthorized') { return new AppError(msg, 401, 'UNAUTHORIZED'); }
  static notFound(msg: string) { return new AppError(msg, 404, 'NOT_FOUND'); }
  static conflict(msg: string) { return new AppError(msg, 409, 'CONFLICT'); }
}
```

---

## Setup Commands

```bash
mkdir my-api && cd my-api
bun init -y

# Dependencies
bun add express cors helmet zod pino prisma @prisma/client
bun add @aws-sdk/client-s3 @aws-sdk/s3-request-presigner
bun add -D @types/express @types/cors typescript @types/node tsx

# Prisma setup
bunx prisma init
# Edit schema.prisma
bunx prisma migrate dev --name init

# Run
bun --watch src/index.ts
```

---

## Key Rules

- Use PostgreSQL for production, SQLite for local/edge
- Always use connection pooling (Prisma handles this)
- Validate environment variables at startup with Zod
- Use MinIO for file storage (S3-compatible, works with Railway)
- Deploy to Railway with PostgreSQL addon
- Run migrations in CI/CD, not on app startup
