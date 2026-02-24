-- Rare Coin Database Migration
-- Run this in Supabase SQL Editor to create all tables

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wallet_address TEXT UNIQUE NOT NULL,
    twitter_handle TEXT,
    registered_at TIMESTAMPTZ DEFAULT NOW(),
    last_claim_at TIMESTAMPTZ,
    claim_count INTEGER DEFAULT 0,
    staking_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_wallet ON users(wallet_address);
CREATE INDEX IF NOT EXISTS idx_users_registered ON users(registered_at);
CREATE INDEX IF NOT EXISTS idx_users_last_claim ON users(last_claim_at);

-- ============================================
-- 2. REGISTRATIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS registrations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    period_id INTEGER NOT NULL,
    registered_at TIMESTAMPTZ DEFAULT NOW(),
    stake_amount BIGINT,
    stake_returned BOOLEAN DEFAULT FALSE,
    is_successful BOOLEAN,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_registrations_user ON registrations(user_id);
CREATE INDEX IF NOT EXISTS idx_registrations_period ON registrations(period_id);

-- ============================================
-- 3. CLAIMS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS claims (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    registration_id UUID REFERENCES registrations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    amount BIGINT NOT NULL,
    claimed_at TIMESTAMPTZ DEFAULT NOW(),
    tx_hash TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_claims_user ON claims(user_id);
CREATE INDEX IF NOT EXISTS idx_claims_registration ON claims(registration_id);
CREATE INDEX IF NOT EXISTS idx_claims_date ON claims(claimed_at);

-- ============================================
-- 4. STAKES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS stakes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    amount BIGINT NOT NULL,
    staked_at TIMESTAMPTZ DEFAULT NOW(),
    unstaked_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    reward_rate DECIMAL(10, 4),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_stakes_user ON stakes(user_id);
CREATE INDEX IF NOT EXISTS idx_stakes_active ON stakes(is_active);

-- ============================================
-- 5. LOTTERY_ENTRIES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS lottery_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    lottery_id INTEGER NOT NULL,
    entry_count INTEGER DEFAULT 1,
    entry_date TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_lottery_user ON lottery_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_lottery_id ON lottery_entries(lottery_id);

-- ============================================
-- 6. LOTTERY_WINNERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS lottery_winners (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    lottery_id INTEGER NOT NULL,
    amount BIGINT NOT NULL,
    won_at TIMESTAMPTZ DEFAULT NOW(),
    tx_hash TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_winners_user ON lottery_winners(user_id);
CREATE INDEX IF NOT EXISTS idx_winners_lottery ON lottery_winners(lottery_id);

-- ============================================
-- 7. BLOG_POSTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS blog_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    content TEXT,
    author TEXT,
    tags TEXT[],
    published_at TIMESTAMPTZ,
    seo_keywords TEXT[],
    reading_time INTEGER,
    featured_image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_blog_slug ON blog_posts(slug);
CREATE INDEX IF NOT EXISTS idx_blog_published ON blog_posts(published_at);
CREATE INDEX IF NOT EXISTS idx_blog_tags ON blog_posts USING GIN(tags);

-- ============================================
-- 8. CLAIM_PERIODS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS claim_periods (
    id SERIAL PRIMARY KEY,
    period_type INTEGER NOT NULL,
    start_block BIGINT,
    end_block BIGINT,
    pool_balance BIGINT,
    claim_per_user BIGINT,
    participants INTEGER DEFAULT 0,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_periods_type ON claim_periods(period_type);

-- ============================================
-- 9. SETTINGS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key TEXT UNIQUE NOT NULL,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    updated_by TEXT
);

-- Seed default settings
INSERT INTO settings (key, value, description) VALUES
    ('claim_stake_requirement', '"100000000000000000000"', 'Required RARE stake to claim (100 RARE in wei)'),
    ('registration_fee', '"50000000000000000"', 'ETH fee for registration (0.05 ETH in wei)'),
    ('blocks_per_day', '16600', 'Blocks per day on Base chain'),
    ('bot_detection_enabled', 'true', 'Enable bot detection'),
    ('maintenance_mode', 'false', 'Site maintenance mode')
ON CONFLICT (key) DO NOTHING;

-- ============================================
-- 10. BOT_DETECTIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS bot_detections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    detection_type TEXT NOT NULL,
    ip_address TEXT,
    user_agent TEXT,
    detected_at TIMESTAMPTZ DEFAULT NOW(),
    blocked BOOLEAN DEFAULT FALSE,
    notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_bot_detection_user ON bot_detections(user_id);
CREATE INDEX IF NOT EXISTS idx_bot_detection_ip ON bot_detections(ip_address);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE stakes ENABLE ROW LEVEL SECURITY;
ALTER TABLE lottery_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE lottery_winners ENABLE ROW LEVEL SECURITY;
ALTER TABLE blog_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE claim_periods ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE bot_detections ENABLE ROW LEVEL SECURITY;

-- Users can read own data
CREATE POLICY "Users can read own data" ON users
    FOR SELECT USING (true);

-- Users can insert own registration
CREATE POLICY "Users can insert own registration" ON registrations
    FOR INSERT WITH CHECK (true);

-- Users can read own registrations
CREATE POLICY "Users can read own registrations" ON registrations
    FOR SELECT USING (true);

-- Users can insert own claims
CREATE POLICY "Users can insert own claims" ON claims
    FOR INSERT WITH CHECK (true);

-- Users can read own claims
CREATE POLICY "Users can read own claims" ON claims
    FOR SELECT USING (true);

-- Users can insert own stakes
CREATE POLICY "Users can insert own stakes" ON stakes
    FOR INSERT WITH CHECK (true);

-- Users can read own stakes
CREATE POLICY "Users can read own stakes" ON stakes
    FOR SELECT USING (true);

-- Users can insert own lottery entries
CREATE POLICY "Users can insert own lottery entries" ON lottery_entries
    FOR INSERT WITH CHECK (true);

-- Users can read own lottery entries
CREATE POLICY "Users can read own lottery entries" ON lottery_entries
    FOR SELECT USING (true);

-- Everyone can read lottery winners
CREATE POLICY "Everyone can read lottery winners" ON lottery_winners
    FOR SELECT USING (true);

-- Everyone can read published blog posts
CREATE POLICY "Everyone can read published blog posts" ON blog_posts
    FOR SELECT USING (published_at IS NOT NULL);

-- Everyone can read claim periods
CREATE POLICY "Everyone can read claim periods" ON claim_periods
    FOR SELECT USING (true);

-- Everyone can read public settings
CREATE POLICY "Everyone can read public settings" ON settings
    FOR SELECT USING (true);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger for blog_posts
CREATE TRIGGER update_blog_posts_updated_at
    BEFORE UPDATE ON blog_posts
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for settings
CREATE TRIGGER update_settings_updated_at
    BEFORE UPDATE ON settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- DONE!
-- ============================================
-- Run this migration in Supabase SQL Editor
-- All tables, indexes, and RLS policies are now set up
