CREATE TABLE Roles (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE
);

INSERT INTO Roles (RoleName) VALUES 
('admin'), ('teacher'),('student');

CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(256) NOT NULL,
    RoleID INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
    );

CREATE TABLE Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL
    );

CREATE TABLE Courses (
    CourseID INT IDENTITY(1,1) PRIMARY KEY,
    CourseCode NVARCHAR(20) NOT NULL,
    CourseName NVARCHAR(100) NOT NULL,
    DepartmentID INT NULL,
    Term NVARCHAR(20),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
    );
CREATE TABLE Projects (
    ProjectID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    Summary NVARCHAR(MAX),
    CreatedBy INT NOT NULL,
    CourseID INT NOT NULL,
    Status NVARCHAR(50) DEFAULT 'proposal',
    CreatedAt DATETIME DEFAULT GETDATE(),
    UpdatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);

CREATE TABLE ProjectMembers (
    MemberID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectID INT NOT NULL,
    UserID INT NOT NULL,
    RoleInProject NVARCHAR(50) DEFAULT 'member',
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE ProjectSupervisors (
    SupervisorID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectID INT NOT NULL,
    UserID INT NOT NULL,
    AssignedAt DATETIME DEFAULT GETDATE(),
    Accepted BIT DEFAULT 0,
    FeedbackText NVARCHAR(Max),
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

CREATE TABLE ProjectDeliverables (
    DeliverableID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectID INT NOT NULL,
    FileName NVARCHAR(255) NOT NULL,
    FilePath NVARCHAR(500) NOT NULL,
    Version INT NOT NULL DEFAULT 1,
    UploadedBy INT NOT NULL,
    UploadedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID),
    FOREIGN KEY (UploadedBy) REFERENCES Users(UserID)
);

CREATE Table ProjectReviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectID INT NOT NULL,
    ReviewerID INT NOT NULL,
    Score INT CHECK (Score >= 0 AND Score <= 100),
    Comment NVARCHAR(MAX),
    ReviewedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID),
    FOREIGN KEY (ReviewerID) REFERENCES Users(UserID)
);

INSERT INTO "Departments" ("DepartmentName") VALUES
('Bilgisayar Mühendisliği'),
('Elektrik-Elektronik Mühendisliği'),
('Yazılım Mühendisliği');

INSERT INTO "Users" ("FullName", "Email", "PasswordHash", "RoleID") VALUES
('Doç. Dr. Durmuş Özdemir', 'durmus.ozdemir@dpu.edu.tr', 'hash123', 2),
('Dr. Ahmet Yılmaz', 'ayilmaz@uni.edu', 'hash123', 2),
('Doç. Dr. Elif Demir', 'edemir@uni.edu', 'hash123', 2),
('Dr. Mehmet Karaca', 'mkaraca@uni.edu', 'hash123', 2),
('Dr. Selin Aksoy', 'saksoy@uni.edu', 'hash123', 2),
('Prof. Dr. Barış Güneş', 'bgunes@uni.edu', 'hash123', 2);

