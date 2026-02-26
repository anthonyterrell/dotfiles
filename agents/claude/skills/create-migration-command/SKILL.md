---
name: create-migration-command
description: Generate a legacy:migrate-* Artisan command with dry-run flag, progress bar, skip-and-log orphans, and ID map building. Use when creating data migration commands.
---

# Create Migration Command

## Prerequisites

- Read `11-data-migration.md` for the migration specification
- Read `16-petdata-boundary.md` for PetData schema details
- Read `02-database-schema.md` for target schema

## Checklist

1. **Create the command:**
   ```bash
   php artisan make:command Legacy/Migrate{EntityName}
   ```
   Namespace: `App\Console\Commands\Legacy`
   Signature: `legacy:migrate-{entities}` (plural, e.g., `legacy:migrate-municipalities`)

2. **Required flags:**
   ```php
   protected $signature = 'legacy:migrate-{entities}
       {--dry-run : Preview changes without writing to the database}
       {--limit= : Limit the number of records to process}
       {--skip-errors : Continue processing on individual record errors}';
   ```

3. **Standard structure:**
   ```php
   public function handle(): int
   {
       $isDryRun = $this->option('dry-run');
       $limit = $this->option('limit');

       // 1. Query legacy database
       $query = DB::connection('legacy_petlicense')
           ->table('legacy_table');

       if ($limit) {
           $query->limit((int) $limit);
       }

       $total = $query->count();
       $bar = $this->output->createProgressBar($total);
       $bar->start();

       $migrated = 0;
       $skipped = 0;
       $errors = [];

       // 2. Process in chunks
       $query->chunk(500, function ($records) use (&$migrated, &$skipped, &$errors, $isDryRun, $bar) {
           foreach ($records as $record) {
               try {
                   $mapped = $this->mapRecord($record);

                   if (!$this->validateRecord($mapped, $record)) {
                       $skipped++;
                       $bar->advance();
                       continue;
                   }

                   if (!$isDryRun) {
                       $newModel = TargetModel::create($mapped);
                       // Store in ID map for FK resolution
                       $this->idMap[$record->id] = $newModel->id;
                   }

                   $migrated++;
               } catch (\Exception $e) {
                   $errors[] = [
                       'legacy_id' => $record->id,
                       'error' => $e->getMessage(),
                   ];

                   if (!$this->option('skip-errors')) {
                       throw $e;
                   }
               }

               $bar->advance();
           }
       });

       $bar->finish();
       $this->newLine(2);

       // 3. Report
       $this->info("Migrated: {$migrated}");
       $this->warn("Skipped: {$skipped}");
       if (count($errors)) {
           $this->error("Errors: " . count($errors));
           foreach ($errors as $err) {
               $this->line("  - Legacy ID {$err['legacy_id']}: {$err['error']}");
           }
       }

       if ($isDryRun) {
           $this->warn('DRY RUN — no records were written.');
       }

       return self::SUCCESS;
   }
   ```

4. **ID Map building:**
   - Store `legacy_id → new_uuid` mapping for each migrated record
   - Use for FK resolution in dependent migrations
   - Pattern: `$this->idMap[$legacyId] = $newModel->id`
   - For integer-PK legacy tables: `legacy_id` column is `int unsigned`
   - For UUID-PK legacy tables: `legacy_id` column is `char(36)`

5. **Orphan handling:**
   - When a FK reference is missing (e.g., owner references a non-existent municipality):
   - Log the orphan with full context
   - Skip the record (don't create with null FK)
   - Report orphaned records in the summary

6. **Legacy database connections:**
   ```php
   // config/database.php connections:
   'legacy_petlicense' => [/* ... */],
   'legacy_petdata' => [/* ... */],
   ```

7. **Write Pest test:**
   ```php
   // tests/Feature/Commands/Migrate{EntityName}Test.php
   it('migrates {entities} from legacy database', function () {
       // Seed legacy database with test data
       DB::connection('legacy_petlicense')->table('legacy_table')->insert([...]);

       $this->artisan('legacy:migrate-{entities}')
           ->assertExitCode(0);

       expect(TargetModel::count())->toBe(1);
   });

   it('supports dry run mode', function () {
       DB::connection('legacy_petlicense')->table('legacy_table')->insert([...]);

       $this->artisan('legacy:migrate-{entities} --dry-run')
           ->assertExitCode(0);

       expect(TargetModel::count())->toBe(0);
   });
   ```

8. **Commit:**
   ```bash
   git add app/Console/Commands/Legacy/ tests/Feature/Commands/
   git commit -m "feat: add legacy:migrate-{entities} command"
   ```

## Migration Order

Commands must run in dependency order:

1. `legacy:migrate-states`
2. `legacy:migrate-species-breeds`
3. `legacy:migrate-colors`
4. `legacy:migrate-municipalities`
5. `legacy:migrate-users`
6. `legacy:migrate-owners`
7. `legacy:migrate-pets`
8. `legacy:migrate-vaccinations`
9. `legacy:migrate-invoices`
10. `legacy:migrate-licenses`
11. `legacy:migrate-transactions`
12. `legacy:migrate-tags`
13. `legacy:migrate-proofs`
14. `legacy:migrate-pricing-rules`

## Reference

- Migration specs: `11-data-migration.md`
- Pre-migration audit: `11a-pre-migration-audit.md`
- PetData schema: `16-petdata-boundary.md`
- Target schema: `02-database-schema.md`
- Decisions: `DECISIONS-NEEDED.md` (D6 for legacy_id types, I14 for command namespace)
