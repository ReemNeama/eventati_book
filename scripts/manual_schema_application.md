# Manual Schema Application Instructions

Since the automated scripts are encountering issues, please follow these manual steps to apply the schema and RLS policies using the Supabase SQL Editor.

## Step 1: Create the exec_sql function

1. In the Supabase SQL Editor, click on "New Query"
2. Copy and paste the following SQL:

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

3. Click "Run" to execute the query

## Step 2: Create Tables

1. Create a new query
2. Copy and paste the following SQL:

```sql
-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- SQL for table: users
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY,
  name text NOT NULL,
  email text NOT NULL,
  phone_number text,
  profile_image_url text,
  created_at timestamp with time zone NOT NULL,
  favorite_venues text[] NOT NULL,
  favorite_services text[] NOT NULL,
  has_premium_subscription boolean NOT NULL,
  is_beta_tester boolean NOT NULL,
  subscription_expiration_date timestamp with time zone,
  email_verified boolean NOT NULL,
  auth_provider text NOT NULL
);

-- SQL for table: services
CREATE TABLE IF NOT EXISTS services (
  id uuid PRIMARY KEY,
  name text NOT NULL,
  description text NOT NULL,
  category_id text NOT NULL,
  vendor_id text NOT NULL,
  price numeric NOT NULL,
  currency text NOT NULL,
  is_price_per_hour boolean NOT NULL,
  minimum_booking_hours integer,
  maximum_capacity integer,
  image_urls text[] NOT NULL,
  thumbnail_urls text[] NOT NULL,
  average_rating numeric NOT NULL,
  review_count integer NOT NULL,
  location text,
  is_available boolean NOT NULL,
  is_featured boolean NOT NULL,
  tags text[] NOT NULL,
  created_at timestamp with time zone NOT NULL,
  updated_at timestamp with time zone NOT NULL
);

-- SQL for table: bookings
CREATE TABLE IF NOT EXISTS bookings (
  id uuid PRIMARY KEY,
  user_id text NOT NULL,
  service_id text NOT NULL,
  service_type text NOT NULL,
  service_name text NOT NULL,
  booking_date_time timestamp with time zone NOT NULL,
  duration numeric NOT NULL,
  guest_count integer NOT NULL,
  special_requests text NOT NULL,
  status text NOT NULL,
  total_price numeric NOT NULL,
  service_options jsonb NOT NULL,
  created_at timestamp with time zone NOT NULL,
  updated_at timestamp with time zone NOT NULL,
  contact_name text NOT NULL,
  contact_email text NOT NULL,
  contact_phone text NOT NULL,
  event_id text,
  event_name text,
  payment_id text,
  payment_status text
);

-- SQL for table: notifications
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY,
  user_id text NOT NULL,
  title text NOT NULL,
  body text NOT NULL,
  type text NOT NULL,
  data jsonb,
  read boolean NOT NULL,
  created_at timestamp with time zone NOT NULL,
  related_entity_id text
);

-- SQL for table: events
CREATE TABLE IF NOT EXISTS events (
  id uuid PRIMARY KEY,
  name text NOT NULL,
  type text NOT NULL,
  date timestamp with time zone NOT NULL,
  location text NOT NULL,
  budget numeric NOT NULL,
  guest_count integer NOT NULL,
  description text,
  user_id text,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  status text,
  image_urls text[] NOT NULL
);

-- SQL for table: tasks
CREATE TABLE IF NOT EXISTS tasks (
  id uuid PRIMARY KEY,
  title text NOT NULL,
  description text,
  due_date timestamp with time zone NOT NULL,
  status text NOT NULL,
  category_id text NOT NULL,
  assigned_to text,
  is_important boolean NOT NULL,
  notes text,
  completed_date timestamp with time zone,
  priority text NOT NULL,
  is_service_related boolean NOT NULL,
  service_id text,
  dependencies text[] NOT NULL,
  event_id text,
  service text
);

-- SQL for table: task_categories
CREATE TABLE IF NOT EXISTS task_categories (
  id uuid PRIMARY KEY,
  name text NOT NULL,
  description text NOT NULL,
  icon text NOT NULL,
  color text NOT NULL,
  order integer NOT NULL,
  is_default boolean NOT NULL,
  is_active boolean NOT NULL,
  created_at timestamp with time zone NOT NULL,
  updated_at timestamp with time zone NOT NULL
);

-- SQL for table: task_dependencies
CREATE TABLE IF NOT EXISTS task_dependencies (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  prerequisite_task_id text NOT NULL,
  dependent_task_id text NOT NULL,
  type text NOT NULL,
  offset_days integer NOT NULL,
  created_at timestamp with time zone NOT NULL,
  updated_at timestamp with time zone NOT NULL
);

-- SQL for table: guests
CREATE TABLE IF NOT EXISTS guests (
  id uuid PRIMARY KEY,
  name text NOT NULL,
  description text,
  color text,
  guests jsonb NOT NULL
);

-- SQL for table: budget_items
CREATE TABLE IF NOT EXISTS budget_items (
  id uuid PRIMARY KEY,
  name text NOT NULL,
  icon text NOT NULL
);

-- SQL for table: wizard_states
CREATE TABLE IF NOT EXISTS wizard_states (
  id uuid PRIMARY KEY,
  template text NOT NULL,
  current_step integer NOT NULL,
  total_steps integer NOT NULL,
  event_name text NOT NULL,
  selected_event_type text,
  event_date timestamp with time zone,
  guest_count integer,
  selected_services text NOT NULL,
  event_duration integer NOT NULL,
  daily_start_time text,
  daily_end_time text,
  needs_setup boolean NOT NULL,
  setup_hours integer NOT NULL,
  needs_teardown boolean NOT NULL,
  teardown_hours integer NOT NULL,
  is_completed boolean NOT NULL,
  last_updated timestamp with time zone NOT NULL
);

-- SQL for table: wizard_connections
CREATE TABLE IF NOT EXISTS wizard_connections (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id text NOT NULL,
  event_id text NOT NULL,
  wizard_state_id text NOT NULL,
  budget_enabled boolean NOT NULL,
  guest_list_enabled boolean NOT NULL,
  timeline_enabled boolean NOT NULL,
  service_recommendations_enabled boolean NOT NULL,
  budget_item_ids text[] NOT NULL,
  guest_group_ids text[] NOT NULL,
  task_ids text[] NOT NULL,
  service_recommendation_ids text[] NOT NULL,
  created_at timestamp with time zone NOT NULL,
  updated_at timestamp with time zone NOT NULL
);

-- SQL for table: service_reviews
CREATE TABLE IF NOT EXISTS service_reviews (
  id uuid PRIMARY KEY,
  service_id text NOT NULL,
  user_id text NOT NULL,
  user_name text NOT NULL,
  rating numeric NOT NULL,
  comment text NOT NULL,
  image_urls text[] NOT NULL,
  is_verified boolean NOT NULL,
  created_at timestamp with time zone NOT NULL,
  updated_at timestamp with time zone NOT NULL
);

-- SQL for table: payments
CREATE TABLE IF NOT EXISTS payments (
  id uuid PRIMARY KEY,
  booking_id text NOT NULL,
  user_id text NOT NULL,
  amount numeric NOT NULL,
  currency text NOT NULL,
  status text NOT NULL,
  payment_intent_id text,
  payment_method_id text,
  created_at timestamp with time zone NOT NULL,
  updated_at timestamp with time zone
);
```

