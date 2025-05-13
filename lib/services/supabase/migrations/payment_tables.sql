-- Create payments table
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID REFERENCES bookings(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  amount DECIMAL NOT NULL,
  currency TEXT NOT NULL,
  status TEXT NOT NULL,
  payment_intent_id TEXT,
  payment_method_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Set up RLS policies
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- Users can only view their own payments
CREATE POLICY "Users can view their own payments" ON payments
  FOR SELECT USING (auth.uid() = user_id);

-- Only authenticated users can insert payments
CREATE POLICY "Authenticated users can insert payments" ON payments
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Users can only update their own payments
CREATE POLICY "Users can update their own payments" ON payments
  FOR UPDATE USING (auth.uid() = user_id);

-- Add payment fields to bookings table if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'bookings' AND column_name = 'payment_id') THEN
    ALTER TABLE bookings ADD COLUMN payment_id UUID REFERENCES payments(id) ON DELETE SET NULL;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'bookings' AND column_name = 'payment_status') THEN
    ALTER TABLE bookings ADD COLUMN payment_status TEXT;
  END IF;
END
$$;