INSERT INTO "Users" ("FullName", "Email", "PasswordHash", "RoleID") VALUES
('Caner Çakal', 'caner.cakal@ogr.dpu.edu.tr', 'hash123', 3),
('Mustafa Yıldız', 'mustafa.yildiz@ogr.dpu.edu.tr', 'hash123', 3),
('Melike Acar', 'melike.acar@ogr.dpu.edu.tr', 'hash123', 3),
('Beytullah Atasoy', 'beytullah.atasoy@ogr.dpu.edu.tr', 'hash123', 3),
('Mert Yıldırım', 'mert.yildirim@uni.edu', 'hash123', 3),
('Ayşe Kurt', 'ayse.kurt@uni.edu', 'hash123', 3),
('Ali Demir', 'ali.demir@uni.edu', 'hash123', 3),
('Fatma Kara', 'fatma.kara@uni.edu', 'hash123', 3),
('Berkay Tunç', 'berkay.tunc@uni.edu', 'hash123', 3),
('Elif Uçar', 'elif.ucar@uni.edu', 'hash123', 3),
('İrem Akın', 'irem.akin@uni.edu', 'hash123', 3),
('Yusuf Irmak', 'yusuf.irmak@uni.edu', 'hash123', 3),
('Sena Taş', 'sena.tas@uni.edu', 'hash123', 3),
('Deniz Şahin', 'deniz.sahin@uni.edu', 'hash123', 3),
('Ege Aydın', 'ege.aydin@uni.edu', 'hash123', 3),
('Ada Soylu', 'ada.soylu@uni.edu', 'hash123', 3),
('Cem Arslan', 'cem.arslan@uni.edu', 'hash123', 3),
('Ebru Sürer', 'ebru.surer@uni.edu', 'hash123', 3),
('Tolga Bal', 'tolga.bal@uni.edu', 'hash123', 3),
('Tuğba Er', 'tugba.er@uni.edu', 'hash123', 3),
('Burak Yaman', 'burak.yaman@uni.edu', 'hash123', 3),
('Hale Erdem', 'hale.erdem@uni.edu', 'hash123', 3),
('Gamze Çetin', 'gamze.cetin@uni.edu', 'hash123', 3),
('Yusuf Korkmaz', 'yusuf.korkmaz@uni.edu', 'hash123', 3);

INSERT INTO "Courses" ("CourseCode", "CourseName", "DepartmentID", "Term") VALUES
('CSE305', 'Veri Tabanı Yönetim Sistemleri', 1, '2025 Güz'),
('CSE220', 'Nesne Yönelimli Programlama', 1, '2026 Bahar'),
('CSE480', 'Bitirme Projesi 1', 1, '2025 Güz'),
('YAZ210', 'Web Programlama', 3, '2025 Bahar'),
('EEE101', 'Elektrik Devre Temelleri', 2, '2026 Bahar');

INSERT INTO "Projects" ("Title", "Summary", "CreatedBy", "CourseID", "Status") VALUES
('Akademik Proje Yönetim Sistemi', 'Üniversiteler için proje yönetim uygulaması.', 1, 1, 'proposal'),
('Akıllı Ev Kontrol Sistemi', 'Mobil uygulama ile kontrol edilen akıllı ev projesi.', 3, 4, 'development'),
('Görüntü İşleme ile Nesne Tanıma', 'OpenCV kullanılarak nesne tespiti.', 5, 1, 'approved'),
('Online Sınav Sistemi', 'Öğrenciler için online sınav platformu.', 8, 2, 'submitted'),
('E-Ticaret Analiz Platformu', 'Satış verilerini analiz eden web sistemi.', 10, 4, 'reviewed'),
('Robot Kol Kontrolü', 'Arduino ile robotik kol tasarımı.', 12, 5, 'development');

INSERT INTO "ProjectMembers" ("ProjectID", "UserID", "RoleInProject") VALUES
(1, 1, 'owner'),
(1, 2, 'member'),

(2, 3, 'owner'),
(2, 4, 'member'),

(3, 5, 'owner'),
(3, 6, 'member'),

(4, 7, 'owner'),
(4, 8, 'member'),

(5, 9, 'owner'),
(5, 10, 'member'),

(6, 11, 'owner'),
(6, 12, 'member');

INSERT INTO "ProjectSupervisors" ("ProjectID", "UserID", "Accepted", "FeedbackText") VALUES
(1, 1, 1, 'Proje fikri uygun. Devam edebilirsiniz.'),
(2, 2, 1, 'Geliştirmelere devam.'),
(3, 3, 0, 'Revizyon gerekli.'),
(4, 4, 1, 'Teslim başarılı'),
(5, 5, 1, 'Genel değerlendirme olumlu.'),
(6, 1, 1, 'Robotik kol tasarımı uygun.');

