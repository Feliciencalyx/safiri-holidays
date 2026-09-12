-- ============================================================================
-- SAFIRI HOLIDAYS PRODUCTION DATABASE SCHEMA (Supabase PostgreSQL DDL)
-- Version: 2.0.0
-- Generated: 2026-08-27
-- Description: Complete schema for Users, Traveler Profiles, Bookings,
--              Flights, Payments, Visas, Tours, Hotels, Notifications, RLS.
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. USERS & PROFILES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    username TEXT UNIQUE,
    full_name TEXT NOT NULL,
    phone TEXT,
    role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'admin', 'concierge')),
    tier TEXT NOT NULL DEFAULT 'Premium Explorer' CHECK (tier IN ('Standard', 'Premium Explorer', 'VIP Concierge')),
    avatar_url TEXT DEFAULT 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    status TEXT NOT NULL DEFAULT 'Active' CHECK (status IN ('Active', 'Suspended', 'Pending')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indices for fast user search and strict uniqueness enforcement
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_username_unique ON public.profiles(username) WHERE username IS NOT NULL AND username != '';
CREATE UNIQUE INDEX IF NOT EXISTS idx_profiles_phone_unique ON public.profiles(phone) WHERE phone IS NOT NULL AND phone != '';
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);

-- ============================================================================
-- 1.1 VERIFICATION CODES (EMAIL & SMS OTP CONFIRMATIONS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.verification_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    identifier TEXT NOT NULL,
    code TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('signup', 'password_reset')),
    expires_at TIMESTAMPTZ NOT NULL,
    is_used BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_verification_identifier ON public.verification_codes(identifier);
CREATE INDEX IF NOT EXISTS idx_verification_type ON public.verification_codes(type);

-- ============================================================================
-- 2. TRAVELER PROFILES (PASSPORT & ICAO VERIFICATION)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.traveler_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    passport_number TEXT NOT NULL,
    passport_country TEXT NOT NULL DEFAULT 'Rwanda',
    is_passport_verified BOOLEAN NOT NULL DEFAULT false,
    verification_badge_text TEXT,
    date_of_birth DATE,
    nationality TEXT DEFAULT 'Rwandan',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_user_passport UNIQUE (user_id, passport_number)
);

CREATE INDEX IF NOT EXISTS idx_traveler_user ON public.traveler_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_traveler_passport ON public.traveler_profiles(passport_number);

-- ============================================================================
-- 3. MASTER BOOKING SEQUENCE & REFERENCE GENERATOR
-- ============================================================================
CREATE SEQUENCE IF NOT EXISTS public.booking_ref_seq START WITH 100000;

CREATE OR REPLACE FUNCTION public.generate_booking_reference()
RETURNS TEXT AS $$
BEGIN
    RETURN 'SAF-' || EXTRACT(YEAR FROM CURRENT_DATE)::TEXT || '-' || LPAD(NEXTVAL('public.booking_ref_seq')::TEXT, 6, '0');
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 4. MASTER BOOKINGS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_reference TEXT UNIQUE NOT NULL DEFAULT public.generate_booking_reference(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    service_type TEXT NOT NULL CHECK (service_type IN ('Flight', 'Hotel', 'Safari', 'Tour', 'Car', 'Visa')),
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PAID', 'CONFIRMED', 'CANCELLED', 'DISPATCHED')),
    total_amount_usd NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    total_amount_rwf NUMERIC(12, 0) NOT NULL DEFAULT 0,
    currency TEXT NOT NULL DEFAULT 'RWF',
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_bookings_user ON public.bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_ref ON public.bookings(booking_reference);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON public.bookings(status);

-- ============================================================================
-- 5. FLIGHT BOOKINGS (DUFFEL INTEGRATION)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.flight_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    duffel_offer_id TEXT,
    duffel_order_id TEXT,
    airline TEXT NOT NULL,
    airline_code TEXT NOT NULL DEFAULT 'WB',
    flight_number TEXT NOT NULL,
    origin_code VARCHAR(3) NOT NULL,
    origin_name TEXT NOT NULL,
    destination_code VARCHAR(3) NOT NULL,
    destination_name TEXT NOT NULL,
    departure_time TIMESTAMPTZ NOT NULL,
    arrival_time TIMESTAMPTZ NOT NULL,
    cabin_class TEXT NOT NULL DEFAULT 'Economy',
    fare_tier TEXT NOT NULL DEFAULT 'SAVER',
    passenger_name TEXT NOT NULL,
    passenger_passport TEXT NOT NULL,
    ticket_pdf_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_flight_booking_id ON public.flight_bookings(booking_id);
CREATE INDEX IF NOT EXISTS idx_flight_duffel_order ON public.flight_bookings(duffel_order_id);

-- ============================================================================
-- 6. PAYMENTS TABLE (MTN MOMO / AIRTEL / CARD WEBHOOKS)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    transaction_reference TEXT UNIQUE NOT NULL,
    provider TEXT NOT NULL CHECK (provider IN ('MTN_MOMO', 'AIRTEL_MONEY', 'VISA', 'MASTERCARD', 'PAYPAL')),
    amount NUMERIC(12, 2) NOT NULL,
    currency TEXT NOT NULL DEFAULT 'RWF',
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'SUCCESSFUL', 'FAILED', 'REFUNDED')),
    provider_response JSONB,
    paid_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payments_booking ON public.payments(booking_id);
