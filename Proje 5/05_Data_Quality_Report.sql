-- Veri Kalitesi Raporu - ETL Öncesi ve Sonrası Karşılaştırma
USE BLM4522_Proje5;
GO

-- ============================================================
-- RAPOR 1: ETL Öncesi / Sonrası Satır Sayısı Karşılaştırması
-- ============================================================
SELECT
    'Müşteriler' AS VeriSeti,
    (SELECT COUNT(*) FROM Ham_Musteriler_Yedek) AS OncekiSatir,
    (SELECT COUNT(*) FROM Temiz_Musteriler)      AS SonrakiSatir,
    (SELECT COUNT(*) FROM Ham_Musteriler_Yedek) -
    (SELECT COUNT(*) FROM Temiz_Musteriler)      AS ElenenSatir
UNION ALL
SELECT
    'Siparişler',
    (SELECT COUNT(*) FROM Ham_Siparisler_Yedek),
    (SELECT COUNT(*) FROM Temiz_Siparisler),
    (SELECT COUNT(*) FROM Ham_Siparisler_Yedek) -
    (SELECT COUNT(*) FROM Temiz_Siparisler);
GO

-- ============================================================
-- RAPOR 2: Düzeltilen sorunların özeti
-- ============================================================
SELECT Sorun, OncekiSayi, 0 AS SonrakiSayi,
       OncekiSayi AS GiderilenSayisi
FROM (
    SELECT 'NULL Ad/Soyad'     AS Sorun,
        (SELECT COUNT(*) FROM Ham_Musteriler_Yedek WHERE Ad IS NULL OR Soyad IS NULL) AS OncekiSayi
    UNION ALL
    SELECT 'Geçersiz Email',
        (SELECT COUNT(*) FROM Ham_Musteriler_Yedek
         WHERE Email IS NOT NULL AND Email NOT LIKE '%@%.%')
    UNION ALL
    SELECT 'Yinelenen Kayıt',
        (SELECT COUNT(*) FROM Ham_Musteriler_Yedek) - (SELECT COUNT(*) FROM Ham_Musteriler)
    UNION ALL
    SELECT 'Geçersiz Tarih',
        (SELECT COUNT(*) FROM Ham_Musteriler_Yedek WHERE ISDATE(DogumTarihi) = 0)
    UNION ALL
    SELECT 'Geçersiz Maaş',
        (SELECT COUNT(*) FROM Ham_Musteriler_Yedek WHERE Maas IS NOT NULL AND ISNUMERIC(Maas) = 0)
) AS Sorunlar
ORDER BY OncekiSayi DESC;
GO

-- ============================================================
-- RAPOR 3: NULL oranları karşılaştırması (öncesi vs sonrası)
-- ============================================================
SELECT
    'Email NULL Oranı (Önce)' AS Metrik,
    CAST(100.0 * SUM(CASE WHEN Email IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2)) AS Yuzde
FROM Ham_Musteriler_Yedek
UNION ALL
SELECT
    'Email NULL Oranı (Sonra)',
    CAST(100.0 * SUM(CASE WHEN Email IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2))
FROM Temiz_Musteriler
UNION ALL
SELECT
    'Maaş NULL Oranı (Önce)',
    CAST(100.0 * SUM(CASE WHEN Maas IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2))
FROM Ham_Musteriler_Yedek
UNION ALL
SELECT
    'Maaş NULL Oranı (Sonra)',
    CAST(100.0 * SUM(CASE WHEN Maas IS NULL THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(5,2))
FROM Temiz_Musteriler;
GO

-- ============================================================
-- RAPOR 4: Şehir bazlı müşteri dağılımı
-- ============================================================
SELECT
    Sehir,
    COUNT(*)                        AS MusteriSayisi,
    AVG(Maas)                       AS OrtMaas,
    MIN(Maas)                       AS MinMaas,
    MAX(Maas)                       AS MaxMaas,
    SUM(CASE WHEN Cinsiyet = 'Erkek' THEN 1 ELSE 0 END) AS ErkekSayisi,
    SUM(CASE WHEN Cinsiyet = 'Kadın' THEN 1 ELSE 0 END) AS KadinSayisi
FROM Temiz_Musteriler
WHERE Sehir IS NOT NULL
GROUP BY Sehir
ORDER BY MusteriSayisi DESC;
GO

-- ============================================================
-- RAPOR 5: Müşteri segmentleri dağılımı
-- ============================================================
SELECT
    MaasSegment,
    YasGrubu,
    COUNT(*) AS KisiSayisi,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS Yuzde
FROM Musteri_Segmentleri
GROUP BY MaasSegment, YasGrubu
ORDER BY MaasSegment, YasGrubu;
GO

-- ============================================================
-- RAPOR 6: Ürün bazlı sipariş analizi
-- ============================================================
SELECT
    UrunAdi,
    COUNT(*)            AS SiparisSayisi,
    SUM(Miktar)         AS ToplamAdet,
    AVG(BirimFiyat)     AS OrtFiyat,
    SUM(ToplamTutar)    AS ToplamCiro
FROM Temiz_Siparisler
GROUP BY UrunAdi
ORDER BY ToplamCiro DESC;
GO

-- ============================================================
-- RAPOR 7: Sipariş durumu dağılımı
-- ============================================================
SELECT
    Durum,
    COUNT(*)                    AS SiparisSayisi,
    SUM(ToplamTutar)            AS ToplamTutar,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS Yuzde
FROM Temiz_Siparisler
GROUP BY Durum
ORDER BY SiparisSayisi DESC;
GO