INSERT INTO "ProjectDeliverables" ("ProjectID", "FileName", "FilePath", "Version", "UploadedBy") VALUES
(1, 'proje_tasarim.pdf', '/files/p1/v1.pdf', 1, 1),
(2, 'akilli_ev.docx', '/files/p2/v1.docx', 1, 3),
(3, 'opencv_rapor.pdf', '/files/p3/v1.pdf', 1, 5),
(4, 'online_sinav.zip', '/files/p4/v2.pdf', 1, 8),
(5, 'analiz.pdf', '/files/p5/v2.pdf', 2, 10),
(6, 'robot_kol.sch', '/files/p6/v1.sch', 1, 12);

INSERT INTO "ProjectReviews" ("ProjectID", "ReviewerID", "Score", "Comment") VALUES
(1, 1, 85, 'Başarılı bir proje.'),
(2, 2, 90, 'Kod yapısı temiz ve düzenli.'),
(3, 3, 70, 'Geliştirilmesi gereken noktalar var.'),
(4, 4, 95, 'Teslim harika.'),
(5, 5, 88, 'Analiz raporu güçlü.'),
(6, 1, 78, 'Robot kol temel işlevleri yerine getiriyor.');

INSERT INTO "Departments" ("DepartmentName") VALUES
('Makine Mühendisliği'),
('Endüstri Mühendisliği'),
('Yapay Zeka Mühendisliği');

INSERT INTO "Users" ("FullName", "Email", "PasswordHash", "RoleID") VALUES
('Doç. Dr. Hakan Kılıç', 'hakan.kilic@uni.edu', 'hash123', 2),
('Dr. Aslı Güner', 'asli.güner@uni.edu', 'hash123', 2),
('Prof. Dr. Cemal Şahin', 'cemal.sahin@uni.edu', 'hash123', 2),
('Dr. Dilan Koç', 'dilan.koc@uni.edu', 'hash123', 2);

INSERT INTO "Users" ("FullName", "Email", "PasswordHash", "RoleID") VALUES
('Kerem Doğan', 'kerem.dogan@uni.edu', 'hash123', 3),
('Nazlı Aksoy', 'nazli.aksoy@uni.edu', 'hash123', 3),
('Sude Aydın', 'sude.aydin@uni.edu', 'hash123', 3),
('Onur Şahin', 'onur.sahin@uni.edu', 'hash123', 3),
('Zehra Kaplan', 'zehra.kaplan@uni.edu', 'hash123', 3),
('Emir Çetin', 'emir.cetin@uni.edu', 'hash123', 3),
('Mina Taş', 'mina.tas@uni.edu', 'hash123', 3),
('Kaan Uçar', 'kaan.ucar@uni.edu', 'hash123', 3),
('Ekin Demirci', 'ekin.demirci@uni.edu', 'hash123', 3),
('Arda Karadeniz', 'arda.karadeniz@uni.edu', 'hash123', 3);

INSERT INTO "Courses" ("CourseCode", "CourseName", "DepartmentID", "Term") VALUES
('CSE350', 'Yapay Zeka', 1, '2024 Güz'),
('MECH210', 'Termodinamik', 1011, '2025 Bahar'),
('IND310', 'İş Analizi ve Süreç Yönetimi', 1012, '2025 Güz'),
('AI420', 'Derin Öğrenme', 1013, '2024 Bahar'),
('CSE340', 'Veri Görselleştirme', 1, '2025 Bahar');

