const express = require('express');
const router = express.Router();
const {
  getAllLaptops, getLaptopById, createLaptop,
  updateLaptop, deleteLaptop, getBrands,
} = require('../controllers/laptopController');
const { authenticate, adminOnly } = require('../middleware/auth');

// Public routes (authenticated users can read)
router.get('/', authenticate, getAllLaptops);
router.get('/brands', authenticate, getBrands);
router.get('/:id', authenticate, getLaptopById);

// Admin-only CRUD
router.post('/', authenticate, adminOnly, createLaptop);
router.put('/:id', authenticate, adminOnly, updateLaptop);
router.delete('/:id', authenticate, adminOnly, deleteLaptop);

module.exports = router;
