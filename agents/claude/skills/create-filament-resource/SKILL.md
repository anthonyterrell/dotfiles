---
name: create-filament-resource
description: Generate a Filament resource following project conventions (municipality tenancy, Shield permissions, relation managers, design system colors). Use when creating admin panel resources.
---

# Create Filament Resource

## Prerequisites

- Read `09-admin-panel.md` for the resource specification
- Read `15-design-system.md` for color/styling conventions
- Read `04-multi-tenancy.md` for tenancy scoping

## Checklist

1. **Generate the resource scaffold:**
   ```bash
   php artisan make:filament-resource {ModelName} --generate
   ```

2. **Apply municipality tenancy:**
   - Add `->modifyQueryUsing()` to scope queries by current municipality
   - Use `BelongsToMunicipality` trait on the model if not already present
   - Filter all list queries: `->modifyQueryUsing(fn ($query) => $query->where('municipality_id', Filament::getTenant()->id))`

3. **Apply Shield permissions:**
   - Do NOT manually define policies — Shield auto-generates them
   - Run `php artisan shield:generate --resource={ModelName}Resource` after creating the resource
   - Verify the auto-generated permissions exist: `view_any_{model}`, `view_{model}`, `create_{model}`, `update_{model}`, `delete_{model}`

4. **Follow role restrictions (I8):**
   - `super-admin`: Full access to all resources
   - `admin`: Full access within their municipality
   - `staff`: View + create + update (no delete) within their municipality
   - `owner`: No admin panel access

5. **Design system colors (from `15-design-system.md`):**
   - Primary actions: `primary` color (blue-green #0C7C59)
   - Danger actions: `danger` color (red #DC2626)
   - Success indicators: `success` color (green #16A34A)
   - Info/neutral: `gray` color

6. **Add relation managers** for HasMany relationships:
   ```bash
   php artisan make:filament-relation-manager {Resource} {relation} {titleAttribute}
   ```

7. **Write Pest test:**
   ```php
   // tests/Feature/Admin/{ModelName}ResourceTest.php
   use function Pest\Livewire\livewire;

   it('lists {models} for admin', function () {
       $admin = User::factory()->create();
       $admin->assignRole('admin');
       $municipality = Municipality::factory()->create();

       $this->actingAs($admin);
       Filament::setTenant($municipality);

       livewire({ModelName}Resource\Pages\List{ModelNames}::class)
           ->assertSuccessful();
   });

   it('denies access to owners', function () {
       $owner = User::factory()->create();
       $owner->assignRole('owner');

       $this->actingAs($owner)
           ->get({ModelName}Resource::getUrl())
           ->assertForbidden();
   });
   ```

8. **Commit:**
   ```bash
   git add app/Filament/ tests/Feature/Admin/
   git commit -m "feat: add {ModelName} Filament resource with tenancy and permissions"
   ```

## Reference

- Resource specs: `09-admin-panel.md`
- Tenancy pattern: `04-multi-tenancy.md` section "Admin Panel Tenancy"
- Permission matrix: `05-authentication-authorization.md` section "Roles"
- Design tokens: `15-design-system.md` section "Filament Panel Configuration"
