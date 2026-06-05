const express = require('express');
const router = express.Router();
const {
  signup, login, getProfile, getAllUsers, updateUser, deleteUser,
  signupValidation, loginValidation,
} = require('../controllers/authController');
const { authenticate, adminOnly } = require('../middleware/auth');

// Public routes
router.post('/signup', signupValidation, signup);
router.post('/login', loginValidation, login);

// Protected routes
router.get('/profile', authenticate, getProfile);

// Admin routes (User Module CRUD)
router.get('/users', authenticate, adminOnly, getAllUsers);
router.put('/users/:id', authenticate, adminOnly, updateUser);
router.delete('/users/:id', authenticate, adminOnly, deleteUser);

module.exports = router;
