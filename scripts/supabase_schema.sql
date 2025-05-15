-- SQL to update Supabase schema to match models
-- Generated on 2025-05-15 11:35:30.766318

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

-- Alter table statements to add missing columns:
ALTER TABLE users ADD COLUMN IF NOT EXISTS name text NOT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS email text NOT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_number text;
ALTER TABLE users ADD COLUMN IF NOT EXISTS profile_image_url text;
ALTER TABLE users ADD COLUMN IF NOT EXISTS created_at timestamp with time zone NOT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS favorite_venues text[] NOT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS favorite_services text[] NOT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS has_premium_subscription boolean NOT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS is_beta_tester boolean NOT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS subscription_expiration_date timestamp with time zone;
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verified boolean NOT NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS auth_provider text NOT NULL;



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

-- Alter table statements to add missing columns:
ALTER TABLE services ADD COLUMN IF NOT EXISTS name text NOT NULL;
ALTER TABLE services ADD COLUMN IF NOT EXISTS description text NOT NULL;
ALTER TABLE services ADD COLUMN IF NOT EXISTS category_id text NOT NULL;
ALTER TABLE services ADD COLUMN IF NOT EXISTS vendor_id text NOT NULL;
ALTER TABLE services ADD COLUMN IF NOT EXISTS price numeric NOT NULL;
ALTER TABLE services ADD COLUMN IF NOT EXISTS currency text NOT NULL;
ALTER TABLE services ADD COLUMN IF NOT EXISTS is_price_per_hour boolean NOT NULL;
ALTER TABLE services ADD COLUMN IF NOT EXISTS minimum_booking_hours integer;
ALTER TABLE services ADD COLUMN IF NOT EXISTS maximum_capacity integer;
ALTER TABLE services ADD COLUMN IF NOT EXISTS image_urls text[] NOT NULL;
ALTER TABLE services ADD COLUMN IF NOT EXISTS thumbnail_urls text[] NOT NULL;
ALTER TABLE services ADD COLUMN IF NOT EXISTS average_rating numeric NOT NULL;
ALTER TABLE services ADD COLUMN IF NOT EXISTS review_count integer NOT NULL;
ALTER TABLE services ADD COLUMN IF NOT EXISTS location text;
ALTER TABLE services ADD COLUMN IF NOT EXISTS is_available boolean NOT NULL;
ALTER TABLE services ADD COLUMN IF NOT EXISTS is_featured boolean NOT NULL;
ALTER TABLE services ADD COLUMN IF NOT EXISTS tags text[] NOT NULL;
ALTER TABLE services ADD COLUMN IF NOT EXISTS created_at timestamp with time zone NOT NULL;
ALTER TABLE services ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone NOT NULL;



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

-- Alter table statements to add missing columns:
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS user_id text NOT NULL;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS service_id text NOT NULL;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS service_type text NOT NULL;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS service_name text NOT NULL;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS booking_date_time timestamp with time zone NOT NULL;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS duration numeric NOT NULL;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS guest_count integer NOT NULL;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS special_requests text NOT NULL;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS status text NOT NULL;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS total_price numeric NOT NULL;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS service_options jsonb NOT NULL;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS created_at timestamp with time zone NOT NULL;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone NOT NULL;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS contact_name text NOT NULL;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS contact_email text NOT NULL;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS contact_phone text NOT NULL;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS event_id text;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS event_name text;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS payment_id text;
ALTER TABLE bookings ADD COLUMN IF NOT EXISTS payment_status text;



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

-- Alter table statements to add missing columns:
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS user_id text NOT NULL;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS title text NOT NULL;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS body text NOT NULL;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS type text NOT NULL;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS data jsonb;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS read boolean NOT NULL;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS created_at timestamp with time zone NOT NULL;
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS related_entity_id text;



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

-- Alter table statements to add missing columns:
ALTER TABLE events ADD COLUMN IF NOT EXISTS name text NOT NULL;
ALTER TABLE events ADD COLUMN IF NOT EXISTS type text NOT NULL;
ALTER TABLE events ADD COLUMN IF NOT EXISTS date timestamp with time zone NOT NULL;
ALTER TABLE events ADD COLUMN IF NOT EXISTS location text NOT NULL;
ALTER TABLE events ADD COLUMN IF NOT EXISTS budget numeric NOT NULL;
ALTER TABLE events ADD COLUMN IF NOT EXISTS guest_count integer NOT NULL;
ALTER TABLE events ADD COLUMN IF NOT EXISTS description text;
ALTER TABLE events ADD COLUMN IF NOT EXISTS user_id text;
ALTER TABLE events ADD COLUMN IF NOT EXISTS created_at timestamp with time zone;
ALTER TABLE events ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone;
ALTER TABLE events ADD COLUMN IF NOT EXISTS status text;
ALTER TABLE events ADD COLUMN IF NOT EXISTS image_urls text[] NOT NULL;



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

