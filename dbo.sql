-- 1. Önce 'admin' rolü var mı bakalım, yoksa ekleyelim
IF NOT EXISTS (SELECT 1 FROM Roles WHERE RoleName = 'admin')
BEGIN
    INSERT INTO Roles (RoleName) VALUES ('admin');
END;

-- 2. 'admin' rolünün ID'sini dinamik olarak alalım (1 OLMAYABİLİR!)
DECLARE @AdminRoleID INT;
SELECT @AdminRoleID = RoleID FROM Roles WHERE RoleName = 'admin';

-- 3. Eğer bu e-posta ile eski bir kayıt varsa silelim (Temiz başlangıç)
-- Not: Eğer bu kullanıcıya bağlı proje vs. varsa hata verebilir, o durumda DELETE satırını silip UPDATE yapabiliriz.
DELETE FROM Users WHERE Email = 'admin@uni.edu';

-- 4. Kullanıcıyı doğru RoleID ile ekleyelim
INSERT INTO Users (FullName, Email, PasswordHash, RoleID) 
VALUES ('Sistem Yöneticisi', 'admin@uni.edu', '1234', @AdminRoleID);

-- 5. SONUÇ: RoleID'nin kaç olduğunu görelim (Bunu not et!)
SELECT UserID, FullName, Email, PasswordHash, RoleID 
FROM Users 
WHERE Email = 'admin@uni.edu';