# Supabase Database Schema - Rare Coin

## Overview

This schema replaces the defunct PhoneDB with Supabase PostgreSQL.

---

## Tables

### 1. `users`

| Column | Type | Description | Notes |
|---------|-------|-------------|--------|
| id | uuid | Primary key (auto-generated) |
| wallet_address | text, unique | User's blockchain wallet address |
| twitter_handle | text, nullable | Optional Twitter for social features |
| registered_at | timestamptz | When user first registered |
| last_claim_at | timestamptz | Last successful claim |
| claim_count | int | Total claims made |
| staking_active | boolean | Currently staking? |
| created_at | timestamptz | Row creation time |

**Indexes:**
- `idx_users_wallet`: `wallet_address` (unique)
- `idx_users_registered`: `registered_at`
- `idx_users_last_claim`: `last_claim_at`

**Row Level Security (RLS):**
- Public can read non-sensitive data (stats only)
- Users can update their own record
- Service role can do everything

---

### 2. `registrations`

| Column | Type | Description | Notes |
|---------|-------|-------------|--------|
| id | uuid | Primary key |
| user_id | uuid, foreign key → users.id | FK reference |
| period_id | int | Which claim period (1 or 2) |
| registered_at | timestamptz | When registered |
| stake_amount | bigint | Amount staked (wei) |
| stake_returned | boolean | Has stake been returned? |
| is_successful | boolean | Was claim successful? |
| created_at | timestamptz | Row creation time |

**Indexes:**
- `idx_registrations_user`: `user_id`
- `idx_registrations_period`: `period_id`

**RLS:**
- Users can insert their own registrations
- Users can read their own history
- Service role can read all

---

### 3. `claims`

| Column | Type | Description | Notes |
|---------|-------|-------------|--------|
| id | uuid | Primary key |
| registration_id | uuid, foreign key → registrations.id | FK reference |
| user_id | uuid, foreign key → users.id | FK reference |
| amount | bigint | Amount claimed (wei) |
| claimed_at | timestamptz | When claim was executed |
| tx_hash | text, nullable | Blockchain transaction hash |
| created_at | timestamptz | Row creation time |

**Indexes:**
- `idx_claims_user`: `user_id`
- `idx_claims_registration`: `registration_id`
- `idx_claims_date`: `claimed_at`

**RLS:**
- Users can insert their own claims
- Users can read their own history
- Service role can read all

---

### 4. `stakes`

| Column | Type | Description | Notes |
|---------|-------|-------------|--------|
| id | uuid | Primary key |
| user_id | uuid, foreign key → users.id | FK reference |
| amount | bigint | Amount staked (wei) |
| staked_at | timestamptz | When stake was created |
| unstaked_at | timestamptz, nullable | When unstaked (if applicable) |
| is_active | boolean | Currently staked? |
| reward_rate | decimal | Reward multiplier |
| created_at | timestamptz | Row creation time |

**Indexes:**
- `idx_stakes_user`: `user_id`
- `idx_stakes_active`: `is_active`

**RLS:**
- Users can insert their own stakes
- Users can read their own stakes
- Service role can read all

---

### 5. `lottery_entries`

| Column | Type | Description | Notes |
|---------|-------|-------------|--------|
| id | uuid | Primary key |
| user_id | uuid, foreign key → users.id | FK reference |
| lottery_id | int | Which lottery draw |
| entry_count | int | Number of tickets |
| entry_date | timestamptz | When entered |
| created_at | timestamptz | Row creation time |

**Indexes:**
- `idx_lottery_user`: `user_id`
- `idx_lottery_id`: `lottery_id`

**RLS:**
- Users can insert their own entries
- Users can read their own entries
- Service role can read all

---

### 6. `lottery_winners`

| Column | Type | Description | Notes |
|---------|-------|-------------|--------|
| id | uuid | Primary key |
| user_id | uuid, foreign key → users.id | FK reference |
| lottery_id | int | Which lottery draw |
| amount | bigint | Prize amount (wei) |
| won_at | timestamptz | When prize was awarded |
| tx_hash | text, nullable | Blockchain transaction hash |
| created_at | timestamptz | Row creation time |

**Indexes:**
- `idx_winners_user`: `user_id`
- `idx_winners_lottery`: `lottery_id`

**RLS:**
- Users can read all (transparency)
- Service role can insert (admin only)

---

### 7. `blog_posts`

| Column | Type | Description | Notes |
|---------|-------|-------------|--------|
| id | uuid | Primary key |
| slug | text, unique | URL-friendly slug |
| title | text | Post title |
| description | text | Meta description for SEO |
| content | text | MDX content body |
| author | text | Author name |
| tags | text[], nullable | Array of tags |
| published_at | timestamptz, nullable | When published |
| seo_keywords | text[], nullable | SEO keywords |
| reading_time | int | Estimated reading time (minutes) |
| featured_image_url | text, nullable | Featured image |
| created_at | timestamptz | Row creation time |
| updated_at | timestamptz | Last update |

