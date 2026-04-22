# Next.js Reference

## Research Queries
- "Next.js 15 best practices 2025 2026"
- "Next.js App Router vs Pages Router"
- "Next.js server components vs client components"
- "shadcn/ui Next.js setup"

## Package Manager
**Bun** - Fast installs, works great with Next.js.

```bash
bunx create-next-app@latest my-app --typescript --tailwind --eslint --app --src-dir
```

## Project Structure (App Router)

```
src/
├── app/
│   ├── layout.tsx
│   ├── page.tsx
│   ├── loading.tsx
│   ├── error.tsx
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   └── register/page.tsx
│   ├── (dashboard)/
│   │   ├── layout.tsx
│   │   ├── dashboard/page.tsx
│   │   └── farmers/
│   │       ├── page.tsx
│   │       └── [id]/page.tsx
│   └── api/
│       └── farmers/route.ts
├── components/
│   ├── ui/                   # shadcn/ui
│   ├── forms/
│   └── layout/
├── lib/
│   ├── utils.ts
│   └── api.ts
├── hooks/
├── services/
├── stores/
└── types/
```

## Essential Libraries

```bash
# UI (shadcn/ui)
bunx shadcn-ui@latest init
bunx shadcn-ui@latest add button card input form table

# State
bun add zustand @tanstack/react-query

# Forms
bun add react-hook-form @hookform/resolvers zod

# Utils
bun add clsx tailwind-merge lucide-react
```

## Code Patterns

### Server Component (Data Fetching)
```tsx
// app/(dashboard)/farmers/page.tsx
import { getFarmers } from '@/services/farmer-service';

export default async function FarmersPage() {
  const farmers = await getFarmers();
  return <FarmersTable data={farmers} />;
}
```

### Client Component
```tsx
'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

export function FarmerForm() {
  const form = useForm({ resolver: zodResolver(schema) });
  // ...
}
```

### API Route
```tsx
// app/api/farmers/route.ts
import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
  const farmers = await prisma.farmer.findMany();
  return NextResponse.json({ data: farmers });
}

export async function POST(request: NextRequest) {
  const body = await request.json();
  const farmer = await prisma.farmer.create({ data: body });
  return NextResponse.json(farmer, { status: 201 });
}
```

### React Query Hook
```tsx
'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';

export function useFarmers() {
  return useQuery({
    queryKey: ['farmers'],
    queryFn: () => fetch('/api/farmers').then(r => r.json()),
  });
}

export function useCreateFarmer() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data) => fetch('/api/farmers', {
      method: 'POST',
      body: JSON.stringify(data),
    }),
    onSuccess: () => queryClient.invalidateQueries(['farmers']),
  });
}
```

## Setup Commands

```bash
bunx create-next-app@latest my-app --typescript --tailwind --eslint --app --src-dir
cd my-app

bunx shadcn-ui@latest init
bunx shadcn-ui@latest add button card input form table

bun add zustand @tanstack/react-query
bun add react-hook-form @hookform/resolvers zod

bun dev
```

## Key Rules

- Server Components are default (no 'use client')
- Only add 'use client' for interactivity/hooks
- Use Server Actions for mutations when possible
- Prefer server-side data fetching
