# Nuxt.js Reference

## Research Queries
- "Nuxt 3 best practices 2025 2026"
- "Nuxt 3 project structure large applications"
- "Nuxt UI vs PrimeVue vs Vuetify 2025"
- "Nuxt 3 composables patterns"

## Package Manager
**Bun** - Fast installs for Vue/Nuxt projects.

```bash
bunx nuxi@latest init my-app
cd my-app
bun install
```

## Project Structure

```
├── app/
│   ├── app.vue
│   └── error.vue
├── components/
│   ├── ui/
│   └── farmers/
├── composables/
│   ├── useFarmers.ts
│   └── useAuth.ts
├── layouts/
│   ├── default.vue
│   └── dashboard.vue
├── middleware/
│   └── auth.ts
├── pages/
│   ├── index.vue
│   ├── login.vue
│   ├── dashboard/
│   │   └── index.vue
│   └── farmers/
│       ├── index.vue
│       └── [id].vue
├── server/
│   ├── api/
│   │   └── farmers/
│   │       ├── index.get.ts
│   │       └── index.post.ts
│   └── utils/
├── stores/
│   └── auth.ts
└── types/
```

## Essential Libraries

```bash
bun add @nuxt/ui                  # Nuxt UI (recommended)
bun add @pinia/nuxt pinia         # State management
bun add @vee-validate/nuxt zod    # Forms
bun add @vueuse/nuxt              # Utilities
```

## nuxt.config.ts

```typescript
export default defineNuxtConfig({
  modules: [
    '@nuxt/ui',
    '@pinia/nuxt',
    '@vee-validate/nuxt',
    '@vueuse/nuxt',
  ],
  ui: { icons: ['heroicons', 'lucide'] },
});
```

## Code Patterns

### Composable
```typescript
// composables/useFarmers.ts
export function useFarmers() {
  return useFetch<Farmer[]>('/api/farmers', { key: 'farmers' });
}

export function useFarmer(id: string | Ref<string>) {
  const farmerId = toRef(id);
  return useFetch(() => `/api/farmers/${farmerId.value}`, {
    key: `farmer-${farmerId.value}`,
  });
}
```

### Server API Route
```typescript
// server/api/farmers/index.get.ts
export default defineEventHandler(async (event) => {
  const farmers = await prisma.farmer.findMany();
  return { data: farmers };
});

// server/api/farmers/index.post.ts
export default defineEventHandler(async (event) => {
  const body = await readBody(event);
  const farmer = await prisma.farmer.create({ data: body });
  return farmer;
});
```

### Pinia Store
```typescript
// stores/auth.ts
export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null);
  const isAuthenticated = computed(() => !!user.value);
  
  async function login(email: string, password: string) {
    const response = await $fetch('/api/auth/login', {
      method: 'POST',
      body: { email, password },
    });
    user.value = response.user;
  }
  
  return { user, isAuthenticated, login };
}, { persist: true });
```

### Page
```vue
<script setup lang="ts">
definePageMeta({ layout: 'dashboard', middleware: ['auth'] });
const { data: farmers, pending } = await useFarmers();
</script>

<template>
  <div class="p-6">
    <h1 class="text-2xl font-bold mb-6">Farmers</h1>
    <UTable :rows="farmers ?? []" :loading="pending" />
  </div>
</template>
```

## Setup Commands

```bash
bunx nuxi@latest init my-app
cd my-app

bun add @nuxt/ui @pinia/nuxt pinia
bun add @vee-validate/nuxt zod @vueuse/nuxt

bun dev
```

## Key Rules

- Components, composables, utils are auto-imported
- Use Nuxt UI for consistent components
- Use composables for data fetching
- Server routes follow file naming convention (.get.ts, .post.ts)
