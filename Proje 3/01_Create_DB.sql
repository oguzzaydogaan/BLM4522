CREATE DATABASE BLM4522_Proje3;
GO

USE BLM4522_Proje3;
GO

-- Müşteriler Tablosu
CREATE TABLE Musteriler (
    MusteriID   INT PRIMARY KEY IDENTITY(1,1),
    Ad          NVARCHAR(50)  NOT NULL,
    Soyad       NVARCHAR(50)  NOT NULL,
    TCNO        CHAR(11)      NOT NULL UNIQUE,
    Email       NVARCHAR(100),
    Telefon     NVARCHAR(15),
    DogumTarihi DATE
);
GO

-- Hesaplar Tablosu
CREATE TABLE Hesaplar (
    HesapID      INT PRIMARY KEY IDENTITY(1,1),
    MusteriID    INT NOT NULL REFERENCES Musteriler(MusteriID),
    IBAN         NVARCHAR(26) NOT NULL UNIQUE,
    HesapTipi    NVARCHAR(20) NOT NULL DEFAULT 'Vadesiz',
    Bakiye       DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    AcilisTarihi DATETIME DEFAULT GETDATE()
);
GO

-- İşlemler Tablosu
CREATE TABLE Islemler (
    IslemID     INT PRIMARY KEY IDENTITY(1,1),
    HesapID     INT NOT NULL REFERENCES Hesaplar(HesapID),
    IslemTipi   NVARCHAR(20) NOT NULL,
    Tutar       DECIMAL(15,2) NOT NULL,
    IslemTarihi DATETIME DEFAULT GETDATE(),
    Aciklama    NVARCHAR(200)
);
GO

-- Örnek Müşteri Verisi
DECLARE @i INT = 1;
WHILE @i <= 100
BEGIN
    INSERT INTO Musteriler (Ad, Soyad, TCNO, Email, Telefon, DogumTarihi)
    VALUES (
        'Musteri' + CAST(@i AS NVARCHAR(5)),
        'Soyad'   + CAST(@i AS NVARCHAR(5)),
        RIGHT('00000000000' + CAST(10000000000 + @i AS NVARCHAR(11)), 11),
        'musteri' + CAST(@i AS NVARCHAR(5)) + '@banka.com',
        '0555' + RIGHT('0000000' + CAST(@i AS NVARCHAR(7)), 7),
        DATEADD(YEAR, -((@i % 40) + 20), GETDATE())
    );
    SET @i = @i + 1;
END;
GO

-- Örnek Hesap Verisi
DECLARE @j INT = 1;
WHILE @j <= 100
BEGIN
    INSERT INTO Hesaplar (MusteriID, IBAN, HesapTipi, Bakiye)
    VALUES (
        @j,
        'TR' + RIGHT(REPLICATE('0', 24) + CAST(@j AS NVARCHAR(24)), 24),
        CASE WHEN @j % 3 = 0 THEN 'Vadeli'
             WHEN @j % 3 = 1 THEN 'Vadesiz'
             ELSE 'Tasarruf' END,
        ROUND(RAND(CHECKSUM(NEWID())) * 50000 + 1000, 2)
    );
    SET @j = @j + 1;
END;
GO

-- Örnek İşlem Verisi
DECLARE @k INT = 1;
WHILE @k <= 300
BEGIN
    INSERT INTO Islemler (HesapID, IslemTipi, Tutar, Aciklama)
    VALUES (
        (@k % 100) + 1,
        CASE WHEN @k % 2 = 0 THEN 'Para Yatirma' ELSE 'Para Cekme' END,
        ROUND(RAND(CHECKSUM(NEWID())) * 5000 + 100, 2),
        'Test islemi ' + CAST(@k AS NVARCHAR(5))
    );
    SET @k = @k + 1;
END;
GO

-- Eklenen verileri doğrula
SELECT 'Musteriler' AS Tablo, COUNT(*) AS SatirSayisi FROM Musteriler
SELECT 'Hesaplar',  COUNT(*) FROM Hesaplar
SELECT 'Islemler',  COUNT(*) FROM Islemler;
GO
