# Supabase Schema Update Script

This directory contains a script to help update your Supabase database schema to match your Dart models.

## Available Script

### `update_supabase_schema.dart`

This script generates SQL statements to update your Supabase database schema to match your Dart models.

**Usage:**
```bash
dart run scripts/update_supabase_schema.dart
```

The script will:
1. Parse all your model files
2. Extract field definitions (name, type, nullability)
3. Generate SQL statements to create or update tables in Supabase
4. Save the SQL to `scripts/supabase_schema.sql`

For more details, see [README_SUPABASE_SCHEMA.md](./README_SUPABASE_SCHEMA.md).

## How to Use

1. Generate the SQL statements:
   ```bash
   dart run scripts/update_supabase_schema.dart
   ```

2. Apply the generated SQL to your Supabase database:
   - Open the Supabase dashboard
   - Go to the SQL Editor
   - Copy and paste the contents of `scripts/supabase_schema.sql`
   - Run the SQL

## Table to Model Mapping

The scripts use the following mapping between database tables and model files:

| Table | Model File |
|-------|------------|
| users | user_models/user.dart |
| services | service_models/service.dart |
| bookings | service_models/booking.dart |
| notifications | notification_models/notification.dart |
| events | event_models/event.dart |
| tasks | planning_models/task.dart |
| guests | planning_models/guest.dart |
| budget_items | planning_models/budget_item.dart |
| wizard_states | event_models/wizard_state.dart |
| wizard_connections | event_models/wizard_connection.dart |
| service_reviews | service_models/service_review.dart |
| payments | service_models/payment.dart |

## Notes

- The scripts use a predefined schema for each table based on the current Supabase database structure.
- If the database schema changes, you'll need to update the `tableSchemas` in the scripts.
- The scripts handle field name conversion between snake_case (database) and camelCase (Dart).
- Type mapping is provided for common PostgreSQL types to Dart types.
