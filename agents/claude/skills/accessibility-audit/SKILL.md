---
name: accessibility-audit
description: WCAG 2.1 AA accessibility checklist for component development. Use when building or reviewing UI components, forms, or pages.
---

# Accessibility Audit

WCAG 2.1 AA compliance checklist for all UI work. Run through this when building or reviewing any user-facing component.

## Checklist

### Forms
- [ ] All form inputs have associated `<label>` elements (use `for`/`id` pairing, not implicit wrapping alone)
- [ ] Error messages are associated with their form fields via `aria-describedby`
- [ ] Required fields are marked with `aria-required="true"` (not just visual asterisks)
- [ ] Form validation errors are announced to screen readers (use `role="alert"` or `aria-live="polite"`)
- [ ] Autocomplete attributes set on address/name/email fields (`autocomplete="given-name"`, etc.)

### Dynamic Content (Livewire)
- [ ] `wire:loading` states include `aria-busy="true"` on the container
- [ ] Alert/notification components use `role="alert"` or `aria-live="assertive"`
- [ ] Modals trap focus and return focus on close
- [ ] Livewire navigation updates announce page changes (`aria-live="polite"` region or `<title>` update)

### Color & Contrast
- [ ] Text contrast meets AA minimum: 4.5:1 for normal text, 3:1 for large text (18px+ or 14px+ bold)
- [ ] UI component contrast meets 3:1 against adjacent colors (buttons, inputs, icons)
- [ ] Information is not conveyed by color alone (use icons, text, or patterns alongside color)
- [ ] Design system tokens from `@theme` handle most contrast — verify any custom overrides

### Keyboard Navigation
- [ ] All interactive elements are reachable via Tab key
- [ ] Tab order follows logical reading order (no `tabindex` > 0)
- [ ] Focus indicators are visible (do not remove browser outlines without replacement)
- [ ] No keyboard traps — users can always Tab away from any component
- [ ] Dropdown menus and custom selects support arrow key navigation
- [ ] Escape key closes modals, dropdowns, and overlays

### Page Structure
- [ ] Skip navigation link on municipality pages (first focusable element, hidden until focused)
- [ ] Page `<title>` includes municipality name and page context (e.g., "Add Pet | Philadelphia | PetLicense")
- [ ] Heading hierarchy is logical (`h1` → `h2` → `h3`, no skipped levels)
- [ ] Landmark regions used: `<main>`, `<nav>`, `<header>`, `<footer>`
- [ ] Language attribute set on `<html>` element

### Images & Icons
- [ ] Icon-only buttons have `aria-label` or visually hidden text (e.g., `<span class="sr-only">Delete</span>`)
- [ ] Decorative images use `aria-hidden="true"` or empty `alt=""` (including the paw icon)
- [ ] Informative images have descriptive `alt` text
- [ ] SVG icons include `role="img"` and `aria-label` when meaningful

### Tables
- [ ] Data tables use `<th>` with `scope="col"` or `scope="row"`
- [ ] Tables have a `<caption>` or `aria-label` describing their purpose
- [ ] Avoid layout tables — use CSS Grid/Flexbox instead

## Quick Test Methods

1. **Tab test:** Navigate the entire page with only the keyboard
2. **Zoom test:** Zoom to 200% — no content should be lost or overlapping
3. **Color test:** View in grayscale (browser dev tools) — all information still conveyed
4. **Screen reader test:** Test key flows with NVDA (Windows), VoiceOver (macOS), or Orca (Linux)

## References

- Design system: `15-design-system.md` (color tokens, typography, component patterns)
- Owner flow: `08-owner-flow.md` (form fields, checkout wizard)
- Admin panel: `09-admin-panel.md` (Filament handles most admin accessibility)
