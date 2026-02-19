---
name: tailwindcss
description: "Styles with Tailwind CSS v4 using utility classes, CSS variables, custom themes, and dynamic values. Activates when writing or editing CSS with Tailwind, configuring themes, creating custom utilities or variants, working with dark mode, responsive layouts, or when the user mentions Tailwind, utility classes, @theme, @source, CSS variables, dark mode, or responsive design."
license: MIT
metadata:
  author: laravel
  tailwindcss: "^4.0"
---

# Tailwind CSS v4

## When to Apply

Activate this skill when:

- Writing or editing Tailwind utility classes
- Configuring themes, colors, typography, or spacing
- Creating custom utilities or variants
- Setting up dark mode or responsive layouts
- Migrating from Tailwind v3 to v4

## Documentation

Use `search-docs` for detailed Tailwind v4 patterns and documentation.

## v4 vs v3: Key Differences

v4 is fundamentally different — orient first:

| v3 | v4 |
|---|---|
| `tailwind.config.js` | No config file needed |
| `@tailwind base/components/utilities` | `@import 'tailwindcss'` |
| `content: [...]` array | `@source` directives in CSS |
| JS-based theme config | `@theme` block in CSS |
| `postcss.config.js` required | `@tailwindcss/vite` handles it |

## Project Setup (v4)

```css
/* resources/css/app.css */
@import 'tailwindcss';

/* Tell Tailwind where to scan for classes */
@source '../**/*.blade.php';
@source '../**/*.js';
@source '../**/*.vue';

/* Custom design tokens */
@theme {
    --color-brand: oklch(0.6 0.2 240);
    --font-sans: 'Inter', ui-sans-serif, system-ui;
    --spacing-18: 4.5rem;
}
```

**vite.config.js**

```js
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
    plugins: [laravel({ input: ['resources/css/app.css', ...] }), tailwindcss()],
})
```

No `postcss.config.js` needed.

## Customizing the Theme

All customization lives in the `@theme` block using CSS variables:

```css
@theme {
    /* Colors — use oklch for perceptual uniformity */
    --color-primary-50: oklch(0.97 0.02 240);
    --color-primary-500: oklch(0.6 0.2 240);
    --color-primary-900: oklch(0.25 0.12 240);

    /* Typography */
    --font-display: 'Playfair Display', serif;
    --text-2xs: 0.625rem;
    --text-2xs--line-height: 0.875rem;

    /* Spacing */
    --spacing-18: 4.5rem;
    --spacing-128: 32rem;

    /* Border radius */
    --radius-2xl: 1.25rem;

    /* Breakpoints */
    --breakpoint-3xl: 120rem;
}
```

These generate utilities automatically: `bg-primary-500`, `font-display`, `text-2xs`, `mt-18`, `rounded-2xl`, `3xl:...`.

## CSS Variable Values

```html
<!-- Use CSS variables directly as utility values -->
<div class="bg-(--color-brand) text-(--font-sans)">

<!-- Arbitrary values still work -->
<div class="mt-[17px] bg-[#bada55] grid-cols-[1fr_2fr]">
```

## Custom Utilities

```css
@utility truncate-2 {
    overflow: hidden;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
}

@utility container-center {
    max-width: 80rem;
    margin-inline: auto;
    padding-inline: 1.5rem;
}
```

Usage: `class="truncate-2 container-center"`.

## Custom Variants

```css
/* Combined hover+focus */
@variant hocus (&:hover, &:focus) {
}

/* Feature query variant */
@variant supports-grid {
    @supports (display: grid) {
        @slot;
    }
}
```

Usage: `hocus:opacity-80`, `supports-grid:grid`.

## Dark Mode

Class-based dark mode works out of the box:

```html
<div class="bg-white dark:bg-gray-900 text-gray-900 dark:text-white">
```

To switch to system preference:

```css
@variant dark (@media (prefers-color-scheme: dark));
```

## Responsive Design

Mobile-first breakpoints: `sm` (640px) `md` (768px) `lg` (1024px) `xl` (1280px) `2xl` (1536px)

```html
<div class="flex flex-col sm:flex-row lg:grid lg:grid-cols-3">
```

## Common Patterns

```html
<!-- Card -->
<div class="rounded-xl border border-gray-200 bg-white p-6 shadow-sm dark:border-gray-800 dark:bg-gray-900">

<!-- Primary button -->
<button class="inline-flex items-center gap-2 rounded-lg bg-primary-600 px-4 py-2 text-sm font-medium text-white hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2">

<!-- Form input -->
<input class="block w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm placeholder-gray-400 focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500 dark:border-gray-700 dark:bg-gray-800 dark:text-white">

<!-- Badge -->
<span class="inline-flex items-center rounded-full bg-green-100 px-2.5 py-0.5 text-xs font-medium text-green-800 dark:bg-green-900/30 dark:text-green-400">
```

## Common Pitfalls

- Do not create `tailwind.config.js` in v4 — use `@theme` in CSS for all customization
- `@tailwind base/components/utilities` is removed — use `@import 'tailwindcss'`
- Class scanning is via `@source` directives, not a `content` array
- Dynamic class construction (`bg-${color}-500`) won't be detected — always use complete class strings or safelist with `@source`
- `@tailwindcss/vite` replaces `postcss.config.js` — don't configure both
- `text-opacity-*` and `bg-opacity-*` are removed — use slash syntax: `text-black/50`, `bg-blue-500/30`
- `divide-*` and `ring-*` utilities still exist but check v4 docs for any syntax changes
