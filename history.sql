/* 2025-11-18 21:17:22 [92 ms] */ 
CREATE TABLE Roles (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE
);
/* 2025-11-18 21:19:10 [39 ms] */ 
INSERT INTO Roles (RoleName)
VALUES ('admin'), ('teacher'),('student');
/* 2025-11-18 21:19:18 [7 ms] */ 
SELECT TOP 100 * FROM "Roles";
/* 2025-11-18 21:28:10 [93 ms] */ 
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(256) NOT NULL,
    RoleID INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
    );
/* 2025-11-18 21:33:12 [37 ms] */ 
CREATE TABLE Departments (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL
    );
/* 2025-11-18 21:38:18 [87 ms] */ 
CREATE TABLE Courses (
    CourseID INT IDENTITY(1,1) PRIMARY KEY,
    CourseCode NVARCHAR(20) NOT NULL,
    CourseName NVARCHAR(100) NOT NULL,
    DepartmentID INT NULL,
    Term NVARCHAR(20),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
    );
/* 2025-11-19 19:31:32 [97 ms] */ 
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
/* 2025-11-19 19:36:14 [29 ms] */ 
CREATE TABLE ProjectMembers (
    MemberID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectID INT NOT NULL,
    UserID INT NOT NULL,
    RoleInProject NVARCHAR(50) DEFAULT 'member',
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
/* 2025-11-19 19:41:00 [37 ms] */ 
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
/* 2025-11-19 19:46:28 [42 ms] */ 
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
/* 2025-11-19 19:52:39 [110 ms] */ 
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
/* 2025-11-19 20:06:30 [62 ms] */ 
INSERT INTO "Departments" ("DepartmentName") VALUES
('Bilgisayar Mühendisliği'),
('Elektrik-Elektronik Mühendisliği'),
('Yazılım Mühendisliği');
/* 2025-11-19 20:16:30 [118 ms] */ 
INSERT INTO "Users" ("FullName", "Email", "PasswordHash", "RoleID") VALUES
('Doç. Dr. Durmuş Özdemir', 'durmus.ozdemir@dpu.edu.tr', 'hash123', 2),
('Dr. Ahmet Yılmaz', 'ayilmaz@uni.edu', 'hash123', 2),
('Doç. Dr. Elif Demir', 'edemir@uni.edu', 'hash123', 2),
('Dr. Mehmet Karaca', 'mkaraca@uni.edu', 'hash123', 2),
('Dr. Selin Aksoy', 'saksoy@uni.edu', 'hash123', 2),
('Prof. Dr. Barış Güneş', 'bgunes@uni.edu', 'hash123', 2);
/* 2025-11-19 20:48:48 [52 ms] */ 
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
/* 2025-11-20 13:08:41 [151 ms] */ 
INSERT INTO "Courses" ("CourseCode", "CourseName", "DepartmentID", "Term") VALUES
('CSE305', 'Veri Tabanı Yönetim Sistemleri', 1, '2025 Güz'),
('CSE220', 'Nesne Yönelimli Programlama', 1, '2026 Bahar'),
('CSE480', 'Bitirme Projesi 1', 1, '2025 Güz'),
('YAZ210', 'Web Programlama', 3, '2025 Bahar'),
('EEE101', 'Elektrik Devre Temelleri', 2, '2026 Bahar');
/* 2025-11-20 13:17:26 [80 ms] */ 
INSERT INTO "Projects" ("Title", "Summary", "CreatedBy", "CourseID", "Status") VALUES
('Akademik Proje Yönetim Sistemi', 'Üniversiteler için proje yönetim uygulaması.', 1, 1, 'proposal'),
('Akıllı Ev Kontrol Sistemi', 'Mobil uygulama ile kontrol edilen akıllı ev projesi.', 3, 4, 'development'),
('Görüntü İşleme ile Nesne Tanıma', 'OpenCV kullanılarak nesne tespiti.', 5, 1, 'approved'),
('Online Sınav Sistemi', 'Öğrenciler için online sınav platformu.', 8, 2, 'submitted'),
('E-Ticaret Analiz Platformu', 'Satış verilerini analiz eden web sistemi.', 10, 4, 'reviewed'),
('Robot Kol Kontrolü', 'Arduino ile robotik kol tasarımı.', 12, 5, 'development');
/* 2025-11-20 13:23:10 [59 ms] */ 
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
/* 2025-11-20 13:29:17 [42 ms] */ 
INSERT INTO "ProjectSupervisors" ("ProjectID", "UserID", "Accepted", "FeedbackText") VALUES
(1, 1, 1, 'Proje fikri uygun. Devam edebilirsiniz.'),
(2, 2, 1, 'Geliştirmelere devam.'),
(3, 3, 0, 'Revizyon gerekli.'),
(4, 4, 1, 'Teslim başarılı'),
(5, 5, 1, 'Genel değerlendirme olumlu.'),
(6, 1, 1, 'Robotik kol tasarımı uygun.');
/* 2025-11-20 13:52:41 [114 ms] */ 
INSERT INTO "ProjectDeliverables" ("ProjectID", "FileName", "FilePath", "Version", "UploadedBy") VALUES
(1, 'proje_tasarim.pdf', '/files/p1/v1.pdf', 1, 1),
(2, 'akilli_ev.docx', '/files/p2/v1.docx', 1, 3),
(3, 'opencv_rapor.pdf', '/files/p3/v1.pdf', 1, 5),
(4, 'online_sinav.zip', '/files/p4/v2.pdf', 1, 8),
(5, 'analiz.pdf', '/files/p5/v2.pdf', 2, 10),
(6, 'robot_kol.sch', '/files/p6/v1.sch', 1, 12);
/* 2025-11-20 13:57:56 [37 ms] */ 
INSERT INTO "ProjectReviews" ("ProjectID", "ReviewerID", "Score", "Comment") VALUES
(1, 1, 85, 'Başarılı bir proje.'),
(2, 2, 90, 'Kod yapısı temiz ve düzenli.'),
(3, 3, 70, 'Geliştirilmesi gereken noktalar var.'),
(4, 4, 95, 'Teslim harika.'),
(5, 5, 88, 'Analiz raporu güçlü.'),
(6, 1, 78, 'Robot kol temel işlevleri yerine getiriyor.');
/* 2025-11-20 14:13:03 [36 ms] */ 
INSERT INTO "Departments" ("DepartmentName") VALUES
('Bilgisayar Mühendisliği'),
('Elektrik-Elektronik Mühendisliği'),
('Yazılım Mühendisliği'),
('Makine Mühendisliği'),
('Endüstri Mühendisliği'),
('Yapay Zeka Mühendisliği');
/* 2025-11-20 14:14:08 [24 ms] */ 
INSERT INTO "Departments" ("DepartmentName") VALUES
('Bilgisayar Mühendisliği'),
('Elektrik-Elektronik Mühendisliği'),
('Yazılım Mühendisliği');
/* 2025-11-20 14:15:00 [64 ms] */ 
DELETE FROM "Departments" WHERE "DepartmentID" IN (1010,1009,1008,1007,1006,1005,1004,1003,1002);
/* 2025-11-20 14:18:59 [81 ms] */ 
INSERT INTO "Departments" ("DepartmentName") VALUES
('Makine Mühendisliği'),
('Endüstri Mühendisliği'),
('Yapay Zeka Mühendisliği');
/* 2025-11-20 14:26:16 [44 ms] */ 
INSERT INTO "Users" ("FullName", "Email", "PasswordHash", "RoleID") VALUES
('Doç. Dr. Hakan Kılıç', 'hakan.kilic@uni.edu', 'hash123', 2),
('Dr. Aslı Güner', 'asli.güner@uni.edu', 'hash123', 2),
('Prof. Dr. Cemal Şahin', 'cemal.sahin@uni.edu', 'hash123', 2),
('Dr. Dilan Koç', 'dilan.koc@uni.edu', 'hash123', 2);
/* 2025-11-20 14:35:15 [97 ms] */ 
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
/* 2025-11-20 14:42:26 [36 ms] */ 
INSERT INTO "Courses" ("CourseCode", "CourseName", "DepartmentID", "Term") VALUES
('CSE350', 'Yapay Zeka', 1, '2024 Güz'),
('MECH210', 'Termodinamik', 1011, '2025 Bahar'),
('IND310', 'İş Analizi ve Süreç Yönetimi', 1012, '2025 Güz'),
('AI420', 'Derin Öğrenme', 1013, '2024 Bahar'),
('CSE340', 'Veri Görselleştirme', 1, '2025 Bahar');
/* 2025-11-20 15:05:19 [52 ms] */ 
INSERT INTO "Projects" ("Title", "Summary", "CreatedBy", "CourseID", "Status") VALUES
('Sanayi 4.0 Süreç İzleme Sistemi', 'Fabrika verilerinin IoT sensörlerle izlenmesi.', 7, 3, 'proposal'),
('Mobil Yemekhane Uygulaması', ' Günlük menü, kalori hesabı ve yoğunluk tahmini.', 15, 1, 'development'),
('Drone Tabanlı Yangın Tespiti', 'Termal kamera ile orman yangını tespiti.', 2, 5, 'approved'),
('AI Chatbot Geliştirme', 'Doğal dil işleme tabanlı chatbot.', 1, 11, 'development'),
('3D Model Oluşturma Otomasyonu', 'Yapay zeka ile otomatik 3D model üretimi.', 11, 8, 'proposal'),
('Akıllı Sera Otomasyonu', 'Nem, ışık, sıcaklık kontrol sistemi', 13, 3, 'approved');
/* 2025-11-20 15:16:54 [36 ms] */ 
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
/* 2025-11-20 15:23:51 [42 ms] */ 
INSERT INTO "ProjectSupervisors" ("ProjectID", "UserID", "Accepted", "FeedbackText") VALUES
(17, 2, 1, 'Fikir uygun, analiz bekliyorum.'),
(18, 4, 0, 'Tasarım eksiklikleri mevcut.'),
(19, 5, 1, 'Drone verileri iyi işlenmiş.'),
(20, 6, 1, 'Chatbot yapısı başarılı.'),
(21, 3, 0, 'Model geliştirme dataylı olmalı.'),
(22, 1, 1, 'Tarım otomasyonu etkili görünüyor.');
/* 2025-11-20 15:31:02 [108 ms] */ 
INSERT INTO "ProjectDeliverables" ("ProjectID", "FileName", "FilePath", "Version", "UploadedBy") VALUES
(17, 's4.iot.pdf', '/files/p7/v1,pdf', 1, 7),
(18, 'yemekhane_app.docx', '/files/p8/v1.docx', 1, 15),
(19, 'drone_tespit.pdf', '/files/p9/v1.pdf', 1, 2),
(20, 'chatbot_nlp.zip', '/files/p10/v1.zip', 1, 1),
(21, '3d_model_rapor.pdf', '/files/p11/v1.pdf', 1, 11),
(22, 'sera_kontrol.xlsx', '/files/p12/v1,xlsx', 1, 13);
/* 2025-11-20 15:35:55 [42 ms] */ 
INSERT INTO "ProjectReviews" ("ProjectID", "ReviewerID", "Score", "Comment") VALUES
(17, 1, 82, 'Başlangıç iyi, gelişme gerekiyor.'),
(18, 3, 75, 'Tasarım eksiklikleri var.'),
(19, 6, 92, 'Çok başarılı bir analiz.'),
(20, 2, 88, 'Chatbot cevap tutarlılığı güçlü.'),
(21, 4, 70, '3D model sonuçları yetersiz.'),
(22, 5, 94, 'Sera kontrolü  mükemmel çalışıyor.');
