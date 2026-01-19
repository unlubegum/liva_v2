-- ═══════════════════════════════════════════════════════════════════════════════════
-- LIVA V2 - SUPABASE DATABASE SETUP (FIXED ORDER)
-- Run this entire script in the Supabase SQL Editor
-- ═══════════════════════════════════════════════════════════════════════════════════

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ═══════════════════════════════════════════════════════════════════════════════════
-- 2. ENUMS
-- ═══════════════════════════════════════════════════════════════════════════════════
CREATE TYPE pet_type AS ENUM ('dog', 'cat', 'bird', 'fish', 'hamster', 'rabbit', 'other');
CREATE TYPE bill_status AS ENUM ('pending', 'paid', 'overdue');
CREATE TYPE transaction_category AS ENUM ('food', 'transport', 'bills', 'entertainment', 'shopping', 'health', 'income', 'other');
CREATE TYPE family_role AS ENUM ('admin', 'parent', 'child', 'member');

-- ═══════════════════════════════════════════════════════════════════════════════════
-- 3. UPDATED_AT TRIGGER FUNCTION
-- ═══════════════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ═══════════════════════════════════════════════════════════════════════════════════
-- 4. TABLES (Created BEFORE the helper function)
-- ═══════════════════════════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────────────────────────────
-- FAMILIES (The core grouping unit)
-- ─────────────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.families (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL DEFAULT 'Ailem',
  invite_code TEXT UNIQUE DEFAULT SUBSTR(MD5(RANDOM()::TEXT), 1, 6),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────────────────────────
-- PROFILES (Users)
-- ─────────────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  family_id UUID REFERENCES public.families(id) ON DELETE SET NULL,
  email TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  role family_role DEFAULT 'member',
  module_family BOOLEAN DEFAULT TRUE,
  module_home BOOLEAN DEFAULT TRUE,
  module_car BOOLEAN DEFAULT FALSE,
  module_pets BOOLEAN DEFAULT TRUE,
  module_travel BOOLEAN DEFAULT TRUE,
  module_podcast BOOLEAN DEFAULT TRUE,
  module_budget BOOLEAN DEFAULT TRUE,
  module_fitness BOOLEAN DEFAULT TRUE,
  module_cycle BOOLEAN DEFAULT FALSE,
  module_pregnancy BOOLEAN DEFAULT FALSE,
  module_fashion BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────────────────────────
-- FAMILY TASKS
-- ─────────────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.family_tasks (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  family_id UUID REFERENCES public.families(id) ON DELETE CASCADE NOT NULL,
  assigned_to_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  is_completed BOOLEAN DEFAULT FALSE,
  due_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────────────────────────
-- SHOPPING ITEMS
-- ─────────────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.shopping_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  family_id UUID REFERENCES public.families(id) ON DELETE CASCADE NOT NULL,
  added_by_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  quantity INTEGER DEFAULT 1,
  is_purchased BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────────────────────────
-- HOME BILLS
-- ─────────────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.home_bills (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  family_id UUID REFERENCES public.families(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  amount DECIMAL(12, 2) NOT NULL,
  due_date DATE NOT NULL,
  status bill_status DEFAULT 'pending',
  is_recurring BOOLEAN DEFAULT FALSE,
  recurrence_months INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────────────────────────
-- HOME ASSETS
-- ─────────────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.home_assets (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  family_id UUID REFERENCES public.families(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  brand TEXT,
  model TEXT,
  purchase_date DATE,
  warranty_end_date DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────────────────────────
-- PETS
-- ─────────────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.pets (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  family_id UUID REFERENCES public.families(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  type pet_type DEFAULT 'dog',
  breed TEXT,
  birth_date DATE,
  weight_kg DECIMAL(5, 2),
  avatar_url TEXT,
  allergies TEXT[],
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────────────────────────
-- PET VACCINES
-- ─────────────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.pet_vaccines (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  pet_id UUID REFERENCES public.pets(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  administered_date DATE NOT NULL,
  next_due_date DATE,
  vet_name TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────────────────────────
-- TRIPS
-- ─────────────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.trips (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  family_id UUID REFERENCES public.families(id) ON DELETE CASCADE NOT NULL,
  destination TEXT NOT NULL,
  emoji TEXT DEFAULT '✈️',
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  accent_color_hex TEXT DEFAULT '#80DEEA',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────────────────────────
-- PACKING ITEMS
-- ─────────────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.packing_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  trip_id UUID REFERENCES public.trips(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  category TEXT DEFAULT 'other',
  is_packed BOOLEAN DEFAULT FALSE,
  is_ai_generated BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─────────────────────────────────────────────────────────────────────────────────────
-- TRANSACTIONS (Budget)
-- ─────────────────────────────────────────────────────────────────────────────────────
CREATE TABLE public.transactions (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  family_id UUID REFERENCES public.families(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  amount DECIMAL(12, 2) NOT NULL,
  category transaction_category DEFAULT 'other',
  is_expense BOOLEAN DEFAULT TRUE,
  transaction_date DATE DEFAULT CURRENT_DATE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════════════════════════════════
-- 5. HELPER FUNCTION (Created AFTER profiles table exists)
-- ═══════════════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.get_user_family_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT family_id FROM public.profiles WHERE id = auth.uid()
$$;

-- ═══════════════════════════════════════════════════════════════════════════════════
-- 6. UPDATED_AT TRIGGERS
-- ═══════════════════════════════════════════════════════════════════════════════════
CREATE TRIGGER handle_updated_at_families BEFORE UPDATE ON public.families FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_updated_at_profiles BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_updated_at_family_tasks BEFORE UPDATE ON public.family_tasks FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_updated_at_shopping_items BEFORE UPDATE ON public.shopping_items FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_updated_at_home_bills BEFORE UPDATE ON public.home_bills FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_updated_at_home_assets BEFORE UPDATE ON public.home_assets FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_updated_at_pets BEFORE UPDATE ON public.pets FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_updated_at_pet_vaccines BEFORE UPDATE ON public.pet_vaccines FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_updated_at_trips BEFORE UPDATE ON public.trips FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_updated_at_packing_items BEFORE UPDATE ON public.packing_items FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();
CREATE TRIGGER handle_updated_at_transactions BEFORE UPDATE ON public.transactions FOR EACH ROW EXECUTE PROCEDURE public.handle_updated_at();

-- ═══════════════════════════════════════════════════════════════════════════════════
-- 7. NEW USER SIGNUP TRIGGER
-- ═══════════════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  new_family_id UUID;
BEGIN
  INSERT INTO public.families (name)
  VALUES (COALESCE(NEW.raw_user_meta_data->>'full_name', 'Ailem') || ' Ailesi')
  RETURNING id INTO new_family_id;

  INSERT INTO public.profiles (id, email, full_name, avatar_url, family_id, role)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'full_name',
    NEW.raw_user_meta_data->>'avatar_url',
    new_family_id,
    'admin'
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ═══════════════════════════════════════════════════════════════════════════════════
-- 8. ROW LEVEL SECURITY (RLS)
-- ═══════════════════════════════════════════════════════════════════════════════════

ALTER TABLE public.families ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shopping_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.home_bills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.home_assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pet_vaccines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trips ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.packing_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- PROFILES
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can view family members" ON public.profiles FOR SELECT USING (family_id = public.get_user_family_id());

-- FAMILIES
CREATE POLICY "Users can view own family" ON public.families FOR SELECT USING (id = public.get_user_family_id());
CREATE POLICY "Users can update own family" ON public.families FOR UPDATE USING (id = public.get_user_family_id());

-- FAMILY-SCOPED TABLES
CREATE POLICY "Family tasks access" ON public.family_tasks FOR ALL USING (family_id = public.get_user_family_id()) WITH CHECK (family_id = public.get_user_family_id());
CREATE POLICY "Shopping items access" ON public.shopping_items FOR ALL USING (family_id = public.get_user_family_id()) WITH CHECK (family_id = public.get_user_family_id());
CREATE POLICY "Home bills access" ON public.home_bills FOR ALL USING (family_id = public.get_user_family_id()) WITH CHECK (family_id = public.get_user_family_id());
CREATE POLICY "Home assets access" ON public.home_assets FOR ALL USING (family_id = public.get_user_family_id()) WITH CHECK (family_id = public.get_user_family_id());
CREATE POLICY "Pets access" ON public.pets FOR ALL USING (family_id = public.get_user_family_id()) WITH CHECK (family_id = public.get_user_family_id());
CREATE POLICY "Pet vaccines access" ON public.pet_vaccines FOR ALL USING (pet_id IN (SELECT id FROM public.pets WHERE family_id = public.get_user_family_id())) WITH CHECK (pet_id IN (SELECT id FROM public.pets WHERE family_id = public.get_user_family_id()));
CREATE POLICY "Trips access" ON public.trips FOR ALL USING (family_id = public.get_user_family_id()) WITH CHECK (family_id = public.get_user_family_id());
CREATE POLICY "Packing items access" ON public.packing_items FOR ALL USING (trip_id IN (SELECT id FROM public.trips WHERE family_id = public.get_user_family_id())) WITH CHECK (trip_id IN (SELECT id FROM public.trips WHERE family_id = public.get_user_family_id()));
CREATE POLICY "Transactions access" ON public.transactions FOR ALL USING (family_id = public.get_user_family_id()) WITH CHECK (family_id = public.get_user_family_id());

-- ═══════════════════════════════════════════════════════════════════════════════════
-- 9. INDEXES
-- ═══════════════════════════════════════════════════════════════════════════════════
CREATE INDEX idx_profiles_family_id ON public.profiles(family_id);
CREATE INDEX idx_family_tasks_family_id ON public.family_tasks(family_id);
CREATE INDEX idx_shopping_items_family_id ON public.shopping_items(family_id);
CREATE INDEX idx_home_bills_family_id ON public.home_bills(family_id);
CREATE INDEX idx_home_assets_family_id ON public.home_assets(family_id);
CREATE INDEX idx_pets_family_id ON public.pets(family_id);
CREATE INDEX idx_pet_vaccines_pet_id ON public.pet_vaccines(pet_id);
CREATE INDEX idx_trips_family_id ON public.trips(family_id);
CREATE INDEX idx_packing_items_trip_id ON public.packing_items(trip_id);
CREATE INDEX idx_transactions_family_id ON public.transactions(family_id);
CREATE INDEX idx_transactions_date ON public.transactions(transaction_date);

-- ═══════════════════════════════════════════════════════════════════════════════════
-- DONE! ✅
-- ═══════════════════════════════════════════════════════════════════════════════════
