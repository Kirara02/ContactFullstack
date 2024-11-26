const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
const port = 3000;

const pool = new Pool({
    user: "postgres",
    host: "localhost",
    database: "contacts",
    password: "root",
    port: 5432
});

app.use(cors());
app.use(express.json());

// Middleware untuk validasi input
const validateContact = (req, res, next) => {
    const { name, phone, email, address } = req.body;
    if (!name || !phone || !email) {
        return res.status(400).json({ message: 'Name, phone, and email are required.' });
    }
    next();
};

// Endpoint untuk CRUD operations
// Create Contact
app.post('/contacts', validateContact, async (req, res) => {
    const { name, phone, email, address } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO contacts (name, phone, email, address) VALUES ($1, $2, $3, $4) RETURNING *',
            [name, phone, email, address || null] // Address boleh null
        );
        res.json(result.rows[0]);
    } catch (error) {
        if (error.code === '23505') {
            // Unique constraint violation error
            return res.status(400).json({ message: 'Email must be unique.' });
        }
        res.status(500).send(error.message);
    }
});

// Get All Contacts
app.get('/contacts', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM contacts');
        res.json(result.rows);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// Get Contact by ID
app.get('/contacts/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const result = await pool.query('SELECT * FROM contacts WHERE id = $1', [id]);
        res.json(result.rows[0]);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

// Update Contact
app.put('/contacts/:id', validateContact, async (req, res) => {
    const { id } = req.params;
    const { name, phone, email, address } = req.body;
    try {
        const result = await pool.query(
            'UPDATE contacts SET name = $1, phone = $2, email = $3, address = $4 WHERE id = $5 RETURNING *',
            [name, phone, email, address || null, id] // Address boleh null
        );
        res.json(result.rows[0]);
    } catch (error) {
        if (error.code === '23505') {
            // Unique constraint violation error
            return res.status(400).json({ message: 'Email must be unique.' });
        }
        res.status(500).send(error.message);
    }
});

// Delete Contact
app.delete('/contacts/:id', async (req, res) => {
    const { id } = req.params;
    try {
        await pool.query('DELETE FROM contacts WHERE id = $1', [id]);
        res.sendStatus(204);
    } catch (error) {
        res.status(500).send(error.message);
    }
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