INSERT INTO "Projects" ("Title", "Summary", "CreatedBy", "CourseID", "Status") VALUES
('Sanayi 4.0 Süreç İzleme Sistemi', 'Fabrika verilerinin IoT sensörlerle izlenmesi.', 7, 3, 'proposal'),
('Mobil Yemekhane Uygulaması', ' Günlük menü, kalori hesabı ve yoğunluk tahmini.', 15, 1, 'development'),
('Drone Tabanlı Yangın Tespiti', 'Termal kamera ile orman yangını tespiti.', 2, 5, 'approved'),
('AI Chatbot Geliştirme', 'Doğal dil işleme tabanlı chatbot.', 1, 11, 'development'),
('3D Model Oluşturma Otomasyonu', 'Yapay zeka ile otomatik 3D model üretimi.', 11, 8, 'proposal'),
('Akıllı Sera Otomasyonu', 'Nem, ışık, sıcaklık kontrol sistemi', 13, 3, 'approved');

INSERT INTO "ProjectMembers" ("ProjectID", "UserID", "RoleInProject") VALUES
(17, 7, 'owner'),
(17, 8, 'member'),

(18, 15, 'owner'),
(18, 16, 'owner'),

(19, 2, 'owner'),
(19, 25, 'member'),

(20, 1, 'owner'),
(20, 22, 'member'),

(21, 11, 'owner'),
(21, 26, 'member'),

(22, 13, 'owner'),
(22, 27, 'member');

INSERT INTO "ProjectSupervisors" ("ProjectID", "UserID", "Accepted", "FeedbackText") VALUES
(17, 2, 1, 'Fikir uygun, analiz bekliyorum.'),
(18, 4, 0, 'Tasarım eksiklikleri mevcut.'),
(19, 5, 1, 'Drone verileri iyi işlenmiş.'),
(20, 6, 1, 'Chatbot yapısı başarılı.'),
(21, 3, 0, 'Model geliştirme dataylı olmalı.'),
(22, 1, 1, 'Tarım otomasyonu etkili görünüyor.');

INSERT INTO "ProjectDeliverables" ("ProjectID", "FileName", "FilePath", "Version", "UploadedBy") VALUES
(17, 's4.iot.pdf', '/files/p7/v1,pdf', 1, 7),
(18, 'yemekhane_app.docx', '/files/p8/v1.docx', 1, 15),
(19, 'drone_tespit.pdf', '/files/p9/v1.pdf', 1, 2),
(20, 'chatbot_nlp.zip', '/files/p10/v1.zip', 1, 1),
(21, '3d_model_rapor.pdf', '/files/p11/v1.pdf', 1, 11),
(22, 'sera_kontrol.xlsx', '/files/p12/v1,xlsx', 1, 13);

INSERT INTO "ProjectReviews" ("ProjectID", "ReviewerID", "Score", "Comment") VALUES
(17, 1, 82, 'Başlangıç iyi, gelişme gerekiyor.'),
(18, 3, 75, 'Tasarım eksiklikleri var.'),
(19, 6, 92, 'Çok başarılı bir analiz.'),
(20, 2, 88, 'Chatbot cevap tutarlılığı güçlü.'),
(21, 4, 70, '3D model sonuçları yetersiz.'),
(22, 5, 94, 'Sera kontrolü  mükemmel çalışıyor.');

