CREATE DATABASE IF NOT EXISTS pern_erp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE pern_erp;
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS dispatch_items; DROP TABLE IF EXISTS dispatches; DROP TABLE IF EXISTS sales_order_items; DROP TABLE IF EXISTS sales_orders; DROP TABLE IF EXISTS quotation_items; DROP TABLE IF EXISTS quotations; DROP TABLE IF EXISTS enquiry_items; DROP TABLE IF EXISTS enquiries; DROP TABLE IF EXISTS inventory; DROP TABLE IF EXISTS products; DROP TABLE IF EXISTS customers; DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS=1;
CREATE TABLE users (id CHAR(36) PRIMARY KEY, name VARCHAR(120) NOT NULL, email VARCHAR(190) NOT NULL UNIQUE, password_hash VARCHAR(255) NOT NULL, role ENUM('ADMIN','SALES_USER') NOT NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB;
CREATE TABLE customers (id CHAR(36) PRIMARY KEY, company_name VARCHAR(180) NOT NULL, contact_person VARCHAR(120) NOT NULL, mobile VARCHAR(30) NOT NULL, email VARCHAR(190), city VARCHAR(100) NOT NULL, created_by CHAR(36), created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(created_by) REFERENCES users(id)) ENGINE=InnoDB;
CREATE TABLE products (id CHAR(36) PRIMARY KEY, product_code VARCHAR(40) NOT NULL UNIQUE, product_name VARCHAR(180) NOT NULL, category VARCHAR(100) NOT NULL, unit VARCHAR(20) NOT NULL DEFAULT 'pcs', base_price DECIMAL(12,2) NOT NULL CHECK(base_price>=0), active BOOLEAN NOT NULL DEFAULT TRUE) ENGINE=InnoDB;

CREATE TABLE inventory (
    product_id CHAR(36) PRIMARY KEY,
    physical_qty INT NOT NULL DEFAULT 0,
    reserved_qty INT NOT NULL DEFAULT 0,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_physical_qty
        CHECK (physical_qty >= 0),
    CONSTRAINT chk_reserved_qty
        CHECK (reserved_qty >= 0 AND reserved_qty <= physical_qty),
    FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB;


CREATE TABLE enquiries (id CHAR(36) PRIMARY KEY, enquiry_number VARCHAR(50) NOT NULL UNIQUE, customer_id CHAR(36) NOT NULL, enquiry_date DATE NOT NULL DEFAULT (CURRENT_DATE), required_date DATE, notes TEXT, status ENUM('NEW','QUOTED','WON','LOST') NOT NULL DEFAULT 'NEW', created_by CHAR(36), created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(customer_id) REFERENCES customers(id), FOREIGN KEY(created_by) REFERENCES users(id), INDEX idx_enquiries_customer(customer_id)) ENGINE=InnoDB;
CREATE TABLE enquiry_items (id CHAR(36) PRIMARY KEY, enquiry_id CHAR(36) NOT NULL, product_id CHAR(36) NOT NULL, quantity INT NOT NULL CHECK(quantity>0), FOREIGN KEY(enquiry_id) REFERENCES enquiries(id) ON DELETE CASCADE, FOREIGN KEY(product_id) REFERENCES products(id)) ENGINE=InnoDB;
CREATE TABLE quotations (id CHAR(36) PRIMARY KEY, quotation_number VARCHAR(50) NOT NULL UNIQUE, enquiry_id CHAR(36) NOT NULL, valid_until DATE, status ENUM('DRAFT','SENT','ACCEPTED','REJECTED') NOT NULL DEFAULT 'DRAFT', subtotal DECIMAL(14,2) NOT NULL DEFAULT 0, discount_total DECIMAL(14,2) NOT NULL DEFAULT 0, gst_total DECIMAL(14,2) NOT NULL DEFAULT 0, grand_total DECIMAL(14,2) NOT NULL DEFAULT 0, created_by CHAR(36), created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(enquiry_id) REFERENCES enquiries(id), FOREIGN KEY(created_by) REFERENCES users(id), INDEX idx_quotations_enquiry(enquiry_id)) ENGINE=InnoDB;
CREATE TABLE quotation_items (id CHAR(36) PRIMARY KEY, quotation_id CHAR(36) NOT NULL, product_id CHAR(36) NOT NULL, quantity INT NOT NULL CHECK(quantity>0), unit_price DECIMAL(12,2) NOT NULL CHECK(unit_price>=0), discount_pct DECIMAL(5,2) NOT NULL DEFAULT 0 CHECK(discount_pct BETWEEN 0 AND 100), gst_pct DECIMAL(5,2) NOT NULL DEFAULT 18 CHECK(gst_pct BETWEEN 0 AND 100), line_amount DECIMAL(14,2) NOT NULL CHECK(line_amount>=0), FOREIGN KEY(quotation_id) REFERENCES quotations(id) ON DELETE CASCADE, FOREIGN KEY(product_id) REFERENCES products(id)) ENGINE=InnoDB;
CREATE TABLE sales_orders (id CHAR(36) PRIMARY KEY, order_number VARCHAR(50) NOT NULL UNIQUE, quotation_id CHAR(36) NOT NULL UNIQUE, customer_id CHAR(36) NOT NULL, order_date DATE NOT NULL DEFAULT (CURRENT_DATE), status ENUM('PENDING','CONFIRMED','DISPATCHED','CANCELLED') NOT NULL DEFAULT 'PENDING', total_amount DECIMAL(14,2) NOT NULL CHECK(total_amount>=0), created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(quotation_id) REFERENCES quotations(id), FOREIGN KEY(customer_id) REFERENCES customers(id), INDEX idx_orders_status(status)) ENGINE=InnoDB;
CREATE TABLE sales_order_items (id CHAR(36) PRIMARY KEY, sales_order_id CHAR(36) NOT NULL, product_id CHAR(36) NOT NULL, quantity INT NOT NULL CHECK(quantity>0), unit_price DECIMAL(12,2) NOT NULL CHECK(unit_price>=0), FOREIGN KEY(sales_order_id) REFERENCES sales_orders(id) ON DELETE CASCADE, FOREIGN KEY(product_id) REFERENCES products(id)) ENGINE=InnoDB;
CREATE TABLE dispatches (id CHAR(36) PRIMARY KEY, dispatch_number VARCHAR(50) NOT NULL UNIQUE, sales_order_id CHAR(36) NOT NULL UNIQUE, dispatch_date DATE NOT NULL DEFAULT (CURRENT_DATE), vehicle_number VARCHAR(40) NOT NULL, driver_name VARCHAR(120) NOT NULL, created_by CHAR(36), created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(sales_order_id) REFERENCES sales_orders(id), FOREIGN KEY(created_by) REFERENCES users(id)) ENGINE=InnoDB;
CREATE TABLE dispatch_items (id CHAR(36) PRIMARY KEY, dispatch_id CHAR(36) NOT NULL, product_id CHAR(36) NOT NULL, quantity INT NOT NULL CHECK(quantity>0), FOREIGN KEY(dispatch_id) REFERENCES dispatches(id) ON DELETE CASCADE, FOREIGN KEY(product_id) REFERENCES products(id)) ENGINE=InnoDB;
