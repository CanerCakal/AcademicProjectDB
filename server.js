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

// Sunucuyu dinlemeye başla
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`🚀 Sunucu http://localhost:${PORT} adresinde çalışıyor.`);
});

// 1. MEVCUT KULLANICI LİSTELEME
app.get('/users', async (req, res) => {
    try {
        const pool = await sql.connect(config);
        // SORGUSU GÜNCELLENDİ: Departments tablosu ile LEFT JOIN yapıldı
        const result = await pool.request().query(`
            SELECT u.*, d.DepartmentName 
            FROM Users u 
            LEFT JOIN Departments d ON u.DepartmentID = d.DepartmentID
        `);
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
                p.CreatedBy,       -- YENİ EKLENEN: Projenin sahibi kim? (Buton kontrolü için şart)
                c.CourseName,
                c.CourseCode,
                u.FullName AS StudentName
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
        console.log("Projeler çekilirken hata oluştu!", err);
        res.status(500).send("Sunucu hatası: " + err.message);
    }
});

// 4. Değerlendirme Kriterlerini Listeleme
app.get('/reviews', async (req, res) => {
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
        console.log("Değerlendirme çekilirken hata oluştu!", err);
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
// 8. PROJE GÜNCELLEME (Title, Status ve Summary)
app.put('/projects/:id', async (req, res) => {
    const { id } = req.params;
    // Frontend'den Title da gelebilir artık
    const { status, summary, title } = req.body;

    try {
        const request = new sql.Request();
        request.input('id', sql.Int, id);
        request.input('status', sql.NVarChar, status);
        request.input('summary', sql.NVarChar, summary);
        request.input('title', sql.NVarChar, title); // Yeni input

        // SQL Sorgusuna Title'ı da ekledik
        await request.query(`
            UPDATE Projects 
            SET Status = @status, Summary = @summary, Title = ISNULL(@title, Title), UpdatedAt = GETDATE()
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
    // DEĞİŞİKLİK BURADA: DepartmentID eklendi
    const { FullName, Email, RoleID, DepartmentID } = req.body;
    try {
        const request = new sql.Request();
        request.input('id', sql.Int, id);
        request.input('name', sql.NVarChar, FullName);
        request.input('email', sql.NVarChar, Email);
        request.input('role', sql.Int, RoleID);
        // YENİ INPUT: Eğer DepartmentID boş gelirse (örn: Admin için) NULL kaydet
        request.input('deptId', sql.Int, DepartmentID || null);

        // SORGUSU GÜNCELLENDİ
        await request.query(`UPDATE Users SET FullName=@name, Email=@email, RoleID=@role, DepartmentID=@deptId WHERE UserID=@id`);
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

/* server.js dosyası */

// 3. DERS GÜNCELLEME (GÜVENLİ YENİ HALİ)
app.put('/courses/:id', async (req, res) => {
    const { id } = req.params;
    // Frontend'den gelen actionUserId bilgisini burada karşılıyoruz
    const { CourseName, CourseCode, Term, actionUserId } = req.body;

    try {
        const request = new sql.Request();

        // 1. İşlemi yapan hocanın/adminin bilgilerini çekiyoruz
        request.input('uid', sql.Int, actionUserId);
        const userCheck = await request.query(`SELECT RoleID, DepartmentID FROM Users WHERE UserID = @uid`);

        if (userCheck.recordset.length === 0) {
            return res.status(404).json({ success: false, message: "Kullanıcı bulunamadı." });
        }

        const user = userCheck.recordset[0];

        // 2. Eğer ADMIN (RoleID=1) değilse, yetki kontrolü yapıyoruz
        if (user.RoleID !== 1) {

            // Güncellenmek istenen dersin Bölüm ID'sini buluyoruz
            // Not: Yeni bir request nesnesi oluşturmak daha güvenlidir
            const requestCourse = new sql.Request();
            requestCourse.input('cid', sql.Int, id);
            const courseCheck = await requestCourse.query(`SELECT DepartmentID FROM Courses WHERE CourseID = @cid`);

            if (courseCheck.recordset.length === 0) {
                return res.status(404).json({ success: false, message: "Ders bulunamadı." });
            }

            const course = courseCheck.recordset[0];

            // KONTROL: Hocanın bölümü ile Dersin bölümü aynı mı?
            if (user.DepartmentID !== course.DepartmentID) {
                return res.status(403).json({
                    success: false,
                    message: "Yetkisiz İşlem! Sadece kendi bölümünüzdeki dersleri düzenleyebilirsiniz."
                });
            }
        }

        // 3. Her şey uygunsa güncellemeyi yapıyoruz
        const updateRequest = new sql.Request();
        updateRequest.input('id', sql.Int, id);
        updateRequest.input('name', sql.NVarChar, CourseName);
        updateRequest.input('code', sql.NVarChar, CourseCode);
        updateRequest.input('term', sql.NVarChar, Term);

        await updateRequest.query(`UPDATE Courses SET CourseName=@name, CourseCode=@code, Term=@term WHERE CourseID=@id`);

        res.json({ success: true, message: "Ders başarıyla güncellendi." });

    } catch (err) {
        console.error("Hata:", err); // Hata ayıklama için konsola yazdır
        res.status(500).json({ success: false, message: err.message });
    }
});
/* -------------------------------------------------------------------------- */
/* ADMIN EKLEME İŞLEMLERİ (POST)                                              */
/* -------------------------------------------------------------------------- */
// 1. YENİ KULLANICI EKLE
app.post('/users', async (req, res) => {
    // DEĞİŞİKLİK BURADA: DepartmentID parametresi eklendi
    const { FullName, Email, RoleID, Password, DepartmentID } = req.body;
    try {
        const request = new sql.Request();
        request.input('name', sql.NVarChar, FullName);
        request.input('email', sql.NVarChar, Email);
        request.input('pass', sql.NVarChar, Password || '1234');
        request.input('role', sql.Int, RoleID);
        // YENİ INPUT
        request.input('deptId', sql.Int, DepartmentID || null);

        // SORGU GÜNCELLENDİ: INSERT içine DepartmentID eklendi
        await request.query(`INSERT INTO Users (FullName, Email, PasswordHash, RoleID, DepartmentID) VALUES (@name, @email, @pass, @role, @deptId)`);
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

// 3. YENİ DERS EKLE (Bölüm ve Hoca ID Destekli)
app.post('/courses', async (req, res) => {
    const { CourseName, CourseCode, Term, DepartmentID, InstructorID } = req.body;

    try {
        const request = new sql.Request();
        request.input('name', sql.NVarChar, CourseName);
        request.input('code', sql.NVarChar, CourseCode);
        request.input('term', sql.NVarChar, Term);
        request.input('deptId', sql.Int, DepartmentID || null);
        request.input('instId', sql.Int, InstructorID || null); // YENİ: Hoca ID

        await request.query(`
            INSERT INTO Courses (CourseName, CourseCode, Term, DepartmentID, InstructorID) 
            VALUES (@name, @code, @term, @deptId, @instId)
        `);

        res.json({ success: true, message: "Ders oluşturuldu ve hoca atandı." });
    } catch (err) { res.status(500).json({ success: false, message: err.message }); }
});

// 4. YENİ PROJE EKLE (OTOMATİK DANIŞMAN ATAMALI)
app.post('/projects', async (req, res) => {
    const { Title, Summary, CourseID, CreatedBy } = req.body;

    // Transaction (İşlem Bütünlüğü) kullanarak hata olursa yarım kayıt oluşmasını engelliyoruz.
    const transaction = new sql.Transaction();

    try {
        await transaction.begin();

        // 1. Önce bu dersin hocası kim, onu bulalım
        const requestCourse = new sql.Request(transaction);
        requestCourse.input('courseId', sql.Int, CourseID);
        const courseResult = await requestCourse.query("SELECT InstructorID FROM Courses WHERE CourseID = @courseId");

        if (courseResult.recordset.length === 0 || !courseResult.recordset[0].InstructorID) {
            // Eğer dersin hocası atanmamışsa işlem iptal
            throw new Error("Seçilen dersin bir danışman hocası (InstructorID) tanımlanmamış! Önce Admin panelinden derse hoca atayın.");
        }

        const instructorId = courseResult.recordset[0].InstructorID;

        // 2. Projeyi Kaydet (Ve oluşan yeni Proje ID'sini al)
        const requestProj = new sql.Request(transaction);
        requestProj.input('title', sql.NVarChar, Title);
        requestProj.input('summary', sql.NVarChar, Summary);
        requestProj.input('courseId', sql.Int, CourseID);
        requestProj.input('studentId', sql.Int, CreatedBy);

        // INSERT işlemi sonuna 'SELECT SCOPE_IDENTITY()' ekleyerek yeni ID'yi alıyoruz
        const insertResult = await requestProj.query(`
            INSERT INTO Projects (Title, Summary, CreatedBy, CourseID, Status) 
            VALUES (@title, @summary, @studentId, @courseId, 'proposal');
            SELECT SCOPE_IDENTITY() AS NewProjectID;
        `);

        const newProjectId = insertResult.recordset[0].NewProjectID;

        // 3. Projeyi Otomatik Olarak Dersin Hocasına Ata (ProjectSupervisors tablosuna ekle)
        const requestSup = new sql.Request(transaction);
        requestSup.input('pId', sql.Int, newProjectId);
        requestSup.input('uId', sql.Int, instructorId); // Dersin Hocası

        await requestSup.query(`
            INSERT INTO ProjectSupervisors (ProjectID, UserID, Accepted, FeedbackText)
            VALUES (@pId, @uId, 0, 'Otomatik atandı. Onay bekleniyor.')
        `);

        // Hata yoksa işlemi onayla
        await transaction.commit();

        res.json({ success: true, message: "Proje oluşturuldu ve dersin danışmanına atandı." });

    } catch (err) {
        // Hata varsa yapılan her şeyi geri al (Rollback)
        if (transaction._aborted === false) {
            await transaction.rollback();
        }
        console.error("Proje ekleme hatası:", err);
        res.status(500).json({ success: false, message: "İşlem başarısız: " + err.message });
    }
});

/* -------------------------------------------------------------------------- */
/* ADMIN SİLME İŞLEMLERİ (DELETE) - YENİ EKLENECEK KISIMLAR                   */
/* -------------------------------------------------------------------------- */

// 1. KULLANICI SİLME
app.delete('/users/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const request = new sql.Request();
        request.input('id', sql.Int, id);

        // DİKKAT: Eğer bu kullanıcının projesi, yorumu vs. varsa SQL hata verir (Foreign Key).
        // Önce bağlı verilerin temizlenmesi gerekir. Şimdilik direkt silmeyi deniyoruz.
        await request.query('DELETE FROM Users WHERE UserID = @id');

        res.json({ success: true, message: "Kullanıcı silindi." });
    } catch (err) {
        // SQL Hatası (Bağlı veri varsa) döner
        res.status(500).json({ success: false, message: "Silinemedi! (Kullanıcıya bağlı proje veya veri olabilir): " + err.message });
    }
});

// 2. BÖLÜM SİLME
app.delete('/departments/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const request = new sql.Request();
        request.input('id', sql.Int, id);

        await request.query('DELETE FROM Departments WHERE DepartmentID = @id');

        res.json({ success: true, message: "Bölüm silindi." });
    } catch (err) {
        res.status(500).json({ success: false, message: "Silinemedi! (Bu bölüme bağlı dersler olabilir): " + err.message });
    }
});

// 3. DERS SİLME
app.delete('/courses/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const request = new sql.Request();
        request.input('id', sql.Int, id);

        await request.query('DELETE FROM Courses WHERE CourseID = @id');

        res.json({ success: true, message: "Ders silindi." });
    } catch (err) {
        res.status(500).json({ success: false, message: "Silinemedi! (Bu derse bağlı projeler olabilir): " + err.message });
    }
});

// MÜSAİT ÖĞRETMENLERİ GETİR (Hicbir derse atanmamış olanlar)
app.get('/available-instructors', async (req, res) => {
    try {
        const pool = await sql.connect(config);
        const result = await pool.request().query(`
            SELECT UserID, FullName 
            FROM Users 
            WHERE RoleID = 2 -- Sadece Öğretmenler
            AND UserID NOT IN (SELECT DISTINCT InstructorID FROM Courses WHERE InstructorID IS NOT NULL) -- Dersi Olmayanlar
        `);
        res.json(result.recordset);
    } catch (err) {
        res.status(500).send(err.message);
    }
});

// 12. YENİ DOSYA YÜKLEME (Simülasyon)
app.post('/files', async (req, res) => {
    const { ProjectID, FileName, UploadedBy } = req.body;

    try {
        const request = new sql.Request();
        request.input('pid', sql.Int, ProjectID);
        request.input('fname', sql.NVarChar, FileName);
        request.input('uid', sql.Int, UploadedBy);

        // Gerçek bir upload olmadığı için sanal bir yol oluşturuyoruz
        const fakePath = `/uploads/projects/${ProjectID}/${FileName}`;
        request.input('fpath', sql.NVarChar, fakePath);

        await request.query(`
            INSERT INTO ProjectDeliverables (ProjectID, FileName, FilePath, Version, UploadedBy) 
            VALUES (@pid, @fname, @fpath, 1, @uid)
        `);

        res.json({ success: true, message: "Dosya başarıyla yüklendi." });
    } catch (err) {
        res.status(500).json({ success: false, message: err.message });
    }
});

app.listen(3000, () => console.log("Server running on port 3000"));