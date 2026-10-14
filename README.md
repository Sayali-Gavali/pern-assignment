# ERP Sales, Quotation, Inventory & Dispatch (MySQL version)

This project implements the assessment workflow: Customer Enquiry → Quotation → Sales Order → Inventory Reservation → Dispatch.

> **Assessment note:** the original brief explicitly asks for PostgreSQL. This version has been converted to MySQL as requested. Confirm that the assessor accepts MySQL before submitting.

## Stack
- MySQL 8.0+ with InnoDB; MySQL Workbench for database management
- Node.js 20+, Express, `mysql2/promise`
- React + Vite
- JWT authentication, bcrypt password hashing, server-side role authorization

## 1. Install prerequisites
Install Node.js LTS, MySQL Server 8.0+ and MySQL Workbench. During MySQL Server setup, remember the password for user `root`.

## 2. Create database in MySQL Workbench
1. Open MySQL Workbench and open your local connection (usually localhost:3306).
2. Enter the MySQL root password.
3. Choose **File → Open SQL Script** and open `server/sql/schema.sql`.
4. Click the lightning-bolt Execute button. The script creates `pern_erp` and all tables. **Warning:** schema.sql drops/recreates project tables to make setup repeatable; do not run it against a database containing data you need to keep.
5. Open `server/sql/seed.sql` and execute it to add six sample products and starting inventory.

## 3. Configure backend
Copy `server/.env.example` to `server/.env` and set `DB_PASSWORD` to your MySQL password and `JWT_SECRET` to a long random secret. Keep the other defaults if MySQL runs locally on port 3306.

In VS Code terminal:
```powershell
cd server
npm install
npm run seed
npm run dev
```
`npm run seed` creates the demo users and seeds products/inventory. If you already ran `seed.sql` in Workbench, that is okay; product seeds use duplicate-safe inserts.

Demo accounts: `admin@example.com` / `Admin@12345`; `sales@example.com` / `Sales@12345`. Change them before any real deployment.

## 4. Start frontend
Open a second VS Code terminal:
```powershell
cd client
npm install
npm run dev
```
Open http://localhost:5173. Backend defaults to http://localhost:5000.

## 5. Demo workflow
1. Sign in as Sales User or Admin.
2. Create an enquiry with customer information and a product.
3. Create a quotation; totals are calculated on the server.
4. Mark the quotation SENT, then ACCEPTED.
5. Convert the accepted quotation into a sales order. A unique database constraint prevents duplicate orders from the same quotation.
6. Sign in as Admin and confirm the order; stock is reserved inside a transaction with row locks.
7. Dispatch the confirmed order; physical and reserved stock both decrease. Admin can cancel pending/confirmed orders; confirmed-order cancellation releases reserved stock.

## 6. Checks before submission
- Check `http://localhost:5000/health` returns `{"status":"ok","database":"connected"}`.
- Test both roles and all workflow statuses.
- Verify a quotation in DRAFT/REJECTED cannot convert, the same quotation cannot create two orders, stock cannot be over-reserved, and Sales User cannot confirm or dispatch orders.
- Build frontend with `cd client; npm run build`.
- This is an assessment starter and should be fully exercised on your local MySQL instance; do not claim tests passed unless you ran them.

## Documentation
- SQL schema: `server/sql/schema.sql`
- Sample products/inventory: `server/sql/seed.sql`
- API overview: `docs/API.md`
- ER diagram: `docs/ERD.mmd`
