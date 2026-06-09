-- SQL Injection Testleri - Güvenlik Açığı Tespiti ve Korunma

USE BLM4522_Proje3;
GO

-- ============================================================
-- BÖLÜM 1: GÜVENLİ OLMAYAN SP - String Birleştirme (Dinamik SQL)
-- ============================================================
CREATE OR ALTER PROCEDURE sp_MusteriAra_Guvensiz
    @Ad NVARCHAR(100)
AS
BEGIN
    -- String birleştirme kullanımı SQL Injection'a açıktır
    DECLARE @Sorgu NVARCHAR(500);
    SET @Sorgu = N'SELECT MusteriID, Ad, Soyad, Email FROM Musteriler WHERE Ad = ''' + @Ad + '''';
    PRINT 'Çalıştırılan sorgu: ' + @Sorgu;
    EXEC(@Sorgu);
END;
GO

-- 1a. Normal kullanım
PRINT '--- Normal Kullanım ---';
EXEC sp_MusteriAra_Guvensiz @Ad = 'Musteri1';
GO

-- 1b. SQL Injection saldırısı: OR koşulu ekleyerek tüm kayıtları döndürme
-- Giriş: ' OR '1'='1
-- Oluşan sorgu: WHERE Ad = '' OR '1'='1'  → TÜM satırları döndürür
PRINT '--- Injection Saldırısı: Tüm kayıtları getir ---';
EXEC sp_MusteriAra_Guvensiz @Ad = ''' OR ''1''=''1';
GO

-- 1c. Yorum satırı ile sorgunun geri kalanını devre dışı bırakma
-- Giriş: Musteri1' --
PRINT '--- Injection Saldırısı: Yorum ile WHERE kısaltma ---';
EXEC sp_MusteriAra_Guvensiz @Ad = 'Musteri1'' --';
GO


-- ============================================================
-- BÖLÜM 2: GÜVENLİ SP - sp_executesql ile Parametreli Sorgu
-- ============================================================
CREATE OR ALTER PROCEDURE sp_MusteriAra_Guvenli
    @Ad NVARCHAR(100)
AS
BEGIN
    -- Parametre ayrı tutulur; giriş asla SQL'e doğrudan eklenmez
    DECLARE @Sorgu NVARCHAR(500);
    SET @Sorgu = N'SELECT MusteriID, Ad, Soyad, Email FROM Musteriler WHERE Ad = @AdParam';
    EXEC sp_executesql @Sorgu, N'@AdParam NVARCHAR(100)', @AdParam = @Ad;
END;
GO

-- 2a. Normal kullanım - çalışır
PRINT '--- Güvenli SP - Normal Kullanım ---';
EXEC sp_MusteriAra_Guvenli @Ad = 'Musteri1';
GO

-- 2b. Aynı injection girişimi - parametre olarak işlenir, injection çalışmaz
PRINT '--- Güvenli SP - Injection Girişimi (Sonuç: 0 satır) ---';
EXEC sp_MusteriAra_Guvenli @Ad = ''' OR ''1''=''1';
GO


-- ============================================================
-- BÖLÜM 3: QUOTENAME ile Dinamik Nesne Adı Güvenliği
-- ============================================================
CREATE OR ALTER PROCEDURE sp_TabloyuListele_Guvenli
    @TabloAdi NVARCHAR(128)
AS
BEGIN
    -- QUOTENAME köşeli parantez ekler, zararlı karakterleri nötralize eder
    DECLARE @Sorgu NVARCHAR(500);
    SET @Sorgu = N'SELECT TOP 5 * FROM ' + QUOTENAME(@TabloAdi);
    PRINT 'Çalıştırılan sorgu: ' + @Sorgu;
    EXEC sp_executesql @Sorgu;
END;
GO

PRINT '--- QUOTENAME - Normal Kullanım ---';
EXEC sp_TabloyuListele_Guvenli @TabloAdi = 'Musteriler';
GO

-- Injection girişimi - QUOTENAME zararsız hale getirir (tablo bulunamaz hatası, DROP çalışmaz)
PRINT '--- QUOTENAME - Injection Girişimi ---';
EXEC sp_TabloyuListele_Guvenli @TabloAdi = 'Musteriler; DROP TABLE Hesaplar';
GO


-- ============================================================
-- BÖLÜM 4: Güvenli/Güvensiz Yöntem Karşılaştırma Özeti
-- ============================================================
SELECT 'Güvensiz SP'  AS YontemTipi,
       'EXEC(@dinamik_string)'           AS Yontem,
       'SQL Injection''a AÇIK'           AS GüvenlikDurumu
UNION ALL
SELECT 'Güvenli SP',
       'sp_executesql + @parametre',
       'SQL Injection''a KAPALI'
UNION ALL
SELECT 'Nesne Adı Güvenliği',
       'QUOTENAME(@TabloAdi)',
       'Injection nötralize edilir';
GO
