---
name: laravel
description: "Organizes Laravel applications using actions, services, DTOs, events, observers, policies, model scopes, and form requests. Activates when structuring business logic, choosing between actions vs services vs jobs, extracting logic from controllers or models, implementing authorization, decoupling with events, or when the user mentions architecture, refactor, service layer, action class, DTO, observer, policy, scope, or best practices."
license: MIT
metadata:
  author: laravel
  laravel: "^12.0"
---

# Laravel Architecture & Best Practices

## When to Apply

Activate this skill when:

- Deciding where to put business logic (controller vs service vs action vs job)
- Extracting logic out of fat controllers or fat models
- Structuring authorization, events, observers, or model scopes
- Choosing between architecture patterns
- Refactoring toward cleaner, more maintainable code

## Documentation

Use `search-docs` for detailed Laravel patterns and documentation.

## Choosing the Right Pattern

| Need | Use |
|------|-----|
| Single operation, reusable | Action class |
| Multiple related operations | Service class |
| Background / async work | Job (ShouldQueue) |
| React to model changes | Observer or Event |
| Enforce authorization | Policy |
| Reusable query constraints | Eloquent Scope |
| Structured data between layers | DTO |
| HTTP input validation | Form Request |

## Action Classes

Single-responsibility classes for one business operation. Prefer over services when the operation is discrete:

```php
// app/Actions/CreateInvoice.php
class CreateInvoice
{
    public function handle(Order $order, array $lineItems): Invoice
    {
        return DB::transaction(function () use ($order, $lineItems) {
            $invoice = Invoice::create([
                'order_id' => $order->id,
                'total'    => collect($lineItems)->sum('amount'),
            ]);

            $invoice->lineItems()->createMany($lineItems);

            event(new InvoiceCreated($invoice));

            return $invoice;
        });
    }
}

// Usage — inject via constructor or resolve directly
app(CreateInvoice::class)->handle($order, $lineItems);
```

Keep actions focused: one public method (`handle`), no state between calls.

## Service Classes

Group related operations when multiple actions share dependencies (e.g. an API client):

```php
// app/Services/StripeService.php
class StripeService
{
    public function __construct(private readonly Stripe\StripeClient $stripe) {}

    public function charge(User $user, int $amountCents): PaymentIntent { ... }
    public function refund(string $paymentIntentId): Refund { ... }
    public function createCustomer(User $user): Customer { ... }
}
```

Register in `AppServiceProvider` if the constructor needs configuration:

```php
$this->app->singleton(StripeService::class, fn () =>
    new StripeService(new Stripe\StripeClient(config('services.stripe.secret')))
);
```

## DTOs (Data Transfer Objects)

Use readonly classes to pass structured data between layers instead of raw arrays:

```php
// app/Data/CreateOrderData.php
readonly class CreateOrderData
{
    public function __construct(
        public string $customerEmail,
        public array $lineItems,
        public ?string $couponCode = null,
    ) {}

    public static function fromRequest(CreateOrderRequest $request): self
    {
        return new self(
            customerEmail: $request->input('email'),
            lineItems: $request->input('items'),
            couponCode: $request->input('coupon'),
        );
    }
}

// In controller
$data = CreateOrderData::fromRequest($request);
app(CreateOrder::class)->handle($data);
```

## Form Requests

Always use Form Requests for validation — never validate inline in controllers:

```php
// app/Http/Requests/StoreOrderRequest.php
class StoreOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('create', Order::class);
    }

    public function rules(): array
    {
        return [
            'email'          => ['required', 'email', 'max:255'],
            'items'          => ['required', 'array', 'min:1'],
            'items.*.id'     => ['required', 'integer', 'exists:products,id'],
            'items.*.qty'    => ['required', 'integer', 'min:1'],
            'coupon'         => ['nullable', 'string', 'exists:coupons,code'],
        ];
    }

    public function messages(): array
    {
        return [
            'items.required' => 'At least one item is required.',
        ];
    }
}
```

## Policies

Centralize authorization logic in Policy classes — never scatter `abort(403)` in controllers:

```php
php artisan make:policy OrderPolicy --model=Order
```

```php
class OrderPolicy
{
    public function view(User $user, Order $order): bool
    {
        return $user->id === $order->user_id || $user->isAdmin();
    }

    public function update(User $user, Order $order): bool
    {
        return $user->id === $order->user_id && $order->isPending();
    }

    public function delete(User $user, Order $order): bool
    {
        return $user->isAdmin();
    }
}
```

Usage:

```php
// Controller
$this->authorize('update', $order);

// Blade
@can('update', $order) ... @endcan

// Inline
Gate::allows('update', $order)
```

Policies auto-discover when named `{Model}Policy` and placed in `app/Policies/`.

## Events & Listeners

Decouple side effects from core logic with events. Fire the event in the action; listeners handle the side effects:

