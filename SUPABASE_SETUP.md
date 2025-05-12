# Supabase Setup Guide for Eventati Book

This guide will help you set up Supabase for the Eventati Book application.

## 1. Create a Supabase Project

1. Go to [Supabase](https://supabase.com/) and sign up or log in
2. Create a new project
3. Choose a name for your project (e.g., "eventati-book")
4. Set a secure database password
5. Choose a region close to your users
6. Wait for your project to be created

## 2. Get Your Supabase Credentials

1. Go to your project dashboard
2. Navigate to Project Settings > API
3. Copy the following credentials:
   - **URL**: Your Supabase project URL
   - **anon key**: Your public API key
   - **service_role key**: Your private API key (keep this secure!)
   - **Project ID**: Your Supabase project ID

## 3. Update Configuration in the App

1. Open `lib/config/supabase_options.dart`
2. Replace the placeholder values with your actual Supabase credentials:

```dart
/// Supabase configuration options
class SupabaseOptions {
  /// Supabase URL
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';

  /// Supabase anonymous key
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// Supabase service role key (for admin operations)
  static const String supabaseServiceRoleKey = 'YOUR_SUPABASE_SERVICE_ROLE_KEY';

  /// Supabase project ID
  static const String supabaseProjectId = 'YOUR_SUPABASE_PROJECT_ID';

  /// Supabase storage bucket name
  static const String supabaseStorageBucket = 'eventati-book';

  /// Supabase storage URL
  static String get supabaseStorageUrl =>
      '$supabaseUrl/storage/v1/object/$supabaseStorageBucket';
}
```

## 4. Set Up Supabase Database Schema

Create the following tables in your Supabase database:

### Users Table

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  name TEXT,
  email TEXT,
  profile_image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  favorite_venues JSONB DEFAULT '[]'::JSONB,
  favorite_services JSONB DEFAULT '[]'::JSONB,
  has_premium_subscription BOOLEAN DEFAULT FALSE
);
```

### Events Table

```sql
CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  event_type TEXT NOT NULL,
  date TIMESTAMP WITH TIME ZONE,
  location TEXT,
  guest_count INTEGER,
  budget DECIMAL(10, 2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Budget Items Table

```sql
CREATE TABLE budget_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  category TEXT,
  estimated_cost DECIMAL(10, 2),
  actual_cost DECIMAL(10, 2),
  paid BOOLEAN DEFAULT FALSE,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Guests Table

```sql
CREATE TABLE guests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  rsvp_status TEXT,
  plus_ones INTEGER DEFAULT 0,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Tasks Table

```sql
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  due_date TIMESTAMP WITH TIME ZONE,
  completed BOOLEAN DEFAULT FALSE,
  priority TEXT,
  category TEXT,
  assigned_to TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Bookings Table

```sql
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  service_id TEXT NOT NULL,
  service_type TEXT NOT NULL,
  booking_date TIMESTAMP WITH TIME ZONE,
  status TEXT,
  payment_status TEXT,
  total_amount DECIMAL(10, 2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Analytics Events Table

```sql
CREATE TABLE analytics_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_name TEXT NOT NULL,
  event_params JSONB,
  user_id UUID,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  session_id TEXT
);
```

### Notification Topics Table

```sql
CREATE TABLE notification_topics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  topic TEXT NOT NULL,
  subscribed BOOLEAN DEFAULT TRUE,
  subscribed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  unsubscribed_at TIMESTAMP WITH TIME ZONE
);
```

### Notification Topic Definitions Table

```sql
CREATE TABLE notification_topic_definitions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  topic TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  description TEXT,
  category TEXT
);
```

### Notification Channels Table

```sql
CREATE TABLE notification_channels (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  channel_id TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  description TEXT,
  importance TEXT
);
```

### User Notification Settings Table

```sql
CREATE TABLE user_notification_settings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  push_enabled BOOLEAN DEFAULT TRUE,
  email_enabled BOOLEAN DEFAULT TRUE,
  event_reminders BOOLEAN DEFAULT TRUE,
  task_reminders BOOLEAN DEFAULT TRUE,
  booking_updates BOOLEAN DEFAULT TRUE,
  marketing_notifications BOOLEAN DEFAULT FALSE,
  quiet_hours_start TIME,
  quiet_hours_end TIME,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Notifications Table

```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB,
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 5. Set Up Supabase Storage Buckets

1. Go to Storage in your Supabase dashboard
2. Create a new bucket named "eventati-book"
3. Set the bucket's privacy to "Public"
4. Create the following folders in the bucket:
   - `profile_images`
   - `event_images`
   - `venue_images`
   - `service_images`

## 6. Set Up Supabase Auth

1. Go to Authentication > Settings in your Supabase dashboard
2. Enable the following providers:
   - Email (with "Confirm email" enabled)
   - Google
   - Apple
3. Configure redirect URLs for your app:
   - Add `io.supabase.eventati://login-callback/` for login
   - Add `io.supabase.eventati://reset-callback/` for password reset

## 7. Set Up PostHog for Analytics and Error Tracking

1. Go to [PostHog](https://posthog.com/) and sign up or log in
2. Create a new project
3. Get your API key
4. Open `lib/config/posthog_options.dart` and update the API key:

```dart
/// PostHog configuration options for analytics and error tracking
class PostHogOptions {
  /// PostHog API key
  static const String apiKey = 'YOUR_POSTHOG_API_KEY';

  /// PostHog API host
  static const String apiHost = 'https://us.i.posthog.com';

  /// Whether to enable debug mode
  static const bool debug = true;

  /// Whether to capture application lifecycle events automatically
  static const bool captureAppLifecycleEvents = true;

  /// Whether to capture deep links automatically
  static const bool captureDeepLinks = true;

  /// Whether to record screen views automatically
  static const bool recordScreenViews = true;

  /// Whether to use the PostHog session replay feature
  static const bool sessionReplay = false;
}
```

## 8. Run the App

After completing the setup, run the app to verify that everything is working correctly.


