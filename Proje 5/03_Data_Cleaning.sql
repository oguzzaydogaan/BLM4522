-- Veri Temizleme - Kirli verinin düzeltilmesi
USE BLM4522_Proje5;
GO

-- ============================================================
-- ADIM 1: Ham tabloların yedeğini al (temizlik öncesi)
-- ============================================================
SELECT * INTO Ham_Musteriler_Yedek FROM Ham_Musteriler;
SELECT * INTO Ham_Siparisler_Yedek FROM Ham_Siparisler;
GO

-- ============================================================
-- ADIM 2: Baş/son boşlukları temizle
-- ============================================================
UPDATE Ham_Musteriler SET
    Ad      = TRIM(Ad),
    Soyad   = TRIM(Soyad),
    Email   = TRIM(Email),
    Telefon = TRIM(Telefon),
    Sehir   = TRIM(Sehir);
GO

-- ============================================================
-- ADIM 3: Büyük/küçük harf standardizasyonu
-- ============================================================
UPDATE Ham_Musteriler SET
    Ad    = UPPER(LEFT(LOWER(Ad), 1)) + LOWER(SUBSTRING(LOWER(Ad), 2, LEN(Ad))),
    Soyad = UPPER(LEFT(LOWER(Soyad), 1)) + LOWER(SUBSTRING(LOWER(Soyad), 2, LEN(Soyad))),
    Email = LOWER(Email),
    Sehir = UPPER(LEFT(LOWER(Sehir), 1)) + LOWER(SUBSTRING(LOWER(Sehir), 2, LEN(Sehir)))
WHERE Ad IS NOT NULL AND Soyad IS NOT NULL;
GO

-- ============================================================
-- ADIM 4: Cinsiyet değerlerini standart hale getir
-- ============================================================
UPDATE Ham_Musteriler SET
    Cinsiyet = CASE
        WHEN UPPER(TRIM(Cinsiyet)) IN ('E', 'ERKEK', 'BAY', 'M', 'MALE')   THEN 'Erkek'
        WHEN UPPER(TRIM(Cinsiyet)) IN ('K', 'KADIN', 'BAYAN', 'F', 'FEMALE') THEN 'Kadın'
        ELSE NULL
    END;
GO

-- ============================================================
-- ADIM 5: Telefon numaralarını standart formata çevir (05XX XXX XX XX)
-- ============================================================
UPDATE Ham_Musteriler SET
    Telefon = '0' + RIGHT(REPLICATE('0',10) +
              REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
              Telefon, '+90', ''), ' ', ''), '-', ''), '(', ''), ')', ''), '.', ''),
              10)
WHERE Telefon IS NOT NULL
  AND LEN(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
      Telefon, '+90', ''), ' ', ''), '-', ''), '(', ''), ')', ''), '.', '')) >= 10;
GO

-- ============================================================
-- ADIM 6: Geçersiz email adreslerini NULL yap
-- ============================================================
UPDATE Ham_Musteriler SET Email = NULL
WHERE Email IS NOT NULL
  AND (
      Email NOT LIKE '%@%.%'
      OR Email LIKE '@%'
      OR Email LIKE '%@'
      OR LEN(Email) < 5
  );
GO

-- ============================================================
-- ADIM 7: Geçersiz tarihleri NULL yap
-- ============================================================
UPDATE Ham_Musteriler SET DogumTarihi = NULL
WHERE ISDATE(DogumTarihi) = 0
   OR TRY_CAST(DogumTarihi AS DATE) > GETDATE()
   OR TRY_CAST(DogumTarihi AS DATE) < '1900-01-01';
GO

-- ============================================================
-- ADIM 8: Geçersiz maaş değerlerini NULL yap
-- ============================================================
UPDATE Ham_Musteriler SET Maas = NULL
WHERE ISNUMERIC(Maas) = 0
   OR TRY_CAST(Maas AS DECIMAL(10,2)) < 0;
GO

-- ============================================================
-- ADIM 9: Yinelenen kayıtları sil (en küçük ID'li olanı tut)
-- ============================================================
DELETE FROM Ham_Musteriler
WHERE ID NOT IN (
    SELECT MIN(ID)
    FROM Ham_Musteriler
    WHERE Email IS NOT NULL
    GROUP BY LOWER(Email)
);
GO

-- ============================================================
-- ADIM 10: Sipariş tablosunu temizle
-- ============================================================

-- NULL ürün adlı siparişleri sil
DELETE FROM Ham_Siparisler WHERE UrunAdi IS NULL;

-- Geçersiz miktar (sayısal olmayan veya negatif)
UPDATE Ham_Siparisler SET Miktar = NULL
WHERE ISNUMERIC(Miktar) = 0 OR TRY_CAST(Miktar AS INT) <= 0;

-- Fiyat alanından TL ve boşluk temizle, negatif olanları NULL yap
UPDATE Ham_Siparisler SET
    BirimFiyat = REPLACE(REPLACE(REPLACE(BirimFiyat, 'TL', ''), 'tl', ''), ' ', '');

UPDATE Ham_Siparisler SET BirimFiyat = NULL
WHERE ISNUMERIC(BirimFiyat) = 0 OR TRY_CAST(BirimFiyat AS DECIMAL(10,2)) <= 0;

-- Sipariş durumu standardizasyonu
UPDATE Ham_Siparisler SET
    Durum = CASE
        WHEN UPPER(TRIM(ISNULL(Durum,''))) IN ('TAMAMLANDI','TAMAMLANDÄ°') THEN 'Tamamlandı'
        WHEN UPPER(TRIM(ISNULL(Durum,''))) IN ('BEKLEMEDE')                 THEN 'Beklemede'
        WHEN UPPER(TRIM(ISNULL(Durum,''))) IN ('IPTAL','İPTAL')            THEN 'İptal'
        ELSE 'Belirsiz'
    END;

-- Geçersiz tarihleri NULL yap
UPDATE Ham_Siparisler SET SiparisTarihi = NULL
WHERE ISDATE(SiparisTarihi) = 0;
GO

-- ============================================================
-- Temizlik sonrası kontrol
-- ============================================================
SELECT 'Temizlik Sonrası Ham_Musteriler' AS Durum, COUNT(*) AS SatirSayisi FROM Ham_Musteriler
UNION ALL
SELECT 'Yedekten Silinen Satır Sayısı',
    (SELECT COUNT(*) FROM Ham_Musteriler_Yedek) - (SELECT COUNT(*) FROM Ham_Musteriler);

SELECT ID, Ad, Soyad, Email, Telefon, Sehir, DogumTarihi, Cinsiyet, Maas
FROM Ham_Musteriler
ORDER BY ID;
GO
