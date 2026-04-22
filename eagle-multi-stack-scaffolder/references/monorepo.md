# Monorepo Architecture Reference

## Research Queries
- "Turborepo best practices 2025 2026"
- "Monorepo vs polyrepo 2025"
- "Turborepo remote caching Railway"
- "Monorepo with multiple languages 2025"
- "pnpm workspaces vs npm workspaces"

## When to Use a Monorepo

### Use Monorepo When:
- Multiple apps share code (types, utilities, components)
- You want unified CI/CD and versioning
- Team works across multiple packages
- Need atomic commits across packages
- Shared development environment

### Avoid Monorepo When:
- Teams are completely independent
- Different deployment lifecycles
- Very large codebases (>1M LOC)
- Need strict access control per package

---

## Tool Selection

| Tool | Best For | Language Support |
|------|----------|------------------|
| **Turborepo** | JS/TS monorepos, speed | JavaScript/TypeScript |
| **Nx** | Enterprise, generators | JavaScript/TypeScript |
| **pnpm Workspaces** | Simple JS monorepos | JavaScript/TypeScript |
| **Bazel** | Multi-language, large scale | Any language |

### Recommended: Turborepo + pnpm

Turborepo provides:
- Incremental builds (only rebuild what changed)
- Remote caching (share cache across CI/team)
- Parallel execution
- Task pipelines

---

## Project Structure

### Full-Stack Monorepo
```
my-project/
├── apps/
│   ├── web/                     # Next.js frontend
│   │   ├── package.json
│   │   └── src/
│   ├── mobile/                  # Expo React Native
│   │   ├── package.json
│   │   └── src/
│   ├── api/                     # Node.js backend
│   │   ├── package.json
│   │   └── src/
│   └── admin/                   # Admin dashboard
│       ├── package.json
│       └── src/
├── packages/
│   ├── ui/                      # Shared UI components
│   │   ├── package.json
│   │   └── src/
│   ├── utils/                   # Shared utilities
│   │   ├── package.json
│   │   └── src/
│   ├── types/                   # Shared TypeScript types
│   │   ├── package.json
│   │   └── src/
│   ├── config/                  # Shared configs
│   │   ├── eslint/
│   │   ├── typescript/
│   │   └── tailwind/
│   └── database/                # Database client & types
│       ├── package.json
│       └── src/
├── turbo.json                   # Turborepo config
├── package.json                 # Root package.json
├── pnpm-workspace.yaml          # pnpm workspaces
└── .github/
    └── workflows/
        └── ci.yml               # CI/CD
```

---

## Initial Setup

### 1. Create Monorepo

```bash
# Create directory
mkdir my-project && cd my-project

# Initialize with pnpm
pnpm init

# Create workspace config
cat > pnpm-workspace.yaml << 'EOF'
packages:
  - 'apps/*'
  - 'packages/*'
EOF

# Install Turborepo
pnpm add -D turbo

# Create turbo.json
cat > turbo.json << 'EOF'
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env.*local"],
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "!.next/cache/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "dependsOn": ["^build"]
    },
    "typecheck": {
      "dependsOn": ["^build"]
    },
    "test": {
      "dependsOn": ["^build"]
    },
    "db:push": {
      "cache": false
    },
    "db:generate": {
      "cache": false
    }
  }
}
EOF
```

### 2. Root package.json

```json
{
  "name": "my-project",
  "private": true,
  "scripts": {
    "build": "turbo run build",
    "dev": "turbo run dev",
    "lint": "turbo run lint",
    "typecheck": "turbo run typecheck",
    "test": "turbo run test",
    "clean": "turbo run clean && rm -rf node_modules",
    "db:push": "turbo run db:push",
    "db:generate": "turbo run db:generate"
  },
  "devDependencies": {
    "turbo": "^2.0.0"
  },
  "packageManager": "pnpm@9.0.0"
}
```

---

## Package Configuration

### Shared UI Package

**packages/ui/package.json:**
```json
{
  "name": "@my-project/ui",
  "version": "0.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "exports": {
    ".": "./src/index.ts",
    "./button": "./src/button.tsx",
    "./card": "./src/card.tsx"
  },
  "scripts": {
    "lint": "eslint src/",
    "typecheck": "tsc --noEmit"
  },
  "devDependencies": {
    "@my-project/config": "workspace:*",
    "typescript": "^5.0.0"
  },
  "peerDependencies": {
    "react": "^18.0.0"
  }
}
```

