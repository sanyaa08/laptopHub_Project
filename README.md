# 💻 Laptop Hub — Full Stack Mobile Application

> A professional Flutter + Node.js + MySQL application with role-based access control, complete CRUD for two modules (Laptops & Users), JWT authentication, and a stunning dark-themed UI.

---

## 📁 Project Structure

```
laptop_hub/
├── backend/                   # Node.js REST API
│   ├── config/
│   │   ├── database.js        # MySQL connection pool
│   │   └── schema.sql         # DB schema + seed data
│   ├── controllers/
│   │   ├── authController.js  # Signup, Login, User CRUD
│   │   ├── laptopController.js# Laptop CRUD
│   │   └── cartController.js  # Cart CRUD
│   ├── middleware/
│   │   └── auth.js            # JWT verify + Admin guard
│   ├── routes/
│   │   ├── auth.js
│   │   ├── laptops.js
│   │   └── cart.js
│   ├── .env                   # Environment variables
│   ├── package.json
│   └── server.js              # Express app entry point
│
└── flutter_app/               # Flutter Frontend
    ├── lib/
    │   ├── main.dart           # App entry + Splash
    │   ├── models/             # Data models
    │   ├── providers/          # State (AuthProvider, LaptopProvider, CartProvider)
    │   ├── screens/
    │   │   ├── auth/           # Login, Signup
    │   │   ├── home/           # Home, MainNavigation
    │   │   ├── laptops/        # List, Detail, Form (Admin CRUD)
    │   │   ├── cart/           # Cart screen
    │   │   ├── admin/          # Admin Dashboard (User CRUD)
    │   │   └── profile/        # Profile + Logout
    │   ├── services/
    │   │   └── api_service.dart# All HTTP calls
    │   ├── theme/
    │   │   └── app_theme.dart  # Dark theme, colors, gradients
    │   └── widgets/            # Reusable UI components
    └── pubspec.yaml
```

---

## 🚀 Setup Instructions

### 1. MySQL Database

1. Open MySQL Workbench or terminal
2. Run the schema file:
```sql
SOURCE /path/to/laptop_hub/backend/config/schema.sql;
```
This creates the database, all tables, and seeds 8 sample laptops + 1 admin user.

**Default Admin Credentials:**
- Email: `admin@laptophub.com`
- Password: `Admin@123`

> ⚠️ The seed admin password in schema.sql uses a placeholder hash. Generate a real one:
> ```js
> require('bcryptjs').hashSync('Admin@123', 10)
> ```
> Then replace the hash in the INSERT statement.

---

### 2. Backend (Node.js)

```bash
cd laptop_hub/backend

# Install dependencies
npm install

# Configure environment
# Edit .env with your MySQL credentials:
#   DB_HOST=localhost
#   DB_USER=root
#   DB_PASSWORD=your_password
#   DB_NAME=laptop_hub_db

# Start the server
npm start        # production
npm run dev      # development (nodemon)
```

Server runs at: **http://localhost:3000**

Health check: **http://localhost:3000/api/health**

---

### 3. Flutter App

```bash
cd laptop_hub/flutter_app

# Install Flutter dependencies
flutter pub get

# Configure API base URL
# Edit lib/utils/constants.dart:
#   Android emulator : http://10.0.2.2:3000/api
#   iOS simulator    : http://localhost:3000/api
#   Physical device  : http://<YOUR_IP>:3000/api

# Run the app
flutter run
```

---

## 📡 API Endpoints

### Auth Module (Module 1 — Users CRUD)
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| POST | /api/auth/signup | Public | Register new user |
| POST | /api/auth/login | Public | Login & get JWT |
| GET | /api/auth/profile | Auth | Get own profile |
| GET | /api/auth/users | Admin | List all users |
| PUT | /api/auth/users/:id | Admin | Update user |
| DELETE | /api/auth/users/:id | Admin | Delete user |

### Laptops Module (Module 2 — Laptops CRUD)
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| GET | /api/laptops | Auth | Get all laptops (search/filter) |
| GET | /api/laptops/:id | Auth | Get laptop by ID |
| POST | /api/laptops | Admin | Create laptop |
| PUT | /api/laptops/:id | Admin | Update laptop |
| DELETE | /api/laptops/:id | Admin | Delete laptop |
| GET | /api/laptops/brands | Auth | List all brands |

### Cart Module
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| GET | /api/cart | Auth | Get user's cart |
| POST | /api/cart | Auth | Add item to cart |
| PUT | /api/cart/:id | Auth | Update quantity |
| DELETE | /api/cart/:id | Auth | Remove item |
| DELETE | /api/cart/clear | Auth | Clear cart |

