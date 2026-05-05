-- ════════════════════════════════════════════════════════════════
-- ACM Bangalore Professional Chapter — Supabase Setup Script
-- Paste this entire file into your Supabase SQL Editor and Run.
-- ════════════════════════════════════════════════════════════════

-- ── 1. ADMINS ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS admins (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  username      text UNIQUE NOT NULL,
  password_hash text NOT NULL,
  created_by    text,
  created_at    timestamptz DEFAULT now()
);

-- ── 2. EVENTS ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS events (
  id            uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  type          text    NOT NULL CHECK (type IN ('upcoming','past')),
  title         text    NOT NULL,
  description   text    DEFAULT '',
  event_date    date,
  start_time    text    DEFAULT '',
  end_time      text    DEFAULT '',
  location      text    DEFAULT '',
  mode          text    DEFAULT 'In-person only',
  speaker_name  text    DEFAULT '',
  speaker_org   text    DEFAULT '',
  host_name     text    DEFAULT '',
  host_org      text    DEFAULT '',
  banner_url    text,
  banner_path   text,
  article_text  text    DEFAULT '',
  display_order integer DEFAULT 0,
  created_at    timestamptz DEFAULT now()
);

-- ── 3. EVENT PHOTOS ──────────────────────────────────────────────
-- Photos shown in the article page of each past event
CREATE TABLE IF NOT EXISTS event_photos (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  event_id      uuid NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  url           text NOT NULL,
  storage_path  text DEFAULT '',
  caption       text DEFAULT '',
  display_order integer DEFAULT 0,
  created_at    timestamptz DEFAULT now()
);

-- ── 4. EVENT REGISTRATIONS ───────────────────────────────────────
-- Per-event sign-up submissions from the public events page
CREATE TABLE IF NOT EXISTS event_registrations (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  event_id    uuid REFERENCES events(id) ON DELETE CASCADE,
  first_name  text NOT NULL,
  last_name   text NOT NULL,
  email       text NOT NULL,
  phone       text DEFAULT '',
  affiliation text DEFAULT '',
  message     text DEFAULT '',
  created_at  timestamptz DEFAULT now()
);

-- ── 5. GALLERY PHOTOS ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS gallery_photos (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  url           text NOT NULL,
  storage_path  text DEFAULT '',
  caption       text DEFAULT '',
  display_order integer DEFAULT 0,
  created_at    timestamptz DEFAULT now()
);

-- ── 6. FORM SUBMISSIONS ──────────────────────────────────────────
-- Membership applications and contact messages from join.html
CREATE TABLE IF NOT EXISTS form_submissions (
  id           uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  type         text DEFAULT 'membership' CHECK (type IN ('membership','contact')),
  first_name   text,
  last_name    text,
  email        text NOT NULL,
  affiliation  text,
  role         text,
  interests    text,
  acm_number   text,
  subject      text,
  message      text,
  submitted_at timestamptz DEFAULT now()
);

-- ── 7. EVENT CONTACT MESSAGES ────────────────────────────────────
-- Messages sent via "Contact Organisers" on event cards
CREATE TABLE IF NOT EXISTS event_contact_messages (
  id           uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  event_id     uuid REFERENCES events(id) ON DELETE SET NULL,
  event_title  text DEFAULT '',
  name         text NOT NULL,
  phone        text DEFAULT '',
  email        text NOT NULL,
  organisation text DEFAULT '',
  message      text NOT NULL,
  created_at   timestamptz DEFAULT now()
);

-- ── 8. DISABLE RLS (anon key drives everything via app-level auth) ─
ALTER TABLE admins                  DISABLE ROW LEVEL SECURITY;
ALTER TABLE events                  DISABLE ROW LEVEL SECURITY;
ALTER TABLE event_photos            DISABLE ROW LEVEL SECURITY;
ALTER TABLE event_registrations     DISABLE ROW LEVEL SECURITY;
ALTER TABLE gallery_photos          DISABLE ROW LEVEL SECURITY;
ALTER TABLE form_submissions        DISABLE ROW LEVEL SECURITY;
ALTER TABLE event_contact_messages  DISABLE ROW LEVEL SECURITY;

-- Grant anon role full access
GRANT ALL ON admins                  TO anon;
GRANT ALL ON events                  TO anon;
GRANT ALL ON event_photos            TO anon;
GRANT ALL ON event_registrations     TO anon;
GRANT ALL ON gallery_photos          TO anon;
GRANT ALL ON form_submissions        TO anon;
GRANT ALL ON event_contact_messages  TO anon;

-- ── 8. INITIAL ADMIN ACCOUNT ─────────────────────────────────────
-- username: surya.rimmalapudi  |  password: abc123
INSERT INTO admins (username, password_hash)
VALUES (
  'surya.rimmalapudi',
  '$2b$10$nMZBZTOLNYpGwU0v4h3HUO4R3FCs3rbgW4CknW0NatsPgW9Aplomi'
)
ON CONFLICT (username) DO NOTHING;

-- ════════════════════════════════════════════════════════════════
-- STORAGE — do this manually in the Supabase Dashboard:
--
--  1. Go to Storage → New bucket
--  2. Name: acm-media   |   Toggle "Public bucket" ON → Save
--  3. Go to Storage → Policies → acm-media → New policy (for each):
--
--     Name: public_select  | Operation: SELECT | Role: anon | Definition: true
--     Name: anon_insert    | Operation: INSERT | Role: anon | Definition: true
--     Name: anon_delete    | Operation: DELETE | Role: anon | Definition: true
--
-- Folder layout used by the app:
--   acm-media/event-banners/<filename>
--   acm-media/event-photos/<event_id>/<filename>
--   acm-media/gallery/<filename>
-- ════════════════════════════════════════════════════════════════