**packages/ui/src/index.ts:**
```typescript
export * from './button';
export * from './card';
export * from './input';
```

**packages/ui/src/button.tsx:**
```typescript
import { forwardRef, ButtonHTMLAttributes } from 'react';

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = 'primary', size = 'md', ...props }, ref) => {
    return (
      <button
        ref={ref}
        className={`btn btn-${variant} btn-${size} ${className}`}
        {...props}
      />
    );
  }
);

Button.displayName = 'Button';
```

### Shared Types Package

**packages/types/package.json:**
```json
{
  "name": "@my-project/types",
  "version": "0.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "exports": {
    ".": "./src/index.ts"
  }
}
```

**packages/types/src/index.ts:**
```typescript
// User types
export interface User {
  id: string;
  email: string;
  name: string | null;
  avatarUrl: string | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateUserInput {
  email: string;
  name?: string;
}

// API Response types
export interface ApiResponse<T> {
  success: boolean;
  data: T;
  error?: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    page: number;
    perPage: number;
    total: number;
    totalPages: number;
  };
}
```

### Shared Utils Package

**packages/utils/package.json:**
```json
{
  "name": "@my-project/utils",
  "version": "0.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "exports": {
    ".": "./src/index.ts"
  }
}
```

**packages/utils/src/index.ts:**
```typescript
export function formatDate(date: Date): string {
  return new Intl.DateTimeFormat('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  }).format(date);
}

export function slugify(text: string): string {
  return text
    .toLowerCase()
    .replace(/[^\w\s-]/g, '')
    .replace(/\s+/g, '-');
}

export function truncate(text: string, length: number): string {
  if (text.length <= length) return text;
  return text.slice(0, length) + '...';
}
```

### Database Package (Prisma)

**packages/database/package.json:**
```json
{
  "name": "@my-project/database",
  "version": "0.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "exports": {
    ".": "./src/index.ts"
  },
  "scripts": {
    "db:generate": "prisma generate",
    "db:push": "prisma db push",
    "db:migrate": "prisma migrate dev",
    "db:studio": "prisma studio"
  },
  "dependencies": {
    "@prisma/client": "^5.0.0"
  },
  "devDependencies": {
    "prisma": "^5.0.0"
  }
}
```

**packages/database/src/index.ts:**
```typescript
import { PrismaClient } from '@prisma/client';

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient };

export const prisma = globalForPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}

export * from '@prisma/client';
```

---

## App Configuration

### Next.js App

**apps/web/package.json:**
```json
{
  "name": "@my-project/web",
  "version": "0.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev --port 3000",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "@my-project/ui": "workspace:*",
    "@my-project/types": "workspace:*",
    "@my-project/utils": "workspace:*",
    "next": "^14.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  }
}
```

### API App

**apps/api/package.json:**
```json
{
  "name": "@my-project/api",
  "version": "0.0.0",
  "private": true,
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "lint": "eslint src/",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "@my-project/database": "workspace:*",
    "@my-project/types": "workspace:*",
    "@my-project/utils": "workspace:*",
    "express": "^4.18.0",
    "zod": "^3.22.0"
  },
  "devDependencies": {
    "@types/express": "^4.17.0",
    "tsx": "^4.0.0",
    "typescript": "^5.0.0"
  }
}
```

### Expo App

**apps/mobile/package.json:**
```json
{
  "name": "@my-project/mobile",
  "version": "0.0.0",
  "private": true,
  "main": "expo-router/entry",
  "scripts": {
    "dev": "expo start",
    "android": "expo run:android",
    "ios": "expo run:ios",
    "lint": "eslint src/",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "@my-project/types": "workspace:*",
    "@my-project/utils": "workspace:*",
    "expo": "~51.0.0",
    "expo-router": "~3.5.0",
    "react": "18.2.0",
    "react-native": "0.74.0"
  }
}
```

---

## Shared Configs

### ESLint Config

**packages/config/eslint/package.json:**
```json
{
  "name": "@my-project/eslint-config",
  "version": "0.0.0",
  "private": true,
  "main": "index.js"
}
```

**packages/config/eslint/index.js:**
```javascript
module.exports = {
  extends: ['eslint:recommended', 'plugin:@typescript-eslint/recommended'],
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint'],
  rules: {
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    '@typescript-eslint/no-explicit-any': 'warn',
  },
};
```

### TypeScript Config

