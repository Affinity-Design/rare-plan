-- Rare Claims V3 - Supabase Schema
-- Run this in Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_address TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- V3 Streak System
  claim_streak INTEGER DEFAULT 0,
  last_claim_day BIGINT DEFAULT 0, -- Days since epoch
  
  -- V3 Holding Tier (0-5)
  holding_tier INTEGER DEFAULT 0,
  
  -- Stats
  total_claims INTEGER DEFAULT 0,
  total_rare_claimed DECIMAL(38,18) DEFAULT 0,
  total_stakes INTEGER DEFAULT 0,
  total_lottery_entries INTEGER DEFAULT 0,
  
  -- Migration
  migrated_from_gnosis BOOLEAN DEFAULT FALSE,
  gnosis_snapshot_balance DECIMAL(38,18) DEFAULT 0,
  nft_bonus_rare DECIMAL(38,18) DEFAULT 0
);

-- Claims history
CREATE TABLE IF NOT EXISTS claims (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  amount DECIMAL(38,18) NOT NULL,
  bonus_applied INTEGER DEFAULT 0, -- basis points (100 = 1%)
  streak_at_claim INTEGER DEFAULT 0,
  holding_tier_at_claim INTEGER DEFAULT 0,
  pool_cycle INTEGER NOT NULL,
  pool_type TEXT NOT NULL, -- 'A' or 'B'
  tx_hash TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Stakes
CREATE TABLE IF NOT EXISTS stakes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  amount DECIMAL(38,18) NOT NULL, -- LP tokens
  term INTEGER NOT NULL, -- 0=7d, 1=28d, 2=84d
  multiplier INTEGER NOT NULL, -- 1, 2, or 3
  start_time TIMESTAMPTZ DEFAULT NOW(),
  end_time TIMESTAMPTZ NOT NULL,
  last_claim_time TIMESTAMPTZ,
  total_claimed DECIMAL(38,18) DEFAULT 0,
  active BOOLEAN DEFAULT TRUE,
  tx_hash TEXT
);

-- Lottery entries
CREATE TABLE IF NOT EXISTS lottery_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  lottery_round INTEGER NOT NULL,
  entry_count INTEGER DEFAULT 1,
  entry_method TEXT DEFAULT 'eth', -- 'eth' or 'rare'
  tx_hash TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Lottery rounds
CREATE TABLE IF NOT EXISTS lottery_rounds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  round_number INTEGER UNIQUE NOT NULL,
  start_time TIMESTAMPTZ DEFAULT NOW(),
  end_time TIMESTAMPTZ,
  winner_address TEXT,
  prize_eth DECIMAL(38,18),
  prize_rare DECIMAL(38,18),
  total_entries INTEGER DEFAULT 0,
  total_players INTEGER DEFAULT 0,
  vrf_request_id TEXT,
  vrf_randomness TEXT,
  status TEXT DEFAULT 'active', -- 'active', 'drawing', 'completed'
  tx_hash TEXT
);