-- Alter table statements to add missing columns:
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS title text NOT NULL;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS description text;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS due_date timestamp with time zone NOT NULL;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS status text NOT NULL;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS category_id text NOT NULL;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS assigned_to text;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS is_important boolean NOT NULL;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS notes text;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS completed_date timestamp with time zone;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS priority text NOT NULL;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS is_service_related boolean NOT NULL;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS service_id text;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS dependencies text[] NOT NULL;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS event_id text;
ALTER TABLE tasks ADD COLUMN IF NOT EXISTS service text;



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

-- Alter table statements to add missing columns:
ALTER TABLE task_categories ADD COLUMN IF NOT EXISTS name text NOT NULL;
ALTER TABLE task_categories ADD COLUMN IF NOT EXISTS description text NOT NULL;
ALTER TABLE task_categories ADD COLUMN IF NOT EXISTS icon text NOT NULL;
ALTER TABLE task_categories ADD COLUMN IF NOT EXISTS color text NOT NULL;
ALTER TABLE task_categories ADD COLUMN IF NOT EXISTS order integer NOT NULL;
ALTER TABLE task_categories ADD COLUMN IF NOT EXISTS is_default boolean NOT NULL;
ALTER TABLE task_categories ADD COLUMN IF NOT EXISTS is_active boolean NOT NULL;
ALTER TABLE task_categories ADD COLUMN IF NOT EXISTS created_at timestamp with time zone NOT NULL;
ALTER TABLE task_categories ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone NOT NULL;



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

-- Alter table statements to add missing columns:
ALTER TABLE task_dependencies ADD COLUMN IF NOT EXISTS prerequisite_task_id text NOT NULL;
ALTER TABLE task_dependencies ADD COLUMN IF NOT EXISTS dependent_task_id text NOT NULL;
ALTER TABLE task_dependencies ADD COLUMN IF NOT EXISTS type text NOT NULL;
ALTER TABLE task_dependencies ADD COLUMN IF NOT EXISTS offset_days integer NOT NULL;
ALTER TABLE task_dependencies ADD COLUMN IF NOT EXISTS created_at timestamp with time zone NOT NULL;
ALTER TABLE task_dependencies ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone NOT NULL;



-- SQL for table: guests
CREATE TABLE IF NOT EXISTS guests (
  id uuid PRIMARY KEY,
  name text NOT NULL,
  description text,
  color text,
  guests jsonb NOT NULL
);

-- Alter table statements to add missing columns:
ALTER TABLE guests ADD COLUMN IF NOT EXISTS name text NOT NULL;
ALTER TABLE guests ADD COLUMN IF NOT EXISTS description text;
ALTER TABLE guests ADD COLUMN IF NOT EXISTS color text;
ALTER TABLE guests ADD COLUMN IF NOT EXISTS guests jsonb NOT NULL;



-- SQL for table: budget_items
CREATE TABLE IF NOT EXISTS budget_items (
  id uuid PRIMARY KEY,
  name text NOT NULL,
  icon text NOT NULL
);

-- Alter table statements to add missing columns:
ALTER TABLE budget_items ADD COLUMN IF NOT EXISTS name text NOT NULL;
ALTER TABLE budget_items ADD COLUMN IF NOT EXISTS icon text NOT NULL;



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