**packages/config/typescript/base.json:**
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  }
}
```

**packages/config/typescript/nextjs.json:**
```json
{
  "extends": "./base.json",
  "compilerOptions": {
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "lib": ["DOM", "DOM.Iterable", "ESNext"],
    "jsx": "preserve",
    "plugins": [{ "name": "next" }]
  }
}
```

---

## Turbo Pipeline Configuration

**turbo.json** (complete):
```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env.*local"],
  "globalEnv": ["NODE_ENV", "DATABASE_URL"],
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", "!.next/cache/**"],
      "env": ["NODE_ENV"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "dependsOn": ["^build"],
      "outputs": []
    },
    "typecheck": {
      "dependsOn": ["^build"],
      "outputs": []
    },
    "test": {
      "dependsOn": ["^build"],
      "outputs": ["coverage/**"]
    },
    "clean": {
      "cache": false
    },
    "@my-project/database#db:generate": {
      "cache": false
    },
    "@my-project/database#db:push": {
      "cache": false
    }
  }
}
```

---

## Remote Caching

### Vercel Remote Cache (Free)

```bash
# Login to Vercel
pnpm dlx turbo login

# Link to Vercel project
pnpm dlx turbo link
```

### Self-Hosted Remote Cache

For Railway or self-hosted, use [Turborepo Remote Cache](https://github.com/ducktors/turborepo-remote-cache):

```bash
# Add to CI environment
TURBO_TOKEN=your-token
TURBO_TEAM=your-team
TURBO_API=https://your-cache-server.railway.app
```

---

## CI/CD with GitHub Actions

**.github/workflows/ci.yml:**
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  TURBO_TOKEN: ${{ secrets.TURBO_TOKEN }}
  TURBO_TEAM: ${{ vars.TURBO_TEAM }}

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: pnpm/action-setup@v3
        with:
          version: 9

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Lint
        run: pnpm lint

      - name: Typecheck
        run: pnpm typecheck

      - name: Build
        run: pnpm build

      - name: Test
        run: pnpm test
```

---

## Deployment: Railway

### Per-App Deployment

Each app gets its own Railway service:

**apps/api/railway.json:**
```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS",
    "buildCommand": "pnpm turbo run build --filter=@my-project/api..."
  },
  "deploy": {
    "startCommand": "node apps/api/dist/index.js",
    "healthcheckPath": "/health"
  }
}
```

**apps/web/railway.json:**
```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS",
    "buildCommand": "pnpm turbo run build --filter=@my-project/web..."
  },
  "deploy": {
    "startCommand": "pnpm --filter @my-project/web start"
  }
}
```

### Deploy Commands

```bash
# Deploy specific app
railway up --service api

# Deploy all
railway up
```

---

## Filtering Commands

```bash
# Run command for specific package
pnpm turbo run build --filter=@my-project/web

# Run for package and its dependencies
pnpm turbo run build --filter=@my-project/web...

# Run for all packages that depend on a package
pnpm turbo run build --filter=...@my-project/ui

# Run for packages changed since main
pnpm turbo run build --filter=[main]
```

---

## Common Tasks

### Add a New Package

```bash
mkdir -p packages/new-package
cd packages/new-package

cat > package.json << 'EOF'
{
  "name": "@my-project/new-package",
  "version": "0.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts"
}
EOF

mkdir src
touch src/index.ts
```

### Add Dependency Between Packages

```bash
# Add workspace dependency
pnpm add @my-project/utils --filter @my-project/web
```

### Run Dev for Specific Apps

```bash
# Run only web and api
pnpm turbo run dev --filter=@my-project/web --filter=@my-project/api
```

---

## Setup Commands

```bash
# Create monorepo
mkdir my-project && cd my-project
pnpm init

# Workspace config
cat > pnpm-workspace.yaml << 'EOF'
packages:
  - 'apps/*'
  - 'packages/*'
EOF

# Install turbo
pnpm add -D turbo

# Create structure
mkdir -p apps/{web,api,mobile}
mkdir -p packages/{ui,types,utils,config/{eslint,typescript},database}

# Initialize apps
cd apps/web && pnpm create next-app . --typescript --tailwind --eslint --app
cd ../api && pnpm init
cd ../mobile && pnpm create expo-app .

# Run dev
pnpm turbo run dev
```

---

## Key Rules

- Use pnpm workspaces with Turborepo for best performance
- Keep shared code in `packages/`, apps in `apps/`
- Use `workspace:*` for internal dependencies
- Configure turbo.json pipelines for correct build order
- Use remote caching for CI speed
- Filter builds in CI to only build changed packages
- Each app deploys independently to Railway