**Indexes:**
- `idx_blog_slug`: `slug` (unique)
- `idx_blog_published`: `published_at`
- `idx_blog_tags`: `tags` (GIN index)

**RLS:**
- Public can read published posts only
- Admins can insert/update/delete

---

### 8. `claim_periods`

| Column | Type | Description | Notes |
|---------|-------|-------------|--------|
| id | int | Period ID (auto-increment) |
| period_type | int | 1 or 2 (dual pool system) |
| start_block | bigint | Blockchain block start |
| end_block | bigint | Blockchain block end |
| pool_balance | bigint | Total pool (wei) |
| claim_per_user | bigint | Claim amount per user (wei) |
| participants | int | Number of registrants |
| completed_at | timestamptz | When period ended |
| created_at | timestamptz | Row creation time |

**Indexes:**
- `idx_periods_id`: `id` (primary)
- `idx_periods_type`: `period_type`

**RLS:**
- Public can read (transparency)
- Service role can insert/update (admin only)

---

### 9. `settings`

| Column | Type | Description | Notes |
|---------|-------|-------------|--------|
| id | uuid | Primary key |
| key | text, unique | Setting name |
| value | jsonb | Setting value (flexible type) |
| description | text, nullable | What this setting does |
| updated_at | timestamptz | Last update time |
| updated_by | text, nullable | Who updated it |

**Settings to store:**
```json
{
  "claim_stake_requirement": "100000000000000000000", // 100 RARE in wei
  "registration_fee": "50000000000000000", // 0.05 ETH in wei
  "blocks_per_day": 16600,
  "bot_detection_enabled": true,
  "turnstile_site_key": "0x...",
  "maintenance_mode": false
}
```

**RLS:**
- Public can read non-sensitive settings
- Service role can read/write all

---

### 10. `bot_detections`

| Column | Type | Description | Notes |
|---------|-------|-------------|--------|
| id | uuid | Primary key |
| user_id | uuid, foreign key → users.id | FK reference |
| detection_type | text | "turnstile_failed", "rate_limit", "suspicious_pattern" |
| ip_address | text | IP (for rate limiting) |
| user_agent | text | Browser UA string |
| detected_at | timestamptz | When detected |
| blocked | boolean | Was action blocked? |
| notes | text, nullable | Additional context |

**Indexes:**
- `idx_bot_detection_user`: `user_id`
- `idx_bot_detection_ip`: `ip_address`

**RLS:**
- Service role can insert (turnstile verification)
- Service role can read all (admin only)

---

## Relationships (Foreign Keys)

```
users (1) ──┬──> registrations (many)
             │
             ├──> claims (many)
             ├──> stakes (many)
             ├──> lottery_entries (many)
             └──> lottery_winners (many)

registrations (1) ──> claims (many)
```

---

## Initial Data Seeding

```sql
-- Create default settings
INSERT INTO settings (key, value, description) VALUES
  ('claim_stake_requirement', '"100000000000000000000"', 'Required RARE stake to claim'),
  ('registration_fee', '"50000000000000000"', 'ETH fee for registration'),
  ('blocks_per_day', '16600', 'Blocks per day on Base chain'),
  ('bot_detection_enabled', 'true', 'Enable bot detection'),
  ('maintenance_mode', 'false', 'Site maintenance mode');
```

---

## SQL Migration File

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create tables (see table definitions above)
-- [Full SQL would be generated here]

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE registrations ENABLE ROW LEVEL SECURITY;
-- ... (enable for all tables)

-- Create RLS policies
CREATE POLICY "Users can read own data" ON users
  FOR SELECT USING (auth.uid()::text = id::text);

-- ... (create policies for all tables)
```

---

## Usage Examples

### Frontend (Client-side - use anon key)
```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
)

// Register user
await supabase.from('registrations').insert({
  user_id: userId,
  period_id: 1,
  stake_amount: 100 * 10**18
})
```

### Backend/Server (use service role key)
```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
)

// Update claim period
await supabase.from('claim_periods').update({
  pool_balance: 2 * 10**18
}).eq('id', 1)
```

---

## Security Notes

1. **Never expose service_role key** in frontend code
2. **Use anon key** for client-side operations
3. **Enable RLS** on all tables
4. **Create specific policies** for each table/operation
5. **Use prepared statements** to prevent SQL injection
6. **Validate inputs** before database operations
7. **Rate limit API calls** via Supabase Dashboard

---

## Migration Checklist

- [ ] Create all tables
- [ ] Set up foreign keys
- [ ] Create indexes
- [ ] Enable RLS on all tables
- [ ] Create RLS policies
- [ ] Seed initial settings
- [ ] Test anon key access (public)
- [ ] Test service role access (admin)
- [ ] Verify foreign key constraints
- [ ] Test cascade deletes

---