-- Streak events (analytics)
CREATE TABLE IF NOT EXISTS streak_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  streak_before INTEGER,
  streak_after INTEGER,
  event_type TEXT, -- 'continue', 'reset', 'milestone'
  bonus_earned INTEGER, -- basis points
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Airdrop claims (migration from Gnosis)
CREATE TABLE IF NOT EXISTS airdrop_claims (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  gnosis_address TEXT NOT NULL,
  rare_balance DECIMAL(38,18) DEFAULT 0,
  lp_underlying DECIMAL(38,18) DEFAULT 0,
  staked_underlying DECIMAL(38,18) DEFAULT 0,
  nft_bonus DECIMAL(38,18) DEFAULT 0,
  total_airdrop DECIMAL(38,18) NOT NULL,
  claimed BOOLEAN DEFAULT FALSE,
  claimed_at TIMESTAMPTZ,
  tx_hash TEXT,
  merkle_proof TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_wallet ON users(wallet_address);
CREATE INDEX IF NOT EXISTS idx_users_streak ON users(claim_streak DESC);
CREATE INDEX IF NOT EXISTS idx_claims_user ON claims(user_id);
CREATE INDEX IF NOT EXISTS idx_claims_created ON claims(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_stakes_user ON stakes(user_id);
CREATE INDEX IF NOT EXISTS idx_stakes_active ON stakes(active) WHERE active = TRUE;
CREATE INDEX IF NOT EXISTS idx_stakes_end ON stakes(end_time) WHERE active = TRUE;
CREATE INDEX IF NOT EXISTS idx_lottery_round ON lottery_entries(lottery_round);
CREATE INDEX IF NOT EXISTS idx_lottery_rounds_status ON lottery_rounds(status);
CREATE INDEX IF NOT EXISTS idx_airdrop_address ON airdrop_claims(gnosis_address);
CREATE INDEX IF NOT EXISTS idx_airdrop_claimed ON airdrop_claims(claimed) WHERE claimed = FALSE;

-- Updated_at trigger for users
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE stakes ENABLE ROW LEVEL SECURITY;
ALTER TABLE lottery_entries ENABLE ROW LEVEL SECURITY;

-- Users can only read their own data
CREATE POLICY "Users can view own data" ON users
  FOR SELECT USING (wallet_address = current_user_address());

CREATE POLICY "Users can view own claims" ON claims
  FOR SELECT USING (user_id IN (
    SELECT id FROM users WHERE wallet_address = current_user_address()
  ));

CREATE POLICY "Users can view own stakes" ON stakes
  FOR SELECT USING (user_id IN (
    SELECT id FROM users WHERE wallet_address = current_user_address()
  ));

CREATE POLICY "Users can view own lottery entries" ON lottery_entries
  FOR SELECT USING (user_id IN (
    SELECT id FROM users WHERE wallet_address = current_user_address()
  ));

-- Note: current_user_address() would need to be a custom function
-- that extracts the address from the JWT token

-- Helper function to get or create user
CREATE OR REPLACE FUNCTION get_or_create_user(wallet_addr TEXT)
RETURNS UUID AS $$
DECLARE
  user_id UUID;
BEGIN
  SELECT id INTO user_id FROM users WHERE wallet_address = LOWER(wallet_addr);
  
  IF user_id IS NULL THEN
    INSERT INTO users (wallet_address)
    VALUES (LOWER(wallet_addr))
    RETURNING id INTO user_id;
  END IF;
  
  RETURN user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper function to update streak
CREATE OR REPLACE FUNCTION update_claim_streak(user_wallet TEXT)
RETURNS INTEGER AS $$
DECLARE
  current_day BIGINT := EXTRACT(EPOCH FROM NOW()) / 86400;
  user_rec RECORD;
  new_streak INTEGER;
BEGIN
  SELECT * INTO user_rec FROM users WHERE wallet_address = LOWER(user_wallet);
  
  IF user_rec.last_claim_day = current_day - 1 THEN
    -- Consecutive day, increment streak
    new_streak := user_rec.claim_streak + 1;
  ELSIF user_rec.last_claim_day < current_day - 1 THEN
    -- Missed a day, reset streak
    new_streak := 1;
    
    -- Log streak reset
    INSERT INTO streak_events (user_id, streak_before, streak_after, event_type)
    VALUES (user_rec.id, user_rec.claim_streak, 0, 'reset');
  ELSE
    -- Same day, no change
    new_streak := user_rec.claim_streak;
  END IF;
  
  -- Update user
  UPDATE users SET
    claim_streak = new_streak,
    last_claim_day = current_day,
    total_claims = total_claims + 1
  WHERE wallet_address = LOWER(user_wallet);
  
  -- Log milestone if applicable
  IF new_streak IN (10, 30, 60, 150, 365) THEN
    INSERT INTO streak_events (user_id, streak_before, streak_after, event_type)
    VALUES (user_rec.id, user_rec.claim_streak, new_streak, 'milestone');
  END IF;
  
  RETURN new_streak;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES TO anon, authenticated;
GRANT EXECUTE ON ALL FUNCTIONS TO anon, authenticated;

-- Insert default lottery round
INSERT INTO lottery_rounds (round_number, status)
VALUES (1, 'active')
ON CONFLICT (round_number) DO NOTHING;
