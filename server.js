const express = require('express');
const cors = require('cors');
// db.js dosyasından sql nesnesini ve ayarları çekiyoruz
const { sql, config } = require('./db'); 

const app = express();
app.use(cors());
app.use(express.json());

/* -------------------------------------------------------------------------- */
/* 1. VERİTABANI BAĞLANTISINI BAŞLATMA (ÇOK ÖNEMLİ)                           */
/* -------------------------------------------------------------------------- */
async function connectToDB() {
    try {
        // Bu komut global bir bağlantı havuzu (pool) oluşturur.
        // Artık uygulamanın her yerinde 'sql' nesnesini kullanabilirsin.
        await sql.connect(config);
        console.log("✅ Veritabanına başarıyla bağlanıldı!");
    } catch (err) {
        console.error("❌ Veritabanı bağlantı hatası:", err);
    }
}

// Sunucu başlarken bağlantıyı da başlat
connectToDB();

/* -------------------------------------------------------------------------- */
/* 2. LOGIN ENDPOINT (Hatasız Versiyon)                                       */
/* -------------------------------------------------------------------------- */
app.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try {
        // HATA ÇÖZÜMÜ:
        // Global bağlantı üzerinden yeni bir istek (Request) nesnesi oluşturuyoruz.
        // Eğer yukarıdaki connectToDB çalıştıysa, bu kod hata vermez.
        const request = new sql.Request();

        // Parametreleri güvenli şekilde tanımlıyoruz (SQL Injection'a karşı)
        request.input('email', sql.NVarChar, email);
        request.input('password', sql.NVarChar, password);

        // Sorguyu çalıştırıyoruz
        const result = await request.query('SELECT * FROM Users WHERE Email = @email AND PasswordHash = @password');

        if (result.recordset.length > 0) {
            const user = result.recordset[0];
            
            // Şifreyi güvenlik gereği frontend'e yollamıyoruz
            delete user.PasswordHash; 
            
            res.json({ success: true, user: user });
        } else {
            res.status(401).json({ success: false, message: "Hatalı e-posta veya şifre!" });
        }

    } catch (err) {
        console.error("Login işlemi sırasında hata:", err);
        // Hata detayını terminale yazdırır, kullanıcıya genel mesaj döner
        res.status(500).json({ success: false, message: "Sunucu hatası: Bağlantı veya sorgu sorunu." });
    }
});

// ... Buradan sonra diğer app.get kodların (projects, users vs.) gelebilir ...

// Sunucuyu dinlemeye başla
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`🚀 Sunucu http://localhost:${PORT} adresinde çalışıyor.`);
});

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

/* 🚀 PROJELERİ GETİREN ENDPOINT (GÜNCELLENMİŞ - JOIN İLE) */
app.get('/projects', async (req, res) => {
    try {
        /* Projects tablosunu Users (Öğrenci Adı için) ve 
           Courses (Ders Adı için) tablolarıyla birleştiriyoruz.
        */
        const query = `
            SELECT 
                p.ProjectID,
                p.Title,
                p.Summary,
                p.Status,
                p.CourseID,
                c.CourseName,      -- Dersin Adı artık gelecek
                c.CourseCode,      -- Dersin Kodu (CSE305 vb.)
                u.FullName AS StudentName  -- Öğrencinin Adı
            FROM Projects p
            LEFT JOIN Courses c ON p.CourseID = c.CourseID
            LEFT JOIN Users u ON p.CreatedBy = u.UserID
        `;
        
        const result = await sql.query(query);
        res.json(result.recordset);
    } catch (err) {
        console.error("Projeler çekilirken hata:", err);
        res.status(500).send(err.message);
    }
});

// 3.Bölümleri Listeleme
app.get('/departments', async (req, res) => {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request().query('SELECT * FROM Departments');
        res.json(result.recordset);
    } catch (err) {
        console.log("Projeler çekilirken hata oluştu!",err);
        res.status(500).send("Sunucu hatası: " + err.message);
    }
});

// 4. Değerlendirme Kriterlerini Listeleme
app.get('/reviews', async (req,res) => {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request().query(`
            SELECT 
                r.ReviewID,
                r.Score,
                r.Comment,
                r.ReviewedAt,
                p.Title AS ProjectTitle,
                u.FullName AS ReviewerName
            FROM ProjectReviews r
            JOIN Projects p ON r.ProjectID = p.ProjectID
            JOIN Users u ON r.ReviewerID = u.UserID
            ORDER BY r.ReviewedAt DESC
        `);
        res.json(result.recordset);
    } catch (err) {
        console.log("Değerlendirme çekilirken hata oluştu!",err);
        res.status(500).send("Sunucu hatası: " + err.message);
    }
});
/* -------------------------------------------------------------------------- */
/* 5. DERSLERİ GETİR (Courses)                                                */
/* -------------------------------------------------------------------------- */
app.get('/courses', async (req, res) => {
    try {
        const result = await sql.query("SELECT * FROM Courses ORDER BY Term DESC");
        res.json(result.recordset);
    } catch (err) {
        res.status(500).send(err.message);
    }
});