---

## 🔐 Role-Based Access

| Feature | Regular User | Admin |
|---------|-------------|-------|
| View laptops | ✅ | ✅ |
| Add to cart | ✅ | ✅ |
| View profile | ✅ | ✅ |
| Add laptop | ❌ | ✅ |
| Edit laptop | ❌ | ✅ |
| Delete laptop | ❌ | ✅ |
| View all users | ❌ | ✅ |
| Edit/Delete users | ❌ | ✅ |
| Admin Dashboard | ❌ | ✅ |

---

## 🛠️ Postman Testing

### Step 1 — Signup
```json
POST /api/auth/signup
{
  "name": "Test Admin",
  "email": "admin@laptophub.com",
  "password": "Admin@123",
  "role": "admin"
}
```

### Step 2 — Login (copy the token)
```json
POST /api/auth/login
{
  "email": "admin@laptophub.com",
  "password": "Admin@123"
}
```

### Step 3 — Use token in headers
```
Authorization: Bearer <your_token_here>
```

### Step 4 — Create Laptop (Admin)
```json
POST /api/laptops
{
  "name": "Test Laptop Pro",
  "brand": "TestBrand",
  "price": 999.99,
  "processor": "Intel i7",
  "ram": "16GB",
  "storage": "512GB SSD",
  "stock": 10
}
```

---

## 📊 Database Schema

### users
| Column | Type | Description |
|--------|------|-------------|
| id | INT PK | Auto increment |
| name | VARCHAR(100) | Full name |
| email | VARCHAR(150) UNIQUE | Email address |
| password | VARCHAR(255) | Bcrypt hash |
| role | ENUM('user','admin') | Access level |
| created_at | TIMESTAMP | Created date |

### laptops
| Column | Type | Description |
|--------|------|-------------|
| id | INT PK | Auto increment |
| name | VARCHAR(200) | Laptop name |
| brand | VARCHAR(100) | Brand name |
| price | DECIMAL(10,2) | Price in USD |
| image_url | VARCHAR(500) | Image link |
| processor | VARCHAR(150) | CPU info |
| ram | VARCHAR(50) | RAM info |
| storage | VARCHAR(100) | Storage info |
| display | VARCHAR(100) | Screen info |
| graphics | VARCHAR(150) | GPU info |
| battery | VARCHAR(100) | Battery life |
| weight | VARCHAR(50) | Weight |
| os | VARCHAR(100) | Operating system |
| description | TEXT | Full description |
| stock | INT | Available units |
| is_featured | BOOLEAN | Featured flag |

### cart
| Column | Type | Description |
|--------|------|-------------|
| id | INT PK | Auto increment |
| user_id | INT FK | References users |
| laptop_id | INT FK | References laptops |
| quantity | INT | Item quantity |

---

## 📱 App Screens

1. **Splash Screen** — Animated logo, auto-login if token saved
2. **Login Screen** — Email/password with demo credentials shown
3. **Signup Screen** — Name, email, password, role selector
4. **Home Screen** — Stats, hero banner, featured laptops, grid
5. **Laptop List** — Search bar, brand filter chips, list with edit/delete (admin)
6. **Laptop Detail** — Full specs, add to cart, edit button (admin)
7. **Laptop Form** — Create/Edit form with all fields (admin only)
8. **Cart Screen** — Items, quantity controls, order summary
9. **Admin Dashboard** — Stats, quick actions, users CRUD table
10. **Profile Screen** — User info, role badge, logout

---

## 🎨 Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.x, Dart |
| State Management | Provider |
| HTTP Client | http package |
| Local Storage | shared_preferences |
| UI | Google Fonts (Outfit), flutter_animate, cached_network_image |
| Backend | Node.js, Express.js |
| Database | MySQL |
| Authentication | JWT (jsonwebtoken) |
| Password Hashing | bcryptjs |
| Validation | express-validator |

---

## ✅ Requirements Checklist

- [x] 2 Modules with complete CRUD (Laptops + Users)
- [x] Flutter frontend connected to Node.js REST API
- [x] MySQL database integration
- [x] User Authentication (Signup/Login required)
- [x] Role-Based Access Control (Admin vs User)
- [x] Admin-only CRUD buttons in UI
- [x] JWT token authentication
- [x] Search and filter functionality
- [x] Professional dark-themed UI
- [x] Postman-testable endpoints
- [x] Database schema with seed data