3. Click "Run" to execute the query

## Step 3: Enable RLS and Create Policies

1. Create a new query
2. Copy and paste the following SQL:

```sql
-- Enable Row Level Security on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE task_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE task_dependencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE guests ENABLE ROW LEVEL SECURITY;
ALTER TABLE budget_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE wizard_states ENABLE ROW LEVEL SECURITY;
ALTER TABLE wizard_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Create a function to get the current user ID
CREATE OR REPLACE FUNCTION auth.get_auth_user_id() RETURNS TEXT AS $$
BEGIN
  RETURN auth.uid()::TEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

3. Click "Run" to execute the query

## Step 4: Create RLS Policies (Part 1)

1. Create a new query
2. Copy and paste the following SQL:

```sql
-- Users table policies
-- Users can only read their own profile
CREATE POLICY "Users can read own profile" ON users
  FOR SELECT USING (id = auth.get_auth_user_id());

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (id = auth.get_auth_user_id());

-- Services table policies
-- Anyone can read services
CREATE POLICY "Anyone can read services" ON services
  FOR SELECT USING (true);

-- Bookings table policies
-- Users can read their own bookings
CREATE POLICY "Users can read own bookings" ON bookings
  FOR SELECT USING (user_id = auth.get_auth_user_id());

-- Users can create their own bookings
CREATE POLICY "Users can create own bookings" ON bookings
  FOR INSERT WITH CHECK (user_id = auth.get_auth_user_id());

