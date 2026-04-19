-- 1. Veritabanını Oluştur
CREATE DATABASE BLM4522;
GO

USE BLM4522;
GO

-- 2. Müşteriler Tablosu
CREATE TABLE Musteriler (
    MusteriID INT PRIMARY KEY IDENTITY(1,1),
    Ad NVARCHAR(50),
    Soyad NVARCHAR(50),
    Email NVARCHAR(100),
    KayitTarihi DATETIME DEFAULT GETDATE()
);
GO

-- 3. Müşteri Verilerini Ekle
DECLARE @i INT = 1;
WHILE @i <= 1000000
BEGIN
    INSERT INTO Musteriler (Ad, Soyad, Email)
    VALUES (
        'MusteriAd' + CAST(@i AS NVARCHAR(10)), 
        'Soyad' + CAST(@i AS NVARCHAR(10)), 
        'user' + CAST(@i AS NVARCHAR(10)) + '@mail.com'
    );
    SET @i = @i + 1;
END;
GO