const express = require('express');
const cors = require('cors');
const { sql, config } = require('./db');

const app = express();
app.use(cors());
app.use(express.json());

// 1. MEVCUT KULLANICI LİSTELEME (Burası zaten vardı)
app.get('/users', async (req, res) => {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request().query('SELECT * FROM Users');
        res.json(result.recordset);
    } catch (err) {
        console.log(err);
        res.status(500).send(err);
    }
});

// 2. YENİ EKLENEN PROJE LİSTELEME (Aynı yapı kullanıldı)
app.get('/projects', async (req, res) => {
    try {
        const pool = await sql.connect(config);
        
        // SQL Sorgusu: ID'leri isimlerle değiştirmek için JOIN kullandık
        const result = await pool.request().query(`
            SELECT 
                p.ProjectID,
                p.Title,
                p.Summary,
                p.Status,
                u.FullName AS StudentName,
                c.CourseName
            FROM Projects p
            JOIN Users u ON p.CreatedBy = u.UserID
            JOIN Courses c ON p.CourseID = c.CourseID
            ORDER BY p.CreatedAt DESC
        `);
        
        res.json(result.recordset);
        
    } catch (err) {
        console.log("Proje çekme hatası:", err);
        res.status(500).send(err);
    }
});

app.listen(3000, () => console.log("Server running on port 3000"));