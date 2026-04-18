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

-- 3. Ürünler Tablosu
CREATE TABLE Urunler (
    UrunID INT PRIMARY KEY IDENTITY(1,1),
    UrunAdi NVARCHAR(100),
    Fiyat DECIMAL(10,2),
    StokAdedi INT
);

-- 4. Siparişler Tablosu (İlişkili Tablo)
CREATE TABLE Siparisler (
    SiparisID INT PRIMARY KEY IDENTITY(1,1),
    MusteriID INT FOREIGN KEY REFERENCES Musteriler(MusteriID),
    UrunID INT FOREIGN KEY REFERENCES Urunler(UrunID),
    SiparisTarihi DATETIME DEFAULT GETDATE(),
    Adet INT
);
GO