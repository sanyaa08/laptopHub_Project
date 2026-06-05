const express = require('express');
const router = express.Router();
const {
  getCart, addToCart, updateCartItem, removeFromCart, clearCart,
} = require('../controllers/cartController');
const { authenticate } = require('../middleware/auth');

router.get('/', authenticate, getCart);
router.post('/', authenticate, addToCart);
router.put('/:id', authenticate, updateCartItem);
router.delete('/clear', authenticate, clearCart);
router.delete('/:id', authenticate, removeFromCart);

module.exports = router;