-- Users can update their own bookings
CREATE POLICY "Users can update own bookings" ON bookings
  FOR UPDATE USING (user_id = auth.get_auth_user_id());

-- Notifications table policies
-- Users can read their own notifications
CREATE POLICY "Users can read own notifications" ON notifications
  FOR SELECT USING (user_id = auth.get_auth_user_id());

-- Users can update their own notifications (e.g., mark as read)
CREATE POLICY "Users can update own notifications" ON notifications
  FOR UPDATE USING (user_id = auth.get_auth_user_id());

-- Events table policies
-- Users can read their own events
CREATE POLICY "Users can read own events" ON events
  FOR SELECT USING (user_id = auth.get_auth_user_id());

-- Users can create their own events
CREATE POLICY "Users can create own events" ON events
  FOR INSERT WITH CHECK (user_id = auth.get_auth_user_id());

-- Users can update their own events
CREATE POLICY "Users can update own events" ON events
  FOR UPDATE USING (user_id = auth.get_auth_user_id());
```

3. Click "Run" to execute the query

## Step 5: Create RLS Policies (Part 2)

1. Create a new query
2. Copy and paste the following SQL:

```sql
-- Tasks table policies
-- Users can read their own tasks
CREATE POLICY "Users can read own tasks" ON tasks
  FOR SELECT USING (event_id IN (
    SELECT id FROM events WHERE user_id = auth.get_auth_user_id()
  ));

-- Users can create their own tasks
CREATE POLICY "Users can create own tasks" ON tasks
  FOR INSERT WITH CHECK (event_id IN (
    SELECT id FROM events WHERE user_id = auth.get_auth_user_id()
  ));

-- Users can update their own tasks
CREATE POLICY "Users can update own tasks" ON tasks
  FOR UPDATE USING (event_id IN (
    SELECT id FROM events WHERE user_id = auth.get_auth_user_id()
  ));

-- Task Categories table policies
-- Users can read all task categories
CREATE POLICY "Users can read all task categories" ON task_categories
  FOR SELECT USING (true);

-- Task Dependencies table policies
-- Users can read their own task dependencies
CREATE POLICY "Users can read own task dependencies" ON task_dependencies
  FOR SELECT USING (prerequisite_task_id IN (
    SELECT id FROM tasks WHERE event_id IN (
      SELECT id FROM events WHERE user_id = auth.get_auth_user_id()
    )
  ));

-- Users can create their own task dependencies
CREATE POLICY "Users can create own task dependencies" ON task_dependencies
  FOR INSERT WITH CHECK (prerequisite_task_id IN (
    SELECT id FROM tasks WHERE event_id IN (
      SELECT id FROM events WHERE user_id = auth.get_auth_user_id()
    )
  ));

-- Users can update their own task dependencies
CREATE POLICY "Users can update own task dependencies" ON task_dependencies
  FOR UPDATE USING (prerequisite_task_id IN (
    SELECT id FROM tasks WHERE event_id IN (
      SELECT id FROM events WHERE user_id = auth.get_auth_user_id()
    )
  ));
```

3. Click "Run" to execute the query

## Step 6: Create RLS Policies (Part 3)

1. Create a new query
2. Copy and paste the following SQL:

```sql
-- Guests table policies
-- Users can read their own guests
CREATE POLICY "Users can read own guests" ON guests
  FOR SELECT USING (id IN (
    SELECT unnest(guest_group_ids) FROM wizard_connections WHERE user_id = auth.get_auth_user_id()
  ));

