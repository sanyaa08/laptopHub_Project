-- ================================================
--  LAPTOP HUB DATABASE SCHEMA
--  Run this file to set up the database
-- ================================================

-- Create & use database
CREATE DATABASE IF NOT EXISTS laptop_hub_db;
USE laptop_hub_db;

-- ================================================
-- TABLE: users
-- ================================================
CREATE TABLE IF NOT EXISTS users (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(100)  NOT NULL,
  email       VARCHAR(150)  NOT NULL UNIQUE,
  password    VARCHAR(255)  NOT NULL,
  role        ENUM('user','admin') NOT NULL DEFAULT 'user',
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ================================================
-- TABLE: laptops
-- ================================================
CREATE TABLE IF NOT EXISTS laptops (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  name          VARCHAR(200)  NOT NULL,
  brand         VARCHAR(100)  NOT NULL,
  price         DECIMAL(10,2) NOT NULL,
  image_url     VARCHAR(500),
  processor     VARCHAR(150),
  ram           VARCHAR(50),
  storage       VARCHAR(100),
  display       VARCHAR(100),
  graphics      VARCHAR(150),
  battery       VARCHAR(100),
  weight        VARCHAR(50),
  os            VARCHAR(100),
  description   TEXT,
  stock         INT DEFAULT 0,
  is_featured   BOOLEAN DEFAULT FALSE,
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ================================================
-- TABLE: cart
-- ================================================
CREATE TABLE IF NOT EXISTS cart (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT NOT NULL,
  laptop_id   INT NOT NULL,
  quantity    INT DEFAULT 1,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)   REFERENCES users(id)   ON DELETE CASCADE,
  FOREIGN KEY (laptop_id) REFERENCES laptops(id) ON DELETE CASCADE,
  UNIQUE KEY unique_cart_item (user_id, laptop_id)
);

-- ================================================
-- SEED DATA: Default admin user
-- Password: Admin@123  (bcrypt hashed)
-- ================================================
INSERT INTO users (name, email, password, role) VALUES
('Super Admin', 'admin@laptophub.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi.', 'admin')
ON DUPLICATE KEY UPDATE id=id;

-- NOTE: Replace the hashed password above with a proper bcrypt hash of your password.
-- You can generate it using: require('bcryptjs').hashSync('Admin@123', 10)

-- ================================================
-- SEED DATA: Sample laptops
-- ================================================
INSERT INTO laptops (name, brand, price, image_url, processor, ram, storage, display, graphics, battery, weight, os, description, stock, is_featured) VALUES
('MacBook Pro 16" M3 Pro', 'Apple', 2499.99, 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800', 'Apple M3 Pro (12-core CPU)', '18GB Unified Memory', '512GB SSD', '16.2" Liquid Retina XDR, 3456x2234', 'Apple M3 Pro 18-core GPU', '22 hours', '2.14 kg', 'macOS Sonoma', 'The most powerful MacBook Pro ever. Featuring the M3 Pro chip with incredible performance and battery life. Perfect for professionals who demand the best.', 15, TRUE),

('Dell XPS 15 9530', 'Dell', 1899.99, 'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=800', 'Intel Core i9-13900H (14-core)', '32GB DDR5', '1TB NVMe SSD', '15.6" OLED 3.5K Touch, 3456x2160', 'NVIDIA RTX 4070 8GB', '13 hours', '1.86 kg', 'Windows 11 Pro', 'Stunning OLED display meets premium build quality. The Dell XPS 15 delivers exceptional visuals and performance for creatives and professionals alike.', 20, TRUE),

('ThinkPad X1 Carbon Gen 11', 'Lenovo', 1649.99, 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=800', 'Intel Core i7-1365U (10-core)', '16GB LPDDR5', '512GB SSD', '14" IPS Anti-glare, 1920x1200', 'Intel Iris Xe Graphics', '15 hours', '1.12 kg', 'Windows 11 Pro', 'The legendary business laptop. Ultra-lightweight carbon fiber chassis with military-grade durability, enterprise security features, and outstanding keyboard.', 25, FALSE),

('ASUS ROG Zephyrus G14', 'ASUS', 1499.99, 'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=800', 'AMD Ryzen 9 7940HS (8-core)', '16GB DDR5', '1TB PCIe 4.0 SSD', '14" QHD+ 165Hz, 2560x1600', 'NVIDIA RTX 4060 8GB', '10 hours', '1.65 kg', 'Windows 11 Home', 'The ultimate compact gaming powerhouse. Exceptional AMD performance with discrete NVIDIA graphics in a surprisingly portable 14-inch form factor.', 18, TRUE),

('HP Spectre x360 14', 'HP', 1399.99, 'https://images.unsplash.com/photo-1525547719571-a2d4ac8945e2?w=800', 'Intel Core i7-1355U (10-core)', '16GB LPDDR4x', '512GB NVMe SSD', '13.5" 3K2K OLED Touch, 3000x2000', 'Intel Iris Xe Graphics', '17 hours', '1.36 kg', 'Windows 11 Home', '2-in-1 luxury meets OLED brilliance. Gem-cut design with a gorgeous touch display, Intel Evo certified for responsive performance.', 12, FALSE),

('Microsoft Surface Laptop 5', 'Microsoft', 1299.99, 'https://images.unsplash.com/photo-1588702547919-26089e690ecc?w=800', 'Intel Core i7-1265U (10-core)', '16GB LPDDR5x', '512GB SSD', '13.5" PixelSense Touch, 2256x1504', 'Intel Iris Xe Graphics', '18 hours', '1.27 kg', 'Windows 11 Home', 'Pure elegance with premium Alcantara fabric. Windows 11 optimized performance with a stunning touch display and all-day battery life.', 30, FALSE),

('Acer Swift 5 SF514', 'Acer', 899.99, 'https://images.unsplash.com/photo-1484788984921-03950022c9ef?w=800', 'Intel Core i5-1335U (10-core)', '8GB LPDDR5', '512GB SSD', '14" IPS FHD, 1920x1080', 'Intel Iris Xe Graphics', '12 hours', '0.99 kg', 'Windows 11 Home', 'Ultra-thin, ultra-light and incredibly capable. The Swift 5 is perfect for students and professionals who need portability without sacrifice.', 40, FALSE),

('Razer Blade 15 2023', 'Razer', 2799.99, 'https://images.unsplash.com/photo-1542393545-10f5cde2c810?w=800', 'Intel Core i9-13950HX (24-core)', '32GB DDR5', '1TB PCIe 5.0 SSD', '15.6" QHD 240Hz, 2560x1440', 'NVIDIA RTX 4080 12GB', '8 hours', '2.01 kg', 'Windows 11 Home', 'The most powerful Razer Blade ever built. CNC aluminum chassis houses RTX 4080 graphics and the latest Intel HX processor for extreme gaming and creation.', 8, TRUE);
