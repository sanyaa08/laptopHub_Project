/**
 * Run once to create/reset the admin user.
 * Usage: node config/seed_admin.js
 */
require('dotenv').config({ path: require('path').join(__dirname, '../.env') });
const bcrypt = require('bcryptjs');
const db = require('./database');

async function seedAdmin() {
  try {
    const name     = 'Super Admin';
    const email    = 'admin@laptophub.com';
    const password = 'Admin@123';
    const role     = 'admin';

    const hashedPassword = await bcrypt.hash(password, 10);

    await db.query(
      `INSERT INTO users (name, email, password, role)
       VALUES (?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE password = ?, role = ?`,
      [name, email, hashedPassword, role, hashedPassword, role]
    );

    console.log('\n✅ Admin user created/updated successfully!');
    console.log('   Email   :', email);
    console.log('   Password:', password);
    console.log('   Role    :', role);
    process.exit(0);
  } catch (err) {
    console.error('❌ Error:', err.message);
    process.exit(1);
  }
}

seedAdmin();