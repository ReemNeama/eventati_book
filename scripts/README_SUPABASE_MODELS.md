# Supabase Model Updates

This directory contains scripts to update the Supabase database schema to match our models.

## Scripts

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

### `supabase_schema.sql`

This file contains the generated SQL statements to create or update tables in Supabase. It includes:
- CREATE TABLE statements for all models
- ALTER TABLE statements to add missing columns
- Proper field types and constraints

### `supabase_rls_policies.sql`

This file contains SQL statements to add Row Level Security (RLS) policies to Supabase tables. It includes:
- Enabling RLS on all tables
- Creating a function to get the current user ID
- Adding policies for SELECT, INSERT, and UPDATE operations on all tables
- Restricting access to data based on user ID

### `apply_supabase_schema.dart`

This script applies the generated SQL schema and RLS policies to your Supabase project.

**Usage:**
```bash
# First, add your Supabase service role key to the script
# Then run:
dart run scripts/apply_supabase_schema.dart
```

The script will:
1. Read the schema SQL file
2. Read the RLS policies SQL file
3. Apply the schema SQL to your Supabase project
4. Apply the RLS policies SQL to your Supabase project

## Model-to-Table Mapping

The scripts use the following mapping between model files and database tables:

| Model File | Table Name |
|------------|------------|
| user_models/user.dart | users |
| service_models/service.dart | services |
| service_models/booking.dart | bookings |
| notification_models/notification.dart | notifications |
| event_models/event.dart | events |
| planning_models/task.dart | tasks |
| planning_models/task_category.dart | task_categories |
| planning_models/task_dependency.dart | task_dependencies |
| planning_models/guest.dart | guests |
| planning_models/budget_item.dart | budget_items |
| event_models/wizard_state.dart | wizard_states |
| event_models/wizard_connection.dart | wizard_connections |
| service_models/service_review.dart | service_reviews |
| service_models/payment.dart | payments |

## Field Naming Conventions

When updating models for Supabase compatibility, follow these conventions:

1. Use snake_case for field names in database methods:
   - `toDatabaseDoc()` should use snake_case field names (e.g., `user_id`, `created_at`)
   - `fromDatabaseDoc()` should expect snake_case field names from the database

2. Keep camelCase for Dart properties:
   - Class properties should use camelCase (e.g., `userId`, `createdAt`)
   - JSON methods (`toJson()`, `fromJson()`) can use either convention, but be consistent

## Testing

After applying the schema and RLS policies, test the following:

1. Data persistence:
   - Create, read, update, and delete operations for all models
   - Verify data integrity and relationships

2. RLS policies:
   - Verify that users can only access their own data
   - Test edge cases and error handling

## Supabase Project Information

- Project URL: https://zyycmxzabfadkyzpsper.supabase.co
- Project ID: zyycmxzabfadkyzpsper
