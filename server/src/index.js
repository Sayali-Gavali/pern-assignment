
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';

import auth from './routes/auth.js';
import products from './routes/products.js';
import enquiries from './routes/enquiries.js';
import quotations from './routes/quotations.js';
import orders from './routes/orders.js';

import { pool } from './utils/db.js';

dotenv.config();

// Check required environment variables
if (!process.env.JWT_SECRET) {
    throw new Error(
        'JWT_SECRET is required. Please configure it in your .env file.'
    );
}

const app = express();

// Middleware
app.use(helmet());

// CORS Configuration
const allowedOrigins = [
    'http://localhost:5173',
    'http://127.0.0.1:5173',
    'http://10.18.95.232:5173'
];

app.use(
    cors({
        origin: (origin, callback) => {
            // Allow requests without an Origin header, such as Postman
            if (!origin || allowedOrigins.includes(origin)) {
                return callback(null, true);
            }

            return callback(new Error('Origin not allowed by CORS'));
        },
        methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
        allowedHeaders: ['Content-Type', 'Authorization']
    })
);

app.use(express.json({ limit: '1mb' }));

// Authentication routes
app.use(
    '/auth',
    rateLimit({
        windowMs: 15 * 60 * 1000,
        max: 100
    }),
    auth
);

// Health check
app.get('/health', async (req, res) => {
    try {
        await pool.query('SELECT 1');

        res.json({
            status: 'ok',
            database: 'connected'
        });
    } catch (error) {
        console.error(
            'Database health check failed:',
            error.message
        );

        res.status(503).json({
            status: 'error',
            database: 'disconnected'
        });
    }
});

// ERP routes
app.use('/products', products);
app.use('/enquiries', enquiries);
app.use('/quotations', quotations);
app.use('/sales-orders', orders);

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        error: 'Route not found'
    });
});

// Error handler
app.use((err, req, res, next) => {
    console.error('Server error:', err);

    res.status(err.status || 500).json({
        error: err.message || 'Internal server error'
    });
});

// Start server
const port = Number(process.env.PORT) || 5000;

app.listen(port, () => {
    console.log(`API listening on port ${port}`);
});
