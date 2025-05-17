# Manual Schema Application Instructions

If the automated script fails to apply the schema and RLS policies, you can apply them manually using the Supabase SQL Editor.

## Steps

1. Log in to the Supabase dashboard at https://app.supabase.io/
2. Select your project: "Eventati Book"
3. Go to the SQL Editor
4. Create a new query

## Step 1: Create the exec_sql function

Copy and paste the following SQL into the SQL Editor and run it:

```sql
-- Create a function to execute SQL statements
CREATE OR REPLACE FUNCTION exec_sql(sql text) RETURNS void AS $$
BEGIN
  EXECUTE sql;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to the service role
GRANT EXECUTE ON FUNCTION exec_sql(text) TO service_role;
```

## Step 2: Apply the Schema

Copy and paste the contents of `scripts/supabase_schema.sql` into the SQL Editor and run it.

## Step 3: Apply the RLS Policies

Copy and paste the contents of `scripts/supabase_rls_policies.sql` into the SQL Editor and run it.

## Verification

After applying the schema and RLS policies, you can verify that they were applied correctly by:

1. Going to the "Table Editor" in the Supabase dashboard
2. Checking that all the tables were created
3. Clicking on a table and going to the "Policies" tab to verify that the RLS policies were applied

## Troubleshooting

If you encounter any errors:

1. Check the error message for details
2. Make sure you have the necessary permissions
3. Try running the SQL statements in smaller chunks
4. Check for any syntax errors in the SQL statements
