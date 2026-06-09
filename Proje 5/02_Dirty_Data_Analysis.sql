-- Kirli Veri Analizi - ETL öncesi sorunların tespiti
USE BLM4522_Proje5;
GO

-- ============================================================
-- RAPOR 1: Genel veri kalitesi özeti
-- ============================================================
SELECT
    'Ham_Musteriler'        AS Tablo,
    COUNT(*)                AS ToplamSatir,
    SUM(CASE WHEN Ad       IS NULL THEN 1 ELSE 0 END) AS NullAd,
    SUM(CASE WHEN Email    IS NULL THEN 1 ELSE 0 END) AS NullEmail,
    SUM(CASE WHEN Telefon  IS NULL THEN 1 ELSE 0 END) AS NullTelefon,
    SUM(CASE WHEN Sehir    IS NULL THEN 1 ELSE 0 END) AS NullSehir,
    SUM(CASE WHEN Maas     IS NULL THEN 1 ELSE 0 END) AS NullMaas
FROM Ham_Musteriler;
GO

-- ============================================================
-- RAPOR 2: Yinelenen (duplicate) kayıtlar
-- ============================================================
SELECT
    LOWER(TRIM(Ad))    AS Ad,
    LOWER(TRIM(Soyad)) AS Soyad,
    LOWER(TRIM(Email)) AS Email,
    COUNT(*)           AS YineleneSayisi
FROM Ham_Musteriler
WHERE Ad IS NOT NULL AND Email IS NOT NULL
GROUP BY LOWER(TRIM(Ad)), LOWER(TRIM(Soyad)), LOWER(TRIM(Email))
HAVING COUNT(*) > 1;
GO

-- ============================================================
-- RAPOR 3: Geçersiz email formatları
-- ============================================================
SELECT ID, Ad, Soyad, Email, 'Geçersiz Email' AS Sorun
FROM Ham_Musteriler
WHERE Email IS NOT NULL
  AND (
      Email NOT LIKE '%@%.%'       -- @ veya . içermiyor
      OR Email LIKE '@%'           -- @ ile başlıyor
      OR Email LIKE '%@'           -- @ ile bitiyor
      OR LEN(TRIM(Email)) = 0      -- boş string
  );
GO

-- ============================================================
-- RAPOR 4: Geçersiz/tutarsız tarih değerleri
-- ============================================================
SELECT ID, Ad, Soyad, DogumTarihi, 'Geçersiz Tarih' AS Sorun
FROM Ham_Musteriler
WHERE DogumTarihi IS NOT NULL
  AND (
      ISDATE(DogumTarihi) = 0                  -- tarih olarak parse edilemiyor
      OR TRY_CAST(DogumTarihi AS DATE) > GETDATE()  -- gelecek tarih
      OR TRY_CAST(DogumTarihi AS DATE) < '1900-01-01'
  );
GO

-- ============================================================
-- RAPOR 5: Geçersiz maaş değerleri
-- ============================================================
SELECT ID, Ad, Soyad, Maas, 'Geçersiz Maaş' AS Sorun
FROM Ham_Musteriler
WHERE Maas IS NOT NULL
  AND (
      ISNUMERIC(Maas) = 0              -- sayıya çevrilemiyor
      OR TRY_CAST(Maas AS DECIMAL(10,2)) < 0  -- negatif değer
  );
GO

-- ============================================================
-- RAPOR 6: Cinsiyet tutarsızlıkları
-- ============================================================
SELECT DISTINCT Cinsiyet, COUNT(*) AS Sayi
FROM Ham_Musteriler
GROUP BY Cinsiyet
ORDER BY Sayi DESC;
GO

-- ============================================================
-- RAPOR 7: Boşluk sorunları (leading/trailing spaces)
-- ============================================================
SELECT ID, Ad, Soyad, Email, Telefon, 'Baş/Son Boşluk' AS Sorun
FROM Ham_Musteriler
WHERE Ad != TRIM(Ad)
   OR Soyad != TRIM(ISNULL(Soyad,''))
   OR Email != TRIM(ISNULL(Email,''))
   OR Telefon != TRIM(ISNULL(Telefon,''));
GO

-- ============================================================
-- RAPOR 8: Siparişlerdeki sorunlar özeti
-- ============================================================
SELECT
    SUM(CASE WHEN UrunAdi IS NULL THEN 1 ELSE 0 END)                          AS NullUrun,
    SUM(CASE WHEN MusteriID IS NULL THEN 1 ELSE 0 END)                        AS NullMusteriID,
    SUM(CASE WHEN ISNUMERIC(Miktar) = 0 OR TRY_CAST(Miktar AS INT) <= 0
             THEN 1 ELSE 0 END)                                                AS GecersizMiktar,
    SUM(CASE WHEN ISNUMERIC(BirimFiyat) = 0 OR TRY_CAST(BirimFiyat AS DECIMAL(10,2)) <= 0
             THEN 1 ELSE 0 END)                                                AS GecersizFiyat,
    SUM(CASE WHEN ISDATE(SiparisTarihi) = 0 THEN 1 ELSE 0 END)                AS GecersizTarih
FROM Ham_Siparisler;
GO

-- ============================================================
-- RAPOR 9: Sorun kategorisi bazında toplam sayılar
-- ============================================================
SELECT Sorun, COUNT(*) AS EtkilenenSatir FROM (
    SELECT 'NULL Değer'           AS Sorun FROM Ham_Musteriler WHERE Ad IS NULL OR Email IS NULL OR Telefon IS NULL
    UNION ALL
    SELECT 'Geçersiz Email'       FROM Ham_Musteriler WHERE Email IS NOT NULL AND Email NOT LIKE '%@%.%'
    UNION ALL
    SELECT 'Geçersiz Tarih'       FROM Ham_Musteriler WHERE ISDATE(DogumTarihi) = 0
    UNION ALL
    SELECT 'Geçersiz Maaş'        FROM Ham_Musteriler WHERE Maas IS NOT NULL AND ISNUMERIC(Maas) = 0
    UNION ALL
    SELECT 'Baş/Son Boşluk'       FROM Ham_Musteriler WHERE Ad != TRIM(Ad) OR Soyad != TRIM(ISNULL(Soyad,''))
) AS Sorunlar
GROUP BY Sorun
ORDER BY EtkilenenSatir DESC;
GO
