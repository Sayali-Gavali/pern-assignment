# API overview
Base URL: `http://localhost:5000`

Send `Authorization: Bearer <token>` on all protected routes.

| Method | Endpoint | Access | Purpose |
|---|---|---|---|
| POST | `/auth/login` | Public | Login and receive JWT |
| GET | `/products` | Authenticated | Product/inventory availability |
| PATCH | `/products/:id/inventory` | Admin | Update physical quantity without going below reserved quantity |
| GET/POST | `/enquiries` | Authenticated / Admin or Sales | List or create enquiry and customer |
| GET/POST | `/quotations` | Authenticated / Admin or Sales | List/create quotation; backend computes totals |
| PATCH | `/quotations/:id/status` | Admin or Sales | SENT, ACCEPTED, REJECTED |
| POST | `/quotations/:id/convert` | Admin or Sales | Convert accepted quotation once |
| GET | `/sales-orders` | Authenticated | List orders |
| POST | `/sales-orders/:id/confirm` | Admin | Reserve inventory atomically |
| POST | `/sales-orders/:id/dispatch` | Admin | Dispatch and decrement physical + reserved quantities |
| GET | `/health` | Public | Health check |

## Demo workflow
1. Login with the seeded admin or sales user.
2. Create an enquiry (select a seeded product).
3. Create a quotation against that enquiry; the server computes line and grand totals.
4. Mark quotation ACCEPTED, then convert it to a sales order.
5. As admin, confirm the order. MySQL/InnoDB transaction + `FOR UPDATE` row locks protect stock reservation from simultaneous requests.
6. Dispatch the confirmed order with vehicle and driver details. Physical and reserved quantities both decrease.

## Important
This compact assessment starter supports one line item per UI-created enquiry/quotation, while the relational schema and API support multiple items. Expand the UI to add multiple lines if you have time. Add real integration tests with an isolated MySQL database before submission.

Additional endpoint: `POST /sales-orders/:id/cancel` (Admin) releases reserved stock when cancelling a confirmed order.
