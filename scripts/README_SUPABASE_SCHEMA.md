# Supabase Schema Update Script

This script generates SQL statements to update your Supabase database schema to match your Dart models.

## How to Use

1. Run the script to generate the SQL:
   ```bash
   dart run scripts/update_supabase_schema.dart
   ```

2. The script will:
   - Parse all your model files
   - Extract field definitions (name, type, nullability)
   - Generate SQL statements to create or update tables in Supabase
   - Save the SQL to `scripts/supabase_schema.sql`

3. Apply the generated SQL to your Supabase database:
   - Open the Supabase dashboard
   - Go to the SQL Editor
   - Copy and paste the contents of `scripts/supabase_schema.sql`
   - Run the SQL

## Important Notes

- The script handles field name conversion from camelCase (Dart) to snake_case (PostgreSQL)
- It maps Dart types to PostgreSQL types (String → text, int → integer, etc.)
- It preserves nullability (nullable fields in Dart become nullable columns in PostgreSQL)
- It generates both CREATE TABLE statements (for new tables) and ALTER TABLE statements (for existing tables)
- For enum types in Dart, it uses text type in PostgreSQL

## Type Mappings

| Dart Type | PostgreSQL Type |
|-----------|----------------|
| String | text |
| int | integer |
| double | numeric |
| bool | boolean |
| DateTime | timestamp with time zone |
| Map<String, dynamic> | jsonb |
| List<String> | text[] |
| List<int> | integer[] |
| List<double> | numeric[] |
| Other List types | jsonb |

## Customization

If you need to customize the SQL generation:

1. Edit the `dartToPostgresTypeMapping` in the script to change type mappings
2. Modify the `generateTableSQL` function to change the SQL generation logic
3. Update the `modelToTableMapping` if you add new models or change file paths

## Troubleshooting

- **NOT NULL constraint errors**: If you get errors about NOT NULL constraints when applying the SQL, you may need to modify the SQL to make those columns nullable or provide default values.
- **Type conversion errors**: If you get type conversion errors, you may need to adjust the type mappings in the script.
- **Existing data conflicts**: If you have existing data that doesn't match the new schema, you may need to migrate the data before applying the schema changes.

## Example

For a model like:

```dart
class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final DateTime createdAt;
}
```

The script will generate SQL like:

```sql
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY,
  name text NOT NULL,
  email text NOT NULL,
  phone_number text,
  created_at timestamp with time zone NOT NULL
);

ALTER TABLE users ADD COLUMN IF NOT EXISTS name text NOT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS email text NOT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_number text;
ALTER TABLE users ADD COLUMN IF NOT EXISTS created_at timestamp with time zone NOT NULL;
```
