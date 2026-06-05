const db = require('../config/database');

// ─── GET Cart (user's cart) ───────────────────────────────
const getCart = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT c.id, c.quantity, c.created_at,
              l.id as laptop_id, l.name, l.brand, l.price, l.image_url,
              l.processor, l.ram, l.storage, l.stock,
              (c.quantity * l.price) as subtotal
       FROM cart c
       JOIN laptops l ON c.laptop_id = l.id
       WHERE c.user_id = ?
       ORDER BY c.created_at DESC`,
      [req.user.id]
    );

    const total = rows.reduce((sum, item) => sum + parseFloat(item.subtotal), 0);

    res.json({
      success: true,
      cart: rows,
      total: total.toFixed(2),
      item_count: rows.length,
    });
  } catch (err) {
    console.error('Get cart error:', err);
    res.status(500).json({ success: false, message: 'Server error.' });
  }
};

// ─── ADD to Cart ──────────────────────────────────────────
const addToCart = async (req, res) => {
  const { laptop_id, quantity = 1 } = req.body;

  if (!laptop_id) {
    return res.status(400).json({ success: false, message: 'laptop_id is required.' });
  }

  try {
    // Check laptop exists and has stock
    const [laptop] = await db.query('SELECT id, stock FROM laptops WHERE id = ?', [laptop_id]);
    if (laptop.length === 0) {
      return res.status(404).json({ success: false, message: 'Laptop not found.' });
    }

    if (laptop[0].stock < quantity) {
      return res.status(400).json({ success: false, message: 'Insufficient stock.' });
    }

    // Upsert cart item
    await db.query(
      `INSERT INTO cart (user_id, laptop_id, quantity) VALUES (?, ?, ?)
       ON DUPLICATE KEY UPDATE quantity = quantity + ?`,
      [req.user.id, laptop_id, quantity, quantity]
    );

    res.status(201).json({ success: true, message: 'Item added to cart!' });
  } catch (err) {
    console.error('Add to cart error:', err);
    res.status(500).json({ success: false, message: 'Server error.' });
  }
};

// ─── UPDATE Cart Item Quantity ────────────────────────────
const updateCartItem = async (req, res) => {
  const { id } = req.params;
  const { quantity } = req.body;

  if (!quantity || quantity < 1) {
    return res.status(400).json({ success: false, message: 'Quantity must be at least 1.' });
  }

  try {
    const [item] = await db.query('SELECT id FROM cart WHERE id = ? AND user_id = ?', [id, req.user.id]);
    if (item.length === 0) {
      return res.status(404).json({ success: false, message: 'Cart item not found.' });
    }

    await db.query('UPDATE cart SET quantity = ? WHERE id = ?', [quantity, id]);
    res.json({ success: true, message: 'Cart updated successfully!' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Server error.' });
  }
};

// ─── REMOVE from Cart ─────────────────────────────────────
const removeFromCart = async (req, res) => {
  const { id } = req.params;
  try {
    await db.query('DELETE FROM cart WHERE id = ? AND user_id = ?', [id, req.user.id]);
    res.json({ success: true, message: 'Item removed from cart.' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Server error.' });
  }
};

// ─── CLEAR Cart ───────────────────────────────────────────
const clearCart = async (req, res) => {
  try {
    await db.query('DELETE FROM cart WHERE user_id = ?', [req.user.id]);
    res.json({ success: true, message: 'Cart cleared.' });
  } catch (err) {
    res.status(500).json({ success: false, message: 'Server error.' });
  }
};

module.exports = { getCart, addToCart, updateCartItem, removeFromCart, clearCart };
