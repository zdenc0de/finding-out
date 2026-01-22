-- ============================================================================
-- MIGRATION: Create Categories and Events Tables
-- Description: Creates the database schema for event categories and events
-- ============================================================================

-- ============================================================================
-- TABLE: categories
-- Stores event categories (Música, Deportes, Bazares, Tech, Artísticos)
-- ============================================================================
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  icon TEXT NOT NULL,           -- Material icon name (e.g., 'music_note')
  color TEXT NOT NULL,          -- Hex color (e.g., '#E91E63')
  display_order INT NOT NULL,   -- Order for display in UI
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- TABLE: events
-- Stores event information with location and category reference
-- ============================================================================
CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  image_url TEXT,
  location_lat DOUBLE PRECISION,
  location_lng DOUBLE PRECISION,
  address TEXT,
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- INDEXES
-- Improve query performance for common operations
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_events_category_id ON events(category_id);
CREATE INDEX IF NOT EXISTS idx_events_start_date ON events(start_date);
CREATE INDEX IF NOT EXISTS idx_events_created_by ON events(created_by);
CREATE INDEX IF NOT EXISTS idx_categories_display_order ON categories(display_order);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- Enable RLS and create policies for authenticated access
-- ============================================================================

-- Enable RLS on tables
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Categories: Readable by all authenticated users
CREATE POLICY "Categories are viewable by authenticated users"
  ON categories FOR SELECT
  TO authenticated
  USING (true);

-- Events: Readable by all authenticated users
CREATE POLICY "Events are viewable by authenticated users"
  ON events FOR SELECT
  TO authenticated
  USING (true);

-- Events: Insertable by authenticated users
CREATE POLICY "Users can create events"
  ON events FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = created_by);

-- Events: Updatable by event creator
CREATE POLICY "Users can update their own events"
  ON events FOR UPDATE
  TO authenticated
  USING (auth.uid() = created_by)
  WITH CHECK (auth.uid() = created_by);

-- Events: Deletable by event creator
CREATE POLICY "Users can delete their own events"
  ON events FOR DELETE
  TO authenticated
  USING (auth.uid() = created_by);

-- ============================================================================
-- SEED DATA: Initial Categories
-- ============================================================================
INSERT INTO categories (name, icon, color, display_order) VALUES
  ('Música', 'music_note', '#E91E63', 1),
  ('Deportes', 'sports_soccer', '#4CAF50', 2),
  ('Bazares', 'storefront', '#FF9800', 3),
  ('Tech', 'computer', '#2196F3', 4),
  ('Artísticos', 'palette', '#9C27B0', 5)
ON CONFLICT (name) DO NOTHING;
