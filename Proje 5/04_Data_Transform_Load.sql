-- Veri Dönüştürme ve Yükleme (Transform & Load)
USE BLM4522_Proje5;
GO

-- ============================================================
-- ADIM 1: Hedef (temiz) tabloları oluştur
-- ============================================================
CREATE TABLE Temiz_Musteriler (
    MusteriID   INT PRIMARY KEY IDENTITY(1,1),
    Ad          NVARCHAR(50)   NOT NULL,
    Soyad       NVARCHAR(50)   NOT NULL,
    TamAd       AS (Ad + ' ' + Soyad),   -- hesaplanan kolon
    Email       NVARCHAR(150),
    Telefon     NVARCHAR(15),
    Sehir       NVARCHAR(50),
    DogumTarihi DATE,
    Yas         AS (DATEDIFF(YEAR, TRY_CAST(DogumTarihi AS DATE), GETDATE())),  -- hesaplanan kolon
    Cinsiyet    NVARCHAR(10),
    Maas        DECIMAL(10,2),
    YuklemeTarihi DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE Temiz_Siparisler (
    SiparisID   INT PRIMARY KEY IDENTITY(1,1),
    MusteriID   INT NOT NULL REFERENCES Temiz_Musteriler(MusteriID),
    UrunAdi     NVARCHAR(100)  NOT NULL,
    Miktar      INT            NOT NULL,
    BirimFiyat  DECIMAL(10,2)  NOT NULL,
    ToplamTutar AS (Miktar * BirimFiyat),  -- hesaplanan kolon
    SiparisTarihi DATE,
    Durum       NVARCHAR(20),
    YuklemeTarihi DATETIME DEFAULT GETDATE()
);
GO

-- ============================================================
-- ADIM 2: Müşteri verisini dönüştürerek yükle
-- ============================================================
INSERT INTO Temiz_Musteriler (Ad, Soyad, Email, Telefon, Sehir, DogumTarihi, Cinsiyet, Maas)
SELECT
    Ad,
    Soyad,
    Email,
    Telefon,
    Sehir,
    TRY_CAST(DogumTarihi AS DATE),
    Cinsiyet,
    TRY_CAST(Maas AS DECIMAL(10,2))
FROM Ham_Musteriler
WHERE Ad    IS NOT NULL
  AND Soyad IS NOT NULL;
GO

-- ============================================================
-- ADIM 3: Sipariş verisini dönüştürerek yükle
-- Ham_Siparisler.MusteriID → Temiz_Musteriler.MusteriID eşleştirmesi gerekiyor
-- Ham tablodaki ID sırasını Temiz tabloya map ediyoruz
-- ============================================================
INSERT INTO Temiz_Siparisler (MusteriID, UrunAdi, Miktar, BirimFiyat, SiparisTarihi, Durum)
SELECT
    tm.MusteriID,
    hs.UrunAdi,
    TRY_CAST(hs.Miktar     AS INT)          AS Miktar,
    TRY_CAST(hs.BirimFiyat AS DECIMAL(10,2)) AS BirimFiyat,
    TRY_CAST(hs.SiparisTarihi AS DATE)       AS SiparisTarihi,
    hs.Durum
FROM Ham_Siparisler hs
JOIN Ham_Musteriler hm ON hs.MusteriID = hm.ID
JOIN Temiz_Musteriler tm
    ON LOWER(tm.Ad) = LOWER(hm.Ad)
    AND LOWER(tm.Soyad) = LOWER(hm.Soyad)
WHERE hs.UrunAdi    IS NOT NULL
  AND hs.Miktar     IS NOT NULL  AND ISNUMERIC(hs.Miktar) = 1      AND TRY_CAST(hs.Miktar AS INT) > 0
  AND hs.BirimFiyat IS NOT NULL  AND ISNUMERIC(hs.BirimFiyat) = 1  AND TRY_CAST(hs.BirimFiyat AS DECIMAL(10,2)) > 0;
GO

-- ============================================================
-- ADIM 4: Şehir bazlı müşteri segmentasyonu (ek dönüşüm)
-- ============================================================
CREATE TABLE Musteri_Segmentleri (
    SegmentID   INT PRIMARY KEY IDENTITY(1,1),
    MusteriID   INT NOT NULL REFERENCES Temiz_Musteriler(MusteriID),
    Sehir       NVARCHAR(50),
    MaasSegment NVARCHAR(20),
    YasGrubu    NVARCHAR(20)
);
GO

INSERT INTO Musteri_Segmentleri (MusteriID, Sehir, MaasSegment, YasGrubu)
SELECT
    MusteriID,
    Sehir,
    CASE
        WHEN Maas < 7000               THEN 'Düşük Gelir'
        WHEN Maas BETWEEN 7000 AND 12000 THEN 'Orta Gelir'
        WHEN Maas > 12000              THEN 'Yüksek Gelir'
        ELSE 'Bilinmiyor'
    END AS MaasSegment,
    CASE
        WHEN DATEDIFF(YEAR, DogumTarihi, GETDATE()) < 30 THEN 'Genç (18-29)'
        WHEN DATEDIFF(YEAR, DogumTarihi, GETDATE()) BETWEEN 30 AND 45 THEN 'Orta Yaş (30-45)'
        WHEN DATEDIFF(YEAR, DogumTarihi, GETDATE()) > 45 THEN 'Kıdemli (45+)'
        ELSE 'Bilinmiyor'
    END AS YasGrubu
FROM Temiz_Musteriler;
GO

-- ============================================================
-- ADIM 5: Yüklenen veriyi doğrula
-- ============================================================
SELECT 'Temiz_Musteriler'   AS Tablo, COUNT(*) AS SatirSayisi FROM Temiz_Musteriler
UNION ALL
SELECT 'Temiz_Siparisler',    COUNT(*) FROM Temiz_Siparisler
UNION ALL
SELECT 'Musteri_Segmentleri', COUNT(*) FROM Musteri_Segmentleri;

-- Temiz müşteri listesi
SELECT MusteriID, TamAd, Email, Telefon, Sehir, DogumTarihi, Yas, Cinsiyet, Maas
FROM Temiz_Musteriler
ORDER BY MusteriID;

-- Siparişler ve toplam tutar
SELECT s.SiparisID, m.TamAd, s.UrunAdi, s.Miktar, s.BirimFiyat, s.ToplamTutar, s.SiparisTarihi, s.Durum
FROM Temiz_Siparisler s
JOIN Temiz_Musteriler m ON s.MusteriID = m.MusteriID
ORDER BY s.SiparisID;
GO