-- Alter table statements to add missing columns:
ALTER TABLE wizard_states ADD COLUMN IF NOT EXISTS template text NOT NULL;
ALTER TABLE wizard_states ADD COLUMN IF NOT EXISTS current_step integer NOT NULL;
ALTER TABLE wizard_states ADD COLUMN IF NOT EXISTS total_steps integer NOT NULL;
ALTER TABLE wizard_states ADD COLUMN IF NOT EXISTS event_name text NOT NULL;
ALTER TABLE wizard_states ADD COLUMN IF NOT EXISTS selected_event_type text;
ALTER TABLE wizard_states ADD COLUMN IF NOT EXISTS event_date timestamp with time zone;
ALTER TABLE wizard_states ADD COLUMN IF NOT EXISTS guest_count integer;
ALTER TABLE wizard_states ADD COLUMN IF NOT EXISTS selected_services text NOT NULL;
ALTER TABLE wizard_states ADD COLUMN IF NOT EXISTS event_duration integer NOT NULL;
ALTER TABLE wizard_states ADD COLUMN IF NOT EXISTS daily_start_time text;
ALTER TABLE wizard_states ADD COLUMN IF NOT EXISTS daily_end_time text;
ALTER TABLE wizard_states ADD COLUMN IF NOT EXISTS needs_setup boolean NOT NULL;
ALTER TABLE wizard_states ADD COLUMN IF NOT EXISTS setup_hours integer NOT NULL;
ALTER TABLE wizard_states ADD COLUMN IF NOT EXISTS needs_teardown boolean NOT NULL;
ALTER TABLE wizard_states ADD COLUMN IF NOT EXISTS teardown_hours integer NOT NULL;
ALTER TABLE wizard_states ADD COLUMN IF NOT EXISTS is_completed boolean NOT NULL;
ALTER TABLE wizard_states ADD COLUMN IF NOT EXISTS last_updated timestamp with time zone NOT NULL;



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

-- Alter table statements to add missing columns:
ALTER TABLE wizard_connections ADD COLUMN IF NOT EXISTS user_id text NOT NULL;
ALTER TABLE wizard_connections ADD COLUMN IF NOT EXISTS event_id text NOT NULL;
ALTER TABLE wizard_connections ADD COLUMN IF NOT EXISTS wizard_state_id text NOT NULL;
ALTER TABLE wizard_connections ADD COLUMN IF NOT EXISTS budget_enabled boolean NOT NULL;
ALTER TABLE wizard_connections ADD COLUMN IF NOT EXISTS guest_list_enabled boolean NOT NULL;
ALTER TABLE wizard_connections ADD COLUMN IF NOT EXISTS timeline_enabled boolean NOT NULL;
ALTER TABLE wizard_connections ADD COLUMN IF NOT EXISTS service_recommendations_enabled boolean NOT NULL;
ALTER TABLE wizard_connections ADD COLUMN IF NOT EXISTS budget_item_ids text[] NOT NULL;
ALTER TABLE wizard_connections ADD COLUMN IF NOT EXISTS guest_group_ids text[] NOT NULL;
ALTER TABLE wizard_connections ADD COLUMN IF NOT EXISTS task_ids text[] NOT NULL;
ALTER TABLE wizard_connections ADD COLUMN IF NOT EXISTS service_recommendation_ids text[] NOT NULL;
ALTER TABLE wizard_connections ADD COLUMN IF NOT EXISTS created_at timestamp with time zone NOT NULL;
ALTER TABLE wizard_connections ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone NOT NULL;



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

-- Alter table statements to add missing columns:
ALTER TABLE service_reviews ADD COLUMN IF NOT EXISTS service_id text NOT NULL;
ALTER TABLE service_reviews ADD COLUMN IF NOT EXISTS user_id text NOT NULL;
ALTER TABLE service_reviews ADD COLUMN IF NOT EXISTS user_name text NOT NULL;
ALTER TABLE service_reviews ADD COLUMN IF NOT EXISTS rating numeric NOT NULL;
ALTER TABLE service_reviews ADD COLUMN IF NOT EXISTS comment text NOT NULL;
ALTER TABLE service_reviews ADD COLUMN IF NOT EXISTS image_urls text[] NOT NULL;
ALTER TABLE service_reviews ADD COLUMN IF NOT EXISTS is_verified boolean NOT NULL;
ALTER TABLE service_reviews ADD COLUMN IF NOT EXISTS created_at timestamp with time zone NOT NULL;
ALTER TABLE service_reviews ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone NOT NULL;



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

-- Alter table statements to add missing columns:
ALTER TABLE payments ADD COLUMN IF NOT EXISTS booking_id text NOT NULL;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS user_id text NOT NULL;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS amount numeric NOT NULL;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS currency text NOT NULL;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS status text NOT NULL;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS payment_intent_id text;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS payment_method_id text;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS created_at timestamp with time zone NOT NULL;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone;



