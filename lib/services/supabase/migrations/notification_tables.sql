-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type INTEGER NOT NULL,
  data JSONB,
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  related_entity_id TEXT
);

-- Create user notification settings table
CREATE TABLE IF NOT EXISTS user_notification_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  all_notifications_enabled BOOLEAN DEFAULT TRUE,
  topic_settings JSONB DEFAULT '{}',
  push_notifications_enabled BOOLEAN DEFAULT TRUE,
  email_notifications_enabled BOOLEAN DEFAULT TRUE,
  in_app_notifications_enabled BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create email logs table
CREATE TABLE IF NOT EXISTS email_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  recipient TEXT NOT NULL,
  subject TEXT NOT NULL,
  status TEXT NOT NULL,
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  error_message TEXT
);

-- Set up RLS policies for notifications
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Users can only view their own notifications
CREATE POLICY "Users can view their own notifications" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

-- Only authenticated users can insert notifications
CREATE POLICY "Authenticated users can insert notifications" ON notifications
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Users can only update their own notifications
CREATE POLICY "Users can update their own notifications" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- Users can only delete their own notifications
CREATE POLICY "Users can delete their own notifications" ON notifications
  FOR DELETE USING (auth.uid() = user_id);

-- Set up RLS policies for user notification settings
ALTER TABLE user_notification_settings ENABLE ROW LEVEL SECURITY;

-- Users can only view their own notification settings
CREATE POLICY "Users can view their own notification settings" ON user_notification_settings
  FOR SELECT USING (auth.uid() = user_id);

-- Only authenticated users can insert notification settings
CREATE POLICY "Authenticated users can insert notification settings" ON user_notification_settings
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Users can only update their own notification settings
CREATE POLICY "Users can update their own notification settings" ON user_notification_settings
  FOR UPDATE USING (auth.uid() = user_id);

-- Set up RLS policies for email logs
ALTER TABLE email_logs ENABLE ROW LEVEL SECURITY;

-- Users can only view their own email logs
CREATE POLICY "Users can view their own email logs" ON email_logs
  FOR SELECT USING (auth.uid() = user_id);

-- Only authenticated users can insert email logs
CREATE POLICY "Authenticated users can insert email logs" ON email_logs
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS notifications_user_id_idx ON notifications(user_id);
CREATE INDEX IF NOT EXISTS notifications_read_idx ON notifications(read);
CREATE INDEX IF NOT EXISTS notifications_created_at_idx ON notifications(created_at);
CREATE INDEX IF NOT EXISTS notifications_related_entity_id_idx ON notifications(related_entity_id);
CREATE INDEX IF NOT EXISTS user_notification_settings_user_id_idx ON user_notification_settings(user_id);
CREATE INDEX IF NOT EXISTS email_logs_user_id_idx ON email_logs(user_id);
CREATE INDEX IF NOT EXISTS email_logs_sent_at_idx ON email_logs(sent_at);