CREATE INDEX IF NOT EXISTS idx_payments_ref ON public.payments(transaction_reference);

-- ============================================================================
-- 7. VISA APPLICATIONS
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.visa_applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID REFERENCES public.bookings(id) ON DELETE SET NULL,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    destination_country TEXT NOT NULL,
    visa_type TEXT NOT NULL DEFAULT 'Tourist Visa',
    passport_copy_url TEXT NOT NULL,
    photo_url TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'UNDER_REVIEW', 'APPROVED', 'REJECTED')),
    concierge_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_visa_user ON public.visa_applications(user_id);

-- ============================================================================
-- 8. TOURS & SAFARIS
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.tours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    destination TEXT NOT NULL,
    duration_days INT NOT NULL DEFAULT 1,
    price_usd NUMERIC(10, 2) NOT NULL,
    image_url TEXT,
    is_featured BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.tour_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    tour_id UUID REFERENCES public.tours(id) ON DELETE SET NULL,
    tour_name TEXT NOT NULL,
    travel_date DATE NOT NULL,
    guests_count INT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 9. HOTEL BOOKINGS
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.hotel_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    hotel_name TEXT NOT NULL,
    destination TEXT NOT NULL,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    rooms_count INT NOT NULL DEFAULT 1,
    guests_count INT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 10. CAR BOOKINGS
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.car_bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    booking_id UUID NOT NULL REFERENCES public.bookings(id) ON DELETE CASCADE,
    vehicle_type TEXT NOT NULL,
    pickup_location TEXT NOT NULL,
    dropoff_location TEXT NOT NULL,
    pickup_time TIMESTAMPTZ NOT NULL,
    return_time TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 11. NOTIFICATIONS & SUPPORT MESSAGES
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.support_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    enquiry_reference TEXT,
    subject TEXT NOT NULL,
    message TEXT NOT NULL,
    priority TEXT NOT NULL DEFAULT 'NORMAL' CHECK (priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT')),
    status TEXT NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 12. AUTOMATIC USER PROFILE CREATION TRIGGER (ON auth.users SIGNUP)
-- ============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user_signup()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, username, full_name, phone, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'username', SPLIT_PART(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', SPLIT_PART(NEW.email, '@', 1)),
        NEW.raw_user_meta_data->>'phone',
        COALESCE(NEW.raw_user_meta_data->>'role', 'customer')
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        username = COALESCE(public.profiles.username, EXCLUDED.username),
        full_name = COALESCE(EXCLUDED.full_name, public.profiles.full_name),
        phone = COALESCE(EXCLUDED.phone, public.profiles.phone);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Bind trigger to Supabase auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_signup();

-- ============================================================================
-- 13. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.traveler_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.flight_bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.visa_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_messages ENABLE ROW LEVEL SECURITY;

-- Helper function to check if current user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Profiles RLS
CREATE POLICY "Users can view their own profile" ON public.profiles FOR SELECT USING (auth.uid() = id OR public.is_admin());
CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id OR public.is_admin());

-- Traveler Profiles RLS
CREATE POLICY "Users can view their own traveler profile" ON public.traveler_profiles FOR SELECT USING (user_id = auth.uid() OR public.is_admin());
CREATE POLICY "Users can insert their traveler profile" ON public.traveler_profiles FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users can update their traveler profile" ON public.traveler_profiles FOR UPDATE USING (user_id = auth.uid() OR public.is_admin());

-- Bookings RLS
CREATE POLICY "Users can view their own bookings" ON public.bookings FOR SELECT USING (user_id = auth.uid() OR public.is_admin());
CREATE POLICY "Users can create bookings" ON public.bookings FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Admins can update bookings" ON public.bookings FOR UPDATE USING (public.is_admin());

-- Flight Bookings RLS
CREATE POLICY "Users can view their flight bookings" ON public.flight_bookings FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.bookings b WHERE b.id = booking_id AND (b.user_id = auth.uid() OR public.is_admin()))
);

-- Payments RLS
CREATE POLICY "Users can view their payments" ON public.payments FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.bookings b WHERE b.id = booking_id AND (b.user_id = auth.uid() OR public.is_admin()))
);

-- Notifications RLS
CREATE POLICY "Users can view their notifications" ON public.notifications FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can update their notifications" ON public.notifications FOR UPDATE USING (user_id = auth.uid());

-- ============================================================================
-- END OF SCHEMA DDL SCRIPT
-- ============================================================================
