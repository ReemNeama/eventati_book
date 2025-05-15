-- SQL to add Row Level Security (RLS) policies to Supabase tables
-- Generated on 2025-05-15

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

-- Guests table policies
-- Users can read their own guests
CREATE POLICY "Users can read own guests" ON guests
  FOR SELECT USING (id IN (
    SELECT guest_group_ids FROM wizard_connections WHERE user_id = auth.get_auth_user_id()
  ));

-- Users can create their own guests
CREATE POLICY "Users can create own guests" ON guests
  FOR INSERT WITH CHECK (true); -- Will be restricted at the application level

-- Users can update their own guests
CREATE POLICY "Users can update own guests" ON guests
  FOR UPDATE USING (id IN (
    SELECT guest_group_ids FROM wizard_connections WHERE user_id = auth.get_auth_user_id()
  ));

-- Budget Items table policies
-- Users can read their own budget items
CREATE POLICY "Users can read own budget items" ON budget_items
  FOR SELECT USING (id IN (
    SELECT budget_item_ids FROM wizard_connections WHERE user_id = auth.get_auth_user_id()
  ));

-- Users can create their own budget items
CREATE POLICY "Users can create own budget items" ON budget_items
  FOR INSERT WITH CHECK (true); -- Will be restricted at the application level

-- Users can update their own budget items
CREATE POLICY "Users can update own budget items" ON budget_items
  FOR UPDATE USING (id IN (
    SELECT budget_item_ids FROM wizard_connections WHERE user_id = auth.get_auth_user_id()
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
