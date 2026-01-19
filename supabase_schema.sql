-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ═════════════════════════════════════════════════════════════════════════════
-- 1. PROFILES (Users)
-- ═════════════════════════════════════════════════════════════════════════════
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policies for Profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public profiles are viewable by everyone" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert their own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- ═════════════════════════════════════════════════════════════════════════════
-- 2. USER MODULES CONFIGURATION
-- ═════════════════════════════════════════════════════════════════════════════
CREATE TABLE user_modules (
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE PRIMARY KEY,
  family BOOLEAN DEFAULT TRUE,
  home BOOLEAN DEFAULT TRUE,
  car BOOLEAN DEFAULT FALSE,
  pets BOOLEAN DEFAULT TRUE,
  travel BOOLEAN DEFAULT TRUE,
  podcast BOOLEAN DEFAULT TRUE,
  budget BOOLEAN DEFAULT TRUE,
  fitness BOOLEAN DEFAULT TRUE,
  cycle_tracking BOOLEAN DEFAULT FALSE,
  pregnancy BOOLEAN DEFAULT FALSE,
  fashion BOOLEAN DEFAULT FALSE,
  tech BOOLEAN DEFAULT FALSE, -- Kept for backward compatibility or if re-added
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE user_modules ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own modules" ON user_modules FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own modules" ON user_modules FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own modules" ON user_modules FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ═════════════════════════════════════════════════════════════════════════════
-- 3. BUDGET MODULE
-- ═════════════════════════════════════════════════════════════════════════════
CREATE TABLE budget_transactions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  category TEXT NOT NULL, -- Stored as string key (e.g., 'food', 'bills')
  is_expense BOOLEAN DEFAULT TRUE,
  transaction_date TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE budget_transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users view own transactions" ON budget_transactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users insert own transactions" ON budget_transactions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users update own transactions" ON budget_transactions FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users delete own transactions" ON budget_transactions FOR DELETE USING (auth.uid() = user_id);

-- ═════════════════════════════════════════════════════════════════════════════
-- 4. FAMILY MODULE
-- ═════════════════════════════════════════════════════════════════════════════
CREATE TABLE family_members (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL, -- The owner of the family group
  name TEXT NOT NULL,
  role TEXT DEFAULT 'member', -- 'admin', 'child', 'parent'
  avatar_color_hex TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE family_tasks (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  family_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL, -- Linked to the main user for now
  assigned_to_id UUID REFERENCES family_members(id),
  title TEXT NOT NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  due_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE family_tasks ENABLE ROW LEVEL SECURITY;
-- Simplified RLS: Users can manage everything linked to their user_id
CREATE POLICY "Manage family members" ON family_members FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Manage family tasks" ON family_tasks FOR ALL USING (auth.uid() = family_id);

-- ═════════════════════════════════════════════════════════════════════════════
-- 5. NOTIFICATIONS (Daily Feed)
-- ═════════════════════════════════════════════════════════════════════════════
CREATE TABLE notifications (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  module_name TEXT NOT NULL,
  title TEXT NOT NULL,
  subtitle TEXT,
  icon_name TEXT,
  accent_color_hex TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  scheduled_for TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Manage notifications" ON notifications FOR ALL USING (auth.uid() = user_id);

-- ═════════════════════════════════════════════════════════════════════════════
-- 6. TRIGGERS
-- ═════════════════════════════════════════════════════════════════════════════
-- Auto-create user_modules on profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, avatar_url)
  VALUES (new.id, new.email, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  
  INSERT INTO public.user_modules (user_id)
  VALUES (new.id);
  
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
