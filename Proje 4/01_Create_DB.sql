-- Veritabanı Yedekleme ve Otomasyon - Veritabanı Oluşturma
CREATE DATABASE BLM4522_Proje4;
GO

USE BLM4522_Proje4;
GO

-- Ürünler Tablosu
CREATE TABLE Urunler (
    UrunID      INT PRIMARY KEY IDENTITY(1,1),
    UrunAdi     NVARCHAR(100) NOT NULL,
    Kategori    NVARCHAR(50),
    BirimFiyat  DECIMAL(10,2) NOT NULL,
    EklenmeTarihi DATETIME DEFAULT GETDATE()
);
GO

-- Depolar Tablosu
CREATE TABLE Depolar (
    DepoID      INT PRIMARY KEY IDENTITY(1,1),
    DepoAdi     NVARCHAR(100) NOT NULL,
    Sehir       NVARCHAR(50),
    Kapasite    INT NOT NULL
);
GO

-- Stok Hareketleri Tablosu
CREATE TABLE StokHareketleri (
    HareketID   INT PRIMARY KEY IDENTITY(1,1),
    UrunID      INT NOT NULL REFERENCES Urunler(UrunID),
    DepoID      INT NOT NULL REFERENCES Depolar(DepoID),
    HareketTipi NVARCHAR(10) NOT NULL CHECK (HareketTipi IN ('Giris','Cikis')),
    Miktar      INT NOT NULL,
    HareketTarihi DATETIME DEFAULT GETDATE()
);
GO

-- Örnek Veriler
INSERT INTO Urunler (UrunAdi, Kategori, BirimFiyat) VALUES
('Laptop',         'Elektronik',  15000.00),
('Klavye',         'Elektronik',    450.00),
('Mouse',          'Elektronik',    250.00),
('Monitör',        'Elektronik',   4500.00),
('Masa',           'Mobilya',      2000.00),
('Sandalye',       'Mobilya',      1200.00),
('Yazıcı',         'Ofis',         3500.00),
('Kalem Seti',     'Kırtasiye',      50.00),
('Dosya Dolabı',   'Mobilya',      1800.00),
('Projeksiyon',    'Elektronik',   8000.00);
GO

INSERT INTO Depolar (DepoAdi, Sehir, Kapasite) VALUES
('Merkez Depo',    'Istanbul',  5000),
('Anadolu Depo',   'Ankara',    3000),
('Ege Depo',       'Izmir',     2500);
GO

DECLARE @i INT = 1;
WHILE @i <= 500
BEGIN
    INSERT INTO StokHareketleri (UrunID, DepoID, HareketTipi, Miktar)
    VALUES (
        (@i % 10) + 1,
        (@i % 3) + 1,
        CASE WHEN @i % 2 = 0 THEN 'Giris' ELSE 'Cikis' END,
        (@i % 100) + 1
    );
    SET @i = @i + 1;
END;
GO

ALTER DATABASE BLM4522_Proje4 SET RECOVERY FULL;
GO

SELECT 'Urunler'          AS Tablo, COUNT(*) AS SatirSayisi FROM Urunler
UNION ALL
SELECT 'Depolar',           COUNT(*) FROM Depolar
UNION ALL
SELECT 'StokHareketleri',   COUNT(*) FROM StokHareketleri;
GO
