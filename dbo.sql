ALTER TRIGGER trg_OnlyStudentCanInsertProject
ON Projects
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Kuralı Şöyle Değiştiriyoruz:
    -- Ekleyen kişinin RoleID'si 3 (Öğrenci) DEĞİLSE VE 1 (Admin) DEĞİLSE engelle.
    IF EXISTS (
        SELECT 1
        FROM Inserted i
        JOIN Users u ON i.CreatedBy = u.UserID
        WHERE u.RoleID NOT IN (3, 1) -- 3: Öğrenci, 1: Admin
    )
    BEGIN
        RAISERROR ('Sadece öğrenciler ve yöneticiler proje ekleyebilir!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
-- 1. Users tablosuna DepartmentID sütunu ekle
ALTER TABLE Users ADD DepartmentID INT NULL;

-- 2. Bu sütunu Departments tablosuna bağla (Foreign Key)
ALTER TABLE Users ADD CONSTRAINT FK_Users_Departments FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID);

-- 3. Mevcut öğretmenleri geçici olarak bir bölüme ata (Örn: ID'si 1 olan bölüme)
-- Bunu yapmazsak uygulamada hata alabiliriz. Daha sonra admin panelinden düzeltebilirsin.
UPDATE Users SET DepartmentID = 1 WHERE RoleID = 2;

-- 1. Courses tablosuna 'InstructorID' sütunu ekle
ALTER TABLE Courses ADD InstructorID INT NULL;

-- 2. Bu sütunu Users tablosuna bağla (Sadece hocalar olacağı için Users'a gider)
ALTER TABLE Courses ADD CONSTRAINT FK_Courses_Instructor FOREIGN KEY (InstructorID) REFERENCES Users(UserID);

-- 3. ÖRNEK VERİ GÜNCELLEME (Burası önemli!)
-- VTYS dersini (CourseCode: CSE305) Durmuş Özdemir'e (UserID: 1 varsayıyorum, sen kendi DB'ne göre kontrol et) atayalım.
-- Eğer Durmuş Hoca'nın ID'si farklıysa (örn: 5 ise) aşağıdaki '1' yerine '5' yaz.
UPDATE Courses SET InstructorID = 1 WHERE CourseCode = 'CSE305';

-- Diğer derslere de rastgele hoca atayalım ki sistem boş kalmasın (ID'si 2, 4, 5 olan hocalar gibi)
UPDATE Courses SET InstructorID = 2 WHERE InstructorID IS NULL;