```php
// app/Events/InvoiceCreated.php
class InvoiceCreated
{
    public function __construct(public readonly Invoice $invoice) {}
}

// app/Listeners/SendInvoiceEmail.php
class SendInvoiceEmail
{
    public function handle(InvoiceCreated $event): void
    {
        Mail::to($event->invoice->customer)->send(new InvoiceMailable($event->invoice));
    }
}
```

Register in `AppServiceProvider` (Laravel 12 auto-discovers listeners in `app/Listeners/` that type-hint an event in `handle()`):

```php
// Only needed if auto-discovery is disabled
Event::listen(InvoiceCreated::class, SendInvoiceEmail::class);
```

Make listeners queueable by adding `ShouldQueue`:

```php
class SendInvoiceEmail implements ShouldQueue
{
    public string $queue = 'notifications';
    ...
}
```

## Observers

Use observers when you need to react to multiple Eloquent events on one model:

```php
php artisan make:observer OrderObserver --model=Order
```

```php
class OrderObserver
{
    public function created(Order $order): void
    {
        Cache::tags('orders')->flush();
    }

    public function updated(Order $order): void
    {
        if ($order->wasChanged('status')) {
            event(new OrderStatusChanged($order));
        }
    }

    public function deleted(Order $order): void
    {
        $order->lineItems()->delete();
    }
}
```

Register in `AppServiceProvider::boot()`:

```php
Order::observe(OrderObserver::class);
```

Prefer **Events/Listeners** when the reaction involves other services. Use **Observers** when logic is tightly coupled to the model lifecycle.

## Eloquent Scopes

Keep query logic in models with local scopes; never repeat `where` chains across the codebase:

```php
// app/Models/Order.php
class Order extends Model
{
    // Local scope — usage: Order::query()->pending()->...
    public function scopePending(Builder $query): void
    {
        $query->where('status', OrderStatus::Pending);
    }

    public function scopeForUser(Builder $query, User $user): void
    {
        $query->where('user_id', $user->id);
    }

    public function scopeWithinDateRange(Builder $query, Carbon $from, Carbon $to): void
    {
        $query->whereBetween('created_at', [$from, $to]);
    }
}

// Usage
Order::query()->pending()->forUser($user)->latest()->get();
```

## Model Accessors & Casts

Use casts for type conversion, accessors for computed/formatted values:

```php
class Order extends Model
{
    protected function casts(): array
    {
        return [
            'status'     => OrderStatus::class,  // Enum cast
            'metadata'   => 'array',
            'shipped_at' => 'datetime',
            'total'      => 'integer',            // store cents
        ];
    }

    // Accessor — $order->formatted_total
    protected function formattedTotal(): Attribute
    {
        return Attribute::get(fn () => '$' . number_format($this->total / 100, 2));
    }
}
```

## Controller Conventions

Keep controllers thin — one action per method, delegate to actions/services:

```php
class OrderController extends Controller
{
    public function store(StoreOrderRequest $request, CreateOrder $action): RedirectResponse
    {
        $order = $action->handle(CreateOrderData::fromRequest($request));

        return redirect()->route('orders.show', $order)
            ->with('success', 'Order created.');
    }
}
```

Avoid: business logic, direct model manipulation, multiple responsibilities.

## Directory Structure Conventions

```
app/
├── Actions/          # Single-responsibility operations
├── Data/             # DTOs and value objects
├── Events/           # Domain events
├── Exceptions/       # Custom exception classes
├── Http/
│   ├── Controllers/  # Thin — delegate to actions/services
│   ├── Middleware/
│   └── Requests/     # Form Request validation
├── Jobs/             # Queued/async work
├── Listeners/        # Event handlers
├── Mail/             # Mailable classes
├── Models/           # Eloquent models
├── Notifications/    # Notification classes
├── Observers/        # Model lifecycle observers
├── Policies/         # Authorization
├── Providers/        # Service providers
└── Services/         # Stateful/multi-method service classes
```

## Common Pitfalls

- Fat controllers — if a controller method exceeds ~15 lines, extract to an action
- Fat models — models should not contain business logic; use actions and services
- Skipping Form Requests — inline `$request->validate()` in controllers doesn't give you authorization or reusability
- Skipping Policies — `abort_if($user->id !== $record->user_id, 403)` scattered in controllers is unmaintainable
- Over-using Observers for everything — they make the code hard to follow; prefer explicit events for cross-concern side effects
- Repository pattern in Laravel — Eloquent scopes + actions cover 95% of use cases without the abstraction overhead; only add repositories if swapping ORMs is a real requirement
- Dispatching events inside model `boot()` — use observers or dispatch in the action after the DB operation completes
- Calling `event()` before a transaction commits — wrap in `DB::transaction()` and let events fire after the commit, or use `DB::afterCommit()`
