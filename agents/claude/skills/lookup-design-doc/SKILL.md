---
name: lookup-design-doc
description: Look up implementation details from design docs by topic keyword. Use when you need to reference a design decision, schema definition, or architectural pattern.
---

# Lookup Design Doc

When implementing a feature or fixing a bug, look up the relevant design documentation to ensure consistency with resolved decisions.

## Design Doc Index

| Topic | Primary Doc | Supporting Docs |
|-------|------------|-----------------|
| Schema / columns / tables | `02-database-schema.md` | `14-gap-resolutions.md` |
| Models / relationships / traits / enums | `03-domain-models.md` | `01-architecture.md` |
| Multi-tenancy / scoping / middleware | `04-multi-tenancy.md` | `08-owner-flow.md` |
| Auth / roles / permissions / claim flow | `05-authentication-authorization.md` | `14-gap-resolutions.md` |
| Pricing rules / fees / late fees | `06-pricing-engine.md` | `02-database-schema.md` |
| Payments / Authorize.net / checkout | `07-payment-gateway.md` | `08-owner-flow.md` |
| Owner registration / pets / checkout flow | `08-owner-flow.md` | `05-authentication-authorization.md` |
| Admin panel / Filament resources | `09-admin-panel.md` | `15-design-system.md` |
| Email / address validation / file storage | `10-external-integrations.md` | |
| Data migration / legacy mapping | `11-data-migration.md` | `16-petdata-boundary.md`, `11a-pre-migration-audit.md` |
| Testing strategy / test patterns | `12-testing-strategy.md` | |
| Phase schedule / task breakdown | `13-implementation-phases.md` | `2026-02-20-petlicense-rewrite-plan.md` |
| Gap analysis / resolved contradictions | `14-gap-resolutions.md` | `DECISIONS-NEEDED.md` |
| UI / colors / typography / components | `15-design-system.md` | `15-design-system-preview.html` |
| PetData legacy boundary | `16-petdata-boundary.md` | `11-data-migration.md` |

## Key Resolved Decisions

All 29 decisions are in `DECISIONS-NEEDED.md`. Quick reference for the most commonly needed:

- **Route prefix:** `municipality.*` (not `muni.*`) — I10
- **Permission naming:** Shield auto-generated (`view_any_*`, `view_*`, `create_*`, `update_*`, `delete_*`) — I7
- **Pricing model:** All matches returned, owner picks — B5
- **Inactive pets:** "Inactive" (expired/never licensed) + "Removed" (soft-deleted) — I17
- **Claim flow:** Reference number + last name + zip — I6
- **Migration commands:** `legacy:migrate-*` namespace — I14
- **Receipt mailable:** `PaymentReceiptMail` — I15
- **Expiration command:** `licenses:send-expiration-reminders` — I16
- **Invoice status enum:** `pending, paid, abandoned, refunded, void, partial_refund` — I18
- **Payment method:** `charge()` not `authorize()` — Fix #28
- **File storage:** Private, Storage-based (S3 prod, filesystem local) — I19

## How to Use

1. Identify the topic area from the index above
2. Read the primary doc section relevant to your task
3. Cross-reference `DECISIONS-NEEDED.md` for any resolved decisions that affect your implementation
4. Check `14-gap-resolutions.md` if you encounter an edge case or contradiction

## Doc Locations

All docs are at: `~/PhpstormProjects/petlicense/docs/` (symlinked from `~/code/petlicense/pd_rewrite/docs/`)
