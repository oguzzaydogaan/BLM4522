-- Erişim Yönetimi - Kullanıcı, Rol ve İzin Yapılandırması
USE master;
GO

-- ============================================================
-- 1. Login ve User Oluşturma
-- ============================================================
CREATE LOGIN BankaAdmin     WITH PASSWORD = '1234';
CREATE LOGIN BankaOkuma     WITH PASSWORD = '1234';
CREATE LOGIN BankaVeriGiris WITH PASSWORD = '1234';
CREATE LOGIN BankaMudur     WITH PASSWORD = '1234';
GO

USE BLM4522_Proje3;
GO

CREATE USER BankaAdmin     FOR LOGIN BankaAdmin;
CREATE USER BankaOkuma     FOR LOGIN BankaOkuma;
CREATE USER BankaVeriGiris FOR LOGIN BankaVeriGiris;
CREATE USER BankaMudur     FOR LOGIN BankaMudur;
GO

-- ============================================================
-- 2. Rol Atama ve Yetkilendirme
-- ============================================================

-- BankaAdmin: tam yetki
ALTER ROLE db_owner ADD MEMBER BankaAdmin;

-- BankaOkuma: sadece okuma
ALTER ROLE db_datareader ADD MEMBER BankaOkuma;

-- BankaVeriGiris: INSERT/UPDATE var, DELETE yok
GRANT INSERT, UPDATE ON dbo.Musteriler TO BankaVeriGiris;
GRANT INSERT, UPDATE ON dbo.Hesaplar   TO BankaVeriGiris;
GRANT INSERT, UPDATE ON dbo.Islemler   TO BankaVeriGiris;
DENY  DELETE         ON dbo.Musteriler TO BankaVeriGiris;
DENY  DELETE         ON dbo.Hesaplar   TO BankaVeriGiris;
DENY  DELETE         ON dbo.Islemler   TO BankaVeriGiris;

-- BankaMudur: tabloları okuyabilir ama hassas kolonlara erişemez
GRANT SELECT ON dbo.Musteriler TO BankaMudur;
GRANT SELECT ON dbo.Hesaplar   TO BankaMudur;
GRANT SELECT ON dbo.Islemler   TO BankaMudur;
-- TCNO hassas kolonu Müdür'den gizle
DENY  SELECT ON dbo.Musteriler(TCNO)    TO BankaMudur;
-- Bakiye kolonunu Müdür'den gizle
DENY  SELECT ON dbo.Hesaplar(Bakiye)    TO BankaMudur;
GO


EXECUTE AS USER = 'BankaMudur';
SELECT MusteriID, Ad, TCNO FROM Musteriler;
SELECT MusteriID, Ad FROM Musteriler;
SELECT * FROM Islemler;

EXECUTE AS USER = 'BankaOkuma';
SELECT MusteriID, Ad, TCNO FROM Musteriler;
DELETE FROM Musteriler WHERE MusteriID = 1;

EXECUTE AS USER = 'BankaVeriGiris';
SELECT * FROM Musteriler;
INSERT INTO Musteriler (Ad, Soyad, TCNO, Email, Telefon, DogumTarihi) VALUES ('Ahmet', 'Yılmaz', '12345678901', 'ahmet@test.com', '555-1234', '1980-01-01');

DELETE FROM Musteriler WHERE MusteriID = 101;

REVERT;
GO

-- ============================================================
-- TEMİZLİK
-- ============================================================
 USE BLM4522_Proje3;
 DROP USER BankaAdmin;
 DROP USER BankaOkuma;
 DROP USER BankaVeriGiris;
 DROP USER BankaMudur;
 GO
 USE master;
 DROP LOGIN BankaAdmin;
 DROP LOGIN BankaOkuma;
 DROP LOGIN BankaVeriGiris;
 DROP LOGIN BankaMudur;
 GO