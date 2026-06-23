-- ============================================================
-- Team Work Report System — Supabase SQL Schema
-- วิธีใช้: ไปที่ Supabase Dashboard → SQL Editor → วางโค้ดนี้ → Run
-- ============================================================

-- 1. สร้างตาราง teams (ทีม)
CREATE TABLE IF NOT EXISTS teams (
    id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name        TEXT NOT NULL,
    icon        TEXT DEFAULT '👥',
    color_bg    TEXT DEFAULT 'rgba(99,102,241,0.15)',
    color_accent TEXT DEFAULT '#6366f1',
    performance INTEGER DEFAULT 0 CHECK (performance >= 0 AND performance <= 100),
    reports     INTEGER DEFAULT 0,
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 2. สร้างตาราง members (สมาชิก)
CREATE TABLE IF NOT EXISTS members (
    id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    team_id      UUID REFERENCES teams(id) ON DELETE CASCADE,
    name         TEXT NOT NULL,
    role         TEXT DEFAULT '',
    avatar_color TEXT DEFAULT '#6366f1',
    created_at   TIMESTAMPTZ DEFAULT NOW(),
    updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- 3. สร้างตาราง reports (รายงาน) — สำหรับการเชื่อมต่อในอนาคต
CREATE TABLE IF NOT EXISTS reports (
    id           UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    team_id      UUID REFERENCES teams(id) ON DELETE SET NULL,
    title        TEXT NOT NULL,
    status       TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'draft')),
    reporter     TEXT,
    shift        TEXT DEFAULT 'เช้า',
    notes        TEXT,
    report_date  DATE,
    created_at   TIMESTAMPTZ DEFAULT NOW(),
    updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- 4. สร้างตาราง checklist_items (รายการตรวจสอบในรายงาน)
CREATE TABLE IF NOT EXISTS checklist_items (
    id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    report_id   UUID REFERENCES reports(id) ON DELETE CASCADE,
    text        TEXT NOT NULL,
    done        BOOLEAN DEFAULT FALSE,
    notes       TEXT,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Auto-update updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER teams_updated_at BEFORE UPDATE ON teams
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER members_updated_at BEFORE UPDATE ON members
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER reports_updated_at BEFORE UPDATE ON reports
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- 6. Row Level Security (RLS) — เปิดใช้งาน RLS
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE members ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE checklist_items ENABLE ROW LEVEL SECURITY;

-- 7. Policies — อนุญาตให้ anon อ่าน/เขียนได้ (ปรับแก้ตามความต้องการ)
-- สำหรับ Demo: อนุญาตทุกคน (ควรเปลี่ยนเป็น authenticated ในโปรดักชัน)
CREATE POLICY "Allow all teams" ON teams FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all members" ON members FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all reports" ON reports FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all checklist" ON checklist_items FOR ALL USING (true) WITH CHECK (true);

-- 8. Sample Data (ข้อมูลตัวอย่าง) — ลบบล็อกนี้ได้หากไม่ต้องการ
INSERT INTO teams (name, icon, color_bg, color_accent, performance, reports) VALUES
('ทีมซ่อมบำรุง', '🔧', 'rgba(59,130,246,0.15)', '#3b82f6', 87, 42),
('ทีมทำความสะอาด', '🧹', 'rgba(16,185,129,0.15)', '#10b981', 92, 38),
('ทีมรักษาความปลอดภัย', '🛡️', 'rgba(245,158,11,0.15)', '#f59e0b', 95, 56),
('ทีมสวนและภูมิทัศน์', '🌿', 'rgba(99,102,241,0.15)', '#6366f1', 78, 20);

-- ============================================================
-- หลังจาก Run SQL นี้แล้ว:
-- 1. ไปที่ teams.html แล้วกดปุ่ม "⚙️ ตั้งค่า"  
-- 2. กรอก Project URL และ Anon Key
-- 3. ระบบจะเชื่อมต่อและพร้อมใช้งานทันที
-- ============================================================
