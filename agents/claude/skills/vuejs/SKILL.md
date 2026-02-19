---
name: vuejs
description: "Builds Vue 3 components using the Composition API with script setup, reactive state, computed properties, watchers, lifecycle hooks, composables, and Inertia.js integration. Activates when creating or editing Vue components, using ref/reactive/computed, handling events, writing composables, integrating with Inertia.js, or when the user mentions Vue, component, ref, reactive, computed, composable, Inertia, useForm, defineProps, or script setup."
license: MIT
metadata:
  author: laravel
  vue: "^3.0"
---

# Vue 3

## When to Apply

Activate this skill when:

- Creating or editing Vue single-file components (`.vue`)
- Using the Composition API (`ref`, `reactive`, `computed`, `watch`)
- Writing composables or handling component events
- Integrating Vue 3 with Laravel via Inertia.js
- Migrating from Vue 2 Options API to Composition API

## Documentation

Use `search-docs` for detailed Vue 3 and Inertia.js patterns and documentation.

## Component Structure

Always use `<script setup>` — it's the recommended, most concise Composition API form:

```vue
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

// Props (typed generics — no defineProps call needed at runtime)
const props = defineProps<{
    title: string
    items: Item[]
    loading?: boolean
}>()

// Emits
const emit = defineEmits<{
    select: [item: Item]
    close: []
}>()

// State
const search = ref('')
const selectedId = ref<number | null>(null)

// Computed
const filteredItems = computed(() =>
    props.items.filter(i => i.name.includes(search.value))
)

function select(item: Item): void {
    selectedId.value = item.id
    emit('select', item)
}

onMounted(() => {
    // runs after DOM insertion
})
</script>

<template>
    <div>
        <input v-model="search" type="text" />
        <button
            v-for="item in filteredItems"
            :key="item.id"
            @click="select(item)"
        >
            {{ item.name }}
        </button>
    </div>
</template>
```

## Reactive State

```ts
import { ref, reactive, toRefs } from 'vue'

// ref — primitives and objects; access via .value in script, auto-unwrapped in template
const count = ref(0)
count.value++

// reactive — objects only; no .value needed
const form = reactive({ name: '', email: '' })
form.name = 'Taylor'

// toRefs — destructure reactive without losing reactivity
const { name, email } = toRefs(form)
```

## Computed Properties

```ts
import { ref, computed } from 'vue'

const search = ref('')
const allUsers = ref<User[]>([])

const filteredUsers = computed(() =>
    allUsers.value.filter(u => u.name.includes(search.value))
)

// Writable computed
const fullName = computed({
    get: () => `${firstName.value} ${lastName.value}`,
    set: (val) => {
        const [first, last] = val.split(' ')
        firstName.value = first
        lastName.value = last
    },
})
```

## Watchers

```ts
import { watch, watchEffect } from 'vue'

// watch — explicit sources, lazy by default
watch(search, (newVal) => fetchResults(newVal))

// Run immediately
watch(userId, fetchUser, { immediate: true })

// Deep watch on objects
watch(formData, save, { deep: true })

// Multiple sources
watch([a, b], ([newA, newB]) => { /* ... */ })

// watchEffect — auto-tracks dependencies, always immediate
watchEffect(() => {
    document.title = `${filteredUsers.value.length} users`
})
```

## Lifecycle Hooks

```ts
import { onMounted, onUnmounted, onUpdated, onBeforeUnmount } from 'vue'

onMounted(() => { /* DOM ready */ })
onUpdated(() => { /* after reactive update triggers re-render */ })
onBeforeUnmount(() => { /* cleanup */ })
onUnmounted(() => { /* DOM removed */ })
```

## Composables

Extract reusable stateful logic into `useX` functions in `composables/`:

```ts
// composables/useUsers.ts
export function useUsers() {
    const users = ref<User[]>([])
    const loading = ref(false)
    const error = ref<string | null>(null)

    async function fetchUsers(): Promise<void> {
        loading.value = true
        try {
            users.value = await api.get('/users')
        } catch (e) {
            error.value = 'Failed to load users'
        } finally {
            loading.value = false
        }
    }

    return { users, loading, error, fetchUsers }
}

// In component
const { users, loading, fetchUsers } = useUsers()
onMounted(fetchUsers)
```

## Provide / Inject

```ts
// Ancestor component
import { provide, ref } from 'vue'
const theme = ref('dark')
provide('theme', theme)  // pass reactive value — child sees updates

// Any descendant
import { inject } from 'vue'
const theme = inject<Ref<string>>('theme', ref('light'))  // second arg = default
```

## defineExpose (template refs)

```ts
// ChildComponent.vue
defineExpose({ reset, focus })

// Parent
const childRef = ref<InstanceType<typeof ChildComponent>>()
childRef.value?.reset()
```

## Inertia.js (Laravel Integration)

```ts
import { router, useForm, usePage } from '@inertiajs/vue3'
import { Link } from '@inertiajs/vue3'

// Shared page props from Laravel (HandleInertiaRequests middleware)
const page = usePage()
const auth = computed(() => page.props.auth as { user: User })

// Form handling with server-side validation errors
const form = useForm({ name: '', email: '' })

function submit(): void {
    form.post('/users', {
        onSuccess: () => form.reset(),
        onError: () => { /* form.errors.name etc. */ },
    })
}

// Programmatic navigation
router.visit('/users')
router.get('/users', { search: 'taylor' }, { preserveState: true })
router.delete(`/users/${id}`, { onSuccess: () => router.visit('/users') })
```

```vue
<template>
    <!-- Inertia link (intercepts navigation, no full page reload) -->
    <Link href="/users">Users</Link>
    <Link href="/users/1" method="delete" as="button">Delete</Link>

    <!-- Form errors -->
    <input v-model="form.name" />
    <span v-if="form.errors.name">{{ form.errors.name }}</span>
    <button :disabled="form.processing" @click="submit">Save</button>
</template>
```

### Receiving Laravel Props in Pages

```vue
<script setup lang="ts">
// Props come from the Laravel controller's Inertia::render() call
const props = defineProps<{
    users: { data: User[]; links: PaginationLinks }
    filters: { search: string; status: string }
}>()

// Keep URL in sync with filter state
const search = ref(props.filters.search)
watch(search, (value) => {
    router.get('/users', { search: value }, { preserveState: true, replace: true })
})
</script>
```

## Common Pitfalls

- Forgetting `.value` on `ref` in `<script setup>` — not needed in `<template>`, required in script
- Destructuring `reactive()` objects loses reactivity — use `toRefs()` or keep as `form.name`
- Mutating props directly — emit an event or use `defineModel()` for two-way binding
- `watch` is lazy by default — add `{ immediate: true }` to run on mount
- Using `reactive()` for primitives (strings, numbers, booleans) — use `ref()` instead
- Using `$emit` string events without `defineEmits` declaration — always declare emits
- In Inertia, `useForm` manages dirty state, errors, and `processing` — don't replicate these manually with `ref`
- `router.visit()` triggers a full Inertia request; use `<Link>` for standard anchor navigation
