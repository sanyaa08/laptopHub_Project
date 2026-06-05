const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();

// ─── Middleware ──────────────────────────────────────────
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ─── Routes ──────────────────────────────────────────────
app.use('/api/auth',    require('./routes/auth'));
app.use('/api/laptops', require('./routes/laptops'));
app.use('/api/cart',    require('./routes/cart'));

// ─── Health Check ────────────────────────────────────────
app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    message: '🚀 Laptop Hub API is running!',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

// ─── 404 Handler ─────────────────────────────────────────
app.use('*', (req, res) => {
  res.status(404).json({ success: false, message: 'Route not found.' });
});

// ─── Error Handler ───────────────────────────────────────
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ success: false, message: 'Something went wrong!' });
});

// ─── Auto-seed admin on first run ────────────────────────
async function autoSeedAdmin() {
  try {
    const db = require('./config/database');
    const bcrypt = require('bcryptjs');

    const [rows] = await db.query("SELECT id FROM users WHERE role='admin' LIMIT 1");

    if (rows.length === 0) {
      const hash = await bcrypt.hash('Admin@123', 10);
      await db.query(
        'INSERT IGNORE INTO users (name, email, password, role) VALUES (?,?,?,?)',
        ['Super Admin', 'admin@laptophub.com', hash, 'admin']
      );
      console.log('✅ Default admin created: admin@laptophub.com / Admin@123');
    } else {
      console.log('✅ Admin user already exists.');
    }
  } catch (err) {
    console.error('⚠️  Auto-seed skipped (DB not ready?):', err.message);
  }
}

// ─── Start Server ─────────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, async () => {
  console.log(`\n🚀 Laptop Hub Server running on port ${PORT}`);
  console.log(`📡 API Base URL: http://localhost:${PORT}/api`);
  //console.log(`❤️  Health check: http://localhost:${PORT}/api/health\n`);
  await autoSeedAdmin();
});