/* -------------------------------------------------------------------------- */
/* 6. PROJE DOSYALARINI GETİR (ProjectDeliverables - JOIN)                    */
/* -------------------------------------------------------------------------- */
app.get('/files', async (req, res) => {
    try {
        // Dosyanın hangi projeye ait olduğunu ve kimin yüklediğini isimle getiriyoruz
        const query = `
            SELECT 
                d.FileName,
                d.FilePath,
                d.Version,
                d.UploadedAt,
                p.Title AS ProjectTitle,
                u.FullName AS UploaderName
            FROM ProjectDeliverables d
            JOIN Projects p ON d.ProjectID = p.ProjectID
            JOIN Users u ON d.UploadedBy = u.UserID
            ORDER BY d.UploadedAt DESC
        `;
        const result = await sql.query(query);
        res.json(result.recordset);
    } catch (err) {
        res.status(500).send(err.message);
    }
});

/* -------------------------------------------------------------------------- */
/* 7. DANIŞMAN GÖRÜŞLERİNİ GETİR (ProjectSupervisors - JOIN)                  */
/* -------------------------------------------------------------------------- */
app.get('/supervisors', async (req, res) => {
    try {
        // Danışmanın adı, projenin adı, onay durumu ve yorum metni
        const query = `
            SELECT 
                ps.FeedbackText,
                ps.Accepted,
                ps.AssignedAt,
                p.Title AS ProjectTitle,
                u.FullName AS SupervisorName
            FROM ProjectSupervisors ps
            JOIN Projects p ON ps.ProjectID = p.ProjectID
            JOIN Users u ON ps.UserID = u.UserID
        `;
        const result = await sql.query(query);
        res.json(result.recordset);
    } catch (err) {
        res.status(500).send(err.message);
    }
});
/* -------------------------------------------------------------------------- */
/* 8. PROJE GÜNCELLEME (Status ve Summary)                                    */
/* -------------------------------------------------------------------------- */
app.put('/projects/:id', async (req, res) => {
    const { id } = req.params;
    const { status, summary } = req.body; // Frontend'den gelecek veriler

    try {
        const request = new sql.Request();
        request.input('id', sql.Int, id);
        request.input('status', sql.NVarChar, status);
        request.input('summary', sql.NVarChar, summary);

        await request.query(`
            UPDATE Projects 
            SET Status = @status, Summary = @summary, UpdatedAt = GETDATE()
            WHERE ProjectID = @id
        `);
        
        res.json({ success: true, message: "Proje güncellendi." });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
});

/* -------------------------------------------------------------------------- */
/* 9. PROJE SİLME                                                             */
/* -------------------------------------------------------------------------- */
app.delete('/projects/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const request = new sql.Request();
        request.input('id', sql.Int, id);

        // Önce bağlı tablolardaki verileri temizlememiz gerekir (Foreign Key hatası almamak için)
        // Gerçek senaryoda "Soft Delete" (IsDeleted = 1) yapılır ama burada direkt siliyoruz.
        await request.query('DELETE FROM ProjectDeliverables WHERE ProjectID = @id');
        await request.query('DELETE FROM ProjectMembers WHERE ProjectID = @id');
        await request.query('DELETE FROM ProjectSupervisors WHERE ProjectID = @id');
        await request.query('DELETE FROM ProjectReviews WHERE ProjectID = @id');
        
        // En son ana projeyi siliyoruz
        await request.query('DELETE FROM Projects WHERE ProjectID = @id');

        res.json({ success: true, message: "Proje silindi." });
    } catch (err) {
        console.log(err);
        res.status(500).json({ success: false, message: "Silme hatası: " + err.message });
    }
});

/* -------------------------------------------------------------------------- */
/* 10. TEK BİR PROJEYE AİT DOSYALARI GETİR                                    */
/* -------------------------------------------------------------------------- */
app.get('/project-files/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const request = new sql.Request();
        request.input('id', sql.Int, id);
        const result = await request.query('SELECT * FROM ProjectDeliverables WHERE ProjectID = @id');
        res.json(result.recordset);
    } catch (err) {
        res.status(500).send(err.message);
    }
});

/* -------------------------------------------------------------------------- */
/* 11. PROJENİN DANIŞMANINI BUL (Yetki Kontrolü İçin)                         */
/* -------------------------------------------------------------------------- */
app.get('/project-supervisor/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const request = new sql.Request();
        request.input('id', sql.Int, id);
        // Bu projeye atanmış danışman(lar)ın UserID'sini getirir
        const result = await request.query('SELECT UserID FROM ProjectSupervisors WHERE ProjectID = @id');
        res.json(result.recordset);
    } catch (err) {
        res.status(500).send(err.message);
    }
});
/* -------------------------------------------------------------------------- */
/* ADMIN GÜNCELLEME İŞLEMLERİ (PUT)                                           */
/* -------------------------------------------------------------------------- */

// 1. KULLANICI GÜNCELLEME
app.put('/users/:id', async (req, res) => {
    const { id } = req.params;
    const { FullName, Email, RoleID } = req.body;
    try {
        const request = new sql.Request();
        request.input('id', sql.Int, id);
        request.input('name', sql.NVarChar, FullName);
        request.input('email', sql.NVarChar, Email);
        request.input('role', sql.Int, RoleID);

        await request.query(`UPDATE Users SET FullName=@name, Email=@email, RoleID=@role WHERE UserID=@id`);
        res.json({ success: true });
    } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

// 2. BÖLÜM GÜNCELLEME
app.put('/departments/:id', async (req, res) => {
    const { id } = req.params;
    const { DepartmentName } = req.body;
    try {
        const request = new sql.Request();
        request.input('id', sql.Int, id);
        request.input('name', sql.NVarChar, DepartmentName);

        await request.query(`UPDATE Departments SET DepartmentName=@name WHERE DepartmentID=@id`);
        res.json({ success: true });
    } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

// 3. DERS GÜNCELLEME
app.put('/courses/:id', async (req, res) => {
    const { id } = req.params;
    const { CourseName, CourseCode, Term } = req.body;
    try {
        const request = new sql.Request();
        request.input('id', sql.Int, id);
        request.input('name', sql.NVarChar, CourseName);
        request.input('code', sql.NVarChar, CourseCode);
        request.input('term', sql.NVarChar, Term);

        await request.query(`UPDATE Courses SET CourseName=@name, CourseCode=@code, Term=@term WHERE CourseID=@id`);
        res.json({ success: true });
    } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});
/* -------------------------------------------------------------------------- */
/* ADMIN EKLEME İŞLEMLERİ (POST)                                              */
/* -------------------------------------------------------------------------- */

// 1. YENİ KULLANICI EKLE
app.post('/users', async (req, res) => {
    const { FullName, Email, RoleID, Password } = req.body;
    try {
        const request = new sql.Request();
        request.input('name', sql.NVarChar, FullName);
        request.input('email', sql.NVarChar, Email);
        request.input('pass', sql.NVarChar, Password || '1234'); // Şifre gelmezse varsayılan 1234 olsun
        request.input('role', sql.Int, RoleID);

        await request.query(`INSERT INTO Users (FullName, Email, PasswordHash, RoleID) VALUES (@name, @email, @pass, @role)`);
        res.json({ success: true, message: "Kullanıcı oluşturuldu." });
    } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

// 2. YENİ BÖLÜM EKLE
app.post('/departments', async (req, res) => {
    const { DepartmentName } = req.body;
    try {
        const request = new sql.Request();
        request.input('name', sql.NVarChar, DepartmentName);

        await request.query(`INSERT INTO Departments (DepartmentName) VALUES (@name)`);
        res.json({ success: true, message: "Bölüm oluşturuldu." });
    } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

// 3. YENİ DERS EKLE
app.post('/courses', async (req, res) => {
    const { CourseName, CourseCode, Term } = req.body; // DepartmentID eklenebilir ama şimdilik basit tutalım
    try {
        const request = new sql.Request();
        request.input('name', sql.NVarChar, CourseName);
        request.input('code', sql.NVarChar, CourseCode);
        request.input('term', sql.NVarChar, Term);

        // Not: DepartmentID null olabilir veya arayüzden seçtirilebilir. Şimdilik NULL gidiyor.
        await request.query(`INSERT INTO Courses (CourseName, CourseCode, Term) VALUES (@name, @code, @term)`);
        res.json({ success: true, message: "Ders oluşturuldu." });
    } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

// 4. YENİ PROJE EKLE (Admin manuel eklemek isterse)
app.post('/projects', async (req, res) => {
    // Bu biraz kompleks çünkü CreatedBy ve CourseID zorunlu. 
    // Admin panelinden bunları ID olarak girmemiz gerekecek.
    const { Title, Summary } = req.body;
    try {
        const request = new sql.Request();
        request.input('title', sql.NVarChar, Title);
        request.input('summary', sql.NVarChar, Summary);
        
        // Admin eklediği için varsayılan değerler atayalım (Örn: Admin ID=1, Ders ID=1)
        // İleride arayüzden seçtirmeli yapabiliriz.
        await request.query(`INSERT INTO Projects (Title, Summary, CreatedBy, CourseID, Status) VALUES (@title, @summary, 1, 1, 'proposal')`);
        
        res.json({ success: true, message: "Proje taslağı oluşturuldu." });
    } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

app.listen(3000, () => console.log("Server running on port 3000"));