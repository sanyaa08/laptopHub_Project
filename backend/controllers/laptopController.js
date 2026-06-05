const db = require('../config/database');

// ─── GET ALL Laptops ──────────────────────────────────────
const getAllLaptops = async (req, res) => {
  try {
    const { search, brand, min_price, max_price, featured, limit = 50, offset = 0 } = req.query;

    let query = 'SELECT * FROM laptops WHERE 1=1';
    const params = [];

    if (search) {
      query += ' AND (name LIKE ? OR brand LIKE ? OR processor LIKE ?)';
      const s = `%${search}%`;
      params.push(s, s, s);
    }

    if (brand) {
      query += ' AND brand = ?';
      params.push(brand);
    }

    if (min_price) {
      query += ' AND price >= ?';
      params.push(parseFloat(min_price));
    }

    if (max_price) {
      query += ' AND price <= ?';
      params.push(parseFloat(max_price));
    }

    if (featured === 'true') {
      query += ' AND is_featured = TRUE';
    }

    query += ' ORDER BY is_featured DESC, created_at DESC LIMIT ? OFFSET ?';
    params.push(parseInt(limit), parseInt(offset));

    const [rows] = await db.query(query, params);

    // Count total for pagination
    let countQuery = 'SELECT COUNT(*) as total FROM laptops WHERE 1=1';
    const countParams = params.slice(0, params.length - 2);
    if (search) countQuery += ' AND (name LIKE ? OR brand LIKE ? OR processor LIKE ?)';
    if (brand) countQuery += ' AND brand = ?';
    if (min_price) countQuery += ' AND price >= ?';
    if (max_price) countQuery += ' AND price <= ?';
    if (featured === 'true') countQuery += ' AND is_featured = TRUE';

    const [countRows] = await db.query(countQuery, countParams);

    res.json({
      success: true,
      laptops: rows,
      total: countRows[0].total,
      limit: parseInt(limit),
      offset: parseInt(offset),
    });
  } catch (err) {
    console.error('Get laptops error:', err);
    res.status(500).json({ success: false, message: 'Server error.' });
  }
};

// ─── GET SINGLE Laptop ────────────────────────────────────
const getLaptopById = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM laptops WHERE id = ?', [req.params.id]);
    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Laptop not found.' });
    }
    res.json({ success: true, laptop: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Server error.' });
  }
};

// ─── CREATE Laptop (Admin) ───────────────────────────────
const createLaptop = async (req, res) => {
  const {
    name, brand, price, image_url, processor, ram,
    storage, display, graphics, battery, weight, os,
    description, stock, is_featured,
  } = req.body;

  if (!name || !brand || !price) {
    return res.status(400).json({ success: false, message: 'Name, brand, and price are required.' });
  }

  try {
    const [result] = await db.query(
      `INSERT INTO laptops 
       (name, brand, price, image_url, processor, ram, storage, display, graphics, battery, weight, os, description, stock, is_featured)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, brand, price, image_url, processor, ram, storage, display, graphics, battery, weight, os, description, stock || 0, is_featured || false]
    );

    const [newLaptop] = await db.query('SELECT * FROM laptops WHERE id = ?', [result.insertId]);

    res.status(201).json({
      success: true,
      message: 'Laptop added successfully!',
      laptop: newLaptop[0],
    });
  } catch (err) {
    console.error('Create laptop error:', err);
    res.status(500).json({ success: false, message: 'Server error.' });
  }
};

// ─── UPDATE Laptop (Admin) ───────────────────────────────
const updateLaptop = async (req, res) => {
  const { id } = req.params;
  const {
    name, brand, price, image_url, processor, ram,
    storage, display, graphics, battery, weight, os,
    description, stock, is_featured,
  } = req.body;

  try {
    const [existing] = await db.query('SELECT id FROM laptops WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({ success: false, message: 'Laptop not found.' });
    }

    await db.query(
      `UPDATE laptops SET 
       name=?, brand=?, price=?, image_url=?, processor=?, ram=?, storage=?, 
       display=?, graphics=?, battery=?, weight=?, os=?, description=?, stock=?, is_featured=?
       WHERE id=?`,
      [name, brand, price, image_url, processor, ram, storage, display, graphics, battery, weight, os, description, stock, is_featured, id]
    );

    const [updated] = await db.query('SELECT * FROM laptops WHERE id = ?', [id]);

    res.json({
      success: true,
      message: 'Laptop updated successfully!',
      laptop: updated[0],
    });
  } catch (err) {
    console.error('Update laptop error:', err);
    res.status(500).json({ success: false, message: 'Server error.' });
  }
};

// ─── DELETE Laptop (Admin) ───────────────────────────────
const deleteLaptop = async (req, res) => {
  const { id } = req.params;
  try {
    const [existing] = await db.query('SELECT id FROM laptops WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({ success: false, message: 'Laptop not found.' });
    }
    await db.query('DELETE FROM laptops WHERE id = ?', [id]);
    res.json({ success: true, message: 'Laptop deleted successfully!' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Server error.' });
  }
};

// ─── GET Brands ───────────────────────────────────────────
const getBrands = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT DISTINCT brand FROM laptops ORDER BY brand');
    res.json({ success: true, brands: rows.map(r => r.brand) });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Server error.' });
  }
};

module.exports = { getAllLaptops, getLaptopById, createLaptop, updateLaptop, deleteLaptop, getBrands };