-- Users can create their own guests
CREATE POLICY "Users can create own guests" ON guests
  FOR INSERT WITH CHECK (true); -- Will be restricted at the application level

-- Users can update their own guests
CREATE POLICY "Users can update own guests" ON guests
  FOR UPDATE USING (id IN (
    SELECT unnest(guest_group_ids) FROM wizard_connections WHERE user_id = auth.get_auth_user_id()
  ));

-- Budget Items table policies
-- Users can read their own budget items
CREATE POLICY "Users can read own budget items" ON budget_items
  FOR SELECT USING (id IN (
    SELECT unnest(budget_item_ids) FROM wizard_connections WHERE user_id = auth.get_auth_user_id()
  ));

-- Users can create their own budget items
CREATE POLICY "Users can create own budget items" ON budget_items
  FOR INSERT WITH CHECK (true); -- Will be restricted at the application level

-- Users can update their own budget items
CREATE POLICY "Users can update own budget items" ON budget_items
  FOR UPDATE USING (id IN (
    SELECT unnest(budget_item_ids) FROM wizard_connections WHERE user_id = auth.get_auth_user_id()
  ));

-- Wizard States table policies
-- Users can read their own wizard states
CREATE POLICY "Users can read own wizard states" ON wizard_states
  FOR SELECT USING (id IN (
    SELECT wizard_state_id FROM wizard_connections WHERE user_id = auth.get_auth_user_id()
  ));

-- Users can create their own wizard states
CREATE POLICY "Users can create own wizard states" ON wizard_states
  FOR INSERT WITH CHECK (true); -- Will be restricted at the application level

-- Users can update their own wizard states
CREATE POLICY "Users can update own wizard states" ON wizard_states
  FOR UPDATE USING (id IN (
    SELECT wizard_state_id FROM wizard_connections WHERE user_id = auth.get_auth_user_id()
  ));
```

3. Click "Run" to execute the query

## Step 7: Create RLS Policies (Part 4)

1. Create a new query
2. Copy and paste the following SQL:

```sql
-- Wizard Connections table policies
-- Users can read their own wizard connections
CREATE POLICY "Users can read own wizard connections" ON wizard_connections
  FOR SELECT USING (user_id = auth.get_auth_user_id());

-- Users can create their own wizard connections
CREATE POLICY "Users can create own wizard connections" ON wizard_connections
  FOR INSERT WITH CHECK (user_id = auth.get_auth_user_id());

-- Users can update their own wizard connections
CREATE POLICY "Users can update own wizard connections" ON wizard_connections
  FOR UPDATE USING (user_id = auth.get_auth_user_id());

-- Service Reviews table policies
-- Anyone can read service reviews
CREATE POLICY "Anyone can read service reviews" ON service_reviews
  FOR SELECT USING (true);

-- Users can create their own service reviews
CREATE POLICY "Users can create own service reviews" ON service_reviews
  FOR INSERT WITH CHECK (user_id = auth.get_auth_user_id());

-- Users can update their own service reviews
CREATE POLICY "Users can update own service reviews" ON service_reviews
  FOR UPDATE USING (user_id = auth.get_auth_user_id());

-- Payments table policies
-- Users can read their own payments
CREATE POLICY "Users can read own payments" ON payments
  FOR SELECT USING (user_id = auth.get_auth_user_id());

-- Users can create their own payments
CREATE POLICY "Users can create own payments" ON payments
  FOR INSERT WITH CHECK (user_id = auth.get_auth_user_id());

-- Users can update their own payments
CREATE POLICY "Users can update own payments" ON payments
  FOR UPDATE USING (user_id = auth.get_auth_user_id());
```

3. Click "Run" to execute the query

## Step 8: Verify Schema and RLS Policies

1. Go to the "Table Editor" in the Supabase dashboard
2. Check that all the tables were created
3. Click on a table and go to the "Policies" tab to verify that the RLS policies were applied

## Troubleshooting

If you encounter any errors:

1. Check the error message for details
2. Make sure you have the necessary permissions
3. Try running the SQL statements in smaller chunks
4. Check for any syntax errors in the SQL statements