UPDATE "Projects" SET "CreatedBy" = 7 WHERE "ProjectID" = 1;
UPDATE "Projects" SET "CreatedBy" = 25 WHERE "ProjectID" = 2;
UPDATE "Projects" SET "CreatedBy" = 19 WHERE "ProjectID" = 3;
UPDATE "Projects" SET "CreatedBy" = 13 WHERE "ProjectID" = 4;
UPDATE "Projects" SET "CreatedBy" = 29 WHERE "ProjectID" = 17;
UPDATE "Projects" SET "CreatedBy" = 9 WHERE "ProjectID" = 19;
UPDATE "Projects" SET "CreatedBy" = 17 WHERE "ProjectID" = 20;
UPDATE "Projects" SET "CreatedBy" = 1008 WHERE "ProjectID" = 20;
UPDATE "Projects" SET "CreatedBy" = 1014 WHERE "ProjectID" = 19;
UPDATE "Projects" SET "CourseID" = 10 WHERE "ProjectID" = 22;
UPDATE "ProjectReviews" SET "ReviewerID" = 1003 WHERE "ReviewID" = 6;
UPDATE "ProjectReviews" SET "ReviewerID" = 1002 WHERE "ReviewID" = 16;
UPDATE "ProjectReviews" SET "ReviewerID" = 1004 WHERE "ReviewID" = 17;
UPDATE "ProjectReviews" SET "ReviewerID" = 1005 WHERE "ReviewID" = 18;
UPDATE "ProjectMembers" SET "UserID" = 7 WHERE "MemberID" = 2;
UPDATE "ProjectMembers" SET "UserID" = 14 WHERE "MemberID" = 3;
UPDATE "ProjectMembers" SET "UserID" = 17 WHERE "MemberID" = 4;
UPDATE "ProjectMembers" SET "UserID" = 18 WHERE "MemberID" = 5;
UPDATE "ProjectMembers" SET "UserID" = 21 WHERE "MemberID" = 13;
UPDATE "ProjectMembers" SET "UserID" = 23 WHERE "MemberID" = 14;
UPDATE "ProjectDeliverables" SET "UploadedBy" = 7 WHERE "DeliverableID" = 1;
UPDATE "ProjectDeliverables" SET "UploadedBy" = 25 WHERE "DeliverableID" = 2;
UPDATE "ProjectDeliverables" SET "UploadedBy" = 19 WHERE "DeliverableID" = 3;
UPDATE "ProjectDeliverables" SET "UploadedBy" = 29 WHERE "DeliverableID" = 7;
UPDATE "ProjectDeliverables" SET "UploadedBy" = 1014 WHERE "DeliverableID" = 9;
UPDATE "ProjectDeliverables" SET "UploadedBy" = 1008 WHERE "DeliverableID" = 10;

CREATE TRIGGER trg_OnlyStudentCanInsertProject
ON Projects
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM Inserted i
        JOIN Users u
            ON i.CreatedBy = u.UserID
        WHERE u.RoleID <> 3    
    )
    BEGIN
        RAISERROR ('Sadece öğrenciler proje ekleyebilir!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

CREATE TRIGGER trg_OnlyTeacherCanInsertComment
ON ProjectReviews
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM Inserted i
        JOIN Users u
            ON i.ReviewerID = u.UserID
        WHERE u.RoleID <> 2    
    )
    BEGIN
        RAISERROR ('Sadece öğretmenler yorum yapabilir!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

INSERT INTO "Projects" ("Title", "Summary", "CreatedBy", "CourseID") VALUES
('Test Projesi - Öğrenci ekledi', 'Bu proje, sadece öğrenci rolündeki kullanıcıların proje ekleyebilme yetkisini test etmek amacıyla oluşturulmuştur.', 7, 1);

INSERT INTO "Projects" ("Title", "Summary", "CreatedBy", "CourseID") VALUES
('Test Projesi - Öğretmen ekledi', 'Açıklama', 1, 1);
-- Bu ekleme, tetikleyici nedeniyle başarısız olmalıdır.

INSERT INTO "ProjectReviews" ("ProjectID", "ReviewerID", "Score", "Comment") VALUES
(1, 1, 90, 'Bu yorum, sadece öğretmen rolündeki kullanıcıların yorum yapabilme yetkisini test etmek amacıyla oluşturulmuştur.');

INSERT INTO "ProjectReviews" ("ProjectID", "ReviewerID", "Score", "Comment") VALUES
(1, 7, 100, 'Bu yorum, öğrenci rolündeki bir kullanıcı tarafından yapılmaya çalışılmıştır.');
-- Bu ekleme, tetikleyici nedeniyle başarısız olmalıdır.


SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'; 
--Bütün tabloları listeleme

SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Users';
--Users tablosunun şemasını görüntüleme


