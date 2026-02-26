---
name: create-livewire-component
description: Scaffold a Livewire component with tenant scoping, Pest test file, and route registration. Use when building owner-facing UI components.
---

# Create Livewire Component

## Prerequisites

- Read `08-owner-flow.md` for the component specification
- Read `15-design-system.md` for UI patterns (buttons, forms, cards)
- Read `04-multi-tenancy.md` for tenant scoping

## Checklist

1. **Generate the component:**
   ```bash
   php artisan make:livewire {ComponentName}
   ```
   This creates:
   - `app/Livewire/{ComponentName}.php`
   - `resources/views/livewire/{component-name}.blade.php`

2. **Apply municipality scoping:**
   - Inject `CurrentMunicipality` or use `currentMunicipality()` helper
   - All DB queries must scope by `municipality_id`
   - Owner access: use `auth()->user()->ownerFor(currentMunicipality())`
   - Session keys: prefix with municipality ID (e.g., `checkout.{$municipality->id}.cart`)

3. **Apply middleware in route registration:**
   ```php
   // routes/web.php
   Route::middleware(['auth', 'verified', 'role:owner', 'municipality'])
       ->prefix('municipality/{municipalityCode}')
       ->name('municipality.')
       ->group(function () {
           Route::get('/{path}', {ComponentName}::class)
               ->name('{route-name}');
       });
   ```

4. **Follow design system patterns (`15-design-system.md`):**
   - Page layout: Use `<x-layouts.municipality>` wrapper
   - Form fields: Standard Tailwind with `focus:ring-primary-500` focus states
   - Buttons: Primary (`bg-primary-600`), secondary (`bg-white border`), danger (`bg-danger-600`)
   - Cards: `bg-white rounded-xl shadow-card p-6`
   - Typography: Fraunces for headings (`font-display`), Figtree for body (`font-body`)
   - Max form width: `max-w-form` (640px / 40rem)

5. **Write Pest test:**
   ```php
   // tests/Feature/Livewire/{ComponentName}Test.php
   use Livewire\Livewire;

   it('renders for authenticated owner', function () {
       $municipality = Municipality::factory()->create(['code' => 'TST']);
       $user = User::factory()->create();
       $user->assignRole('owner');
       $owner = Owner::factory()->for($municipality)->create(['user_id' => $user->id]);

       Livewire::actingAs($user)
           ->test({ComponentName}::class, ['municipalityCode' => 'TST'])
           ->assertSuccessful();
   });

   it('blocks unauthenticated access', function () {
       $municipality = Municipality::factory()->create(['code' => 'TST']);

       $this->get(route('municipality.{route-name}', ['municipalityCode' => 'TST']))
           ->assertRedirect(route('login'));
   });
   ```

6. **Commit:**
   ```bash
   git add app/Livewire/ resources/views/livewire/ tests/Feature/Livewire/ routes/
   git commit -m "feat: add {ComponentName} Livewire component"
   ```

## Key Patterns

### Owner Resolution
```php
$owner = auth()->user()->ownerFor(currentMunicipality());
```

### Session Scoping
```php
$cartKey = "checkout.{$this->municipality->id}.cart";
session()->put($cartKey, $cart);
```

### Empty Pricing (No License Available)
```php
$options = $pricingService->calculateForPet($pet);
if ($options->isEmpty()) {
    // No license available — show message, don't add to cart
}
```

## Reference

- Component specs: `08-owner-flow.md`
- Checkout flow: `07-payment-gateway.md`
- Design patterns: `15-design-system.md`
- Tenancy: `04-multi-tenancy.md`
