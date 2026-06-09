-- T-SQL ile Yedekleme Raporları (msdb sistem tabloları)
USE msdb;
GO

-- ============================================================
-- RAPOR 1: Son 30 günde alınan tüm yedeklerin özeti
-- ============================================================
SELECT
    bs.database_name            AS VeritabaniAdi,
    CASE bs.type
        WHEN 'D' THEN 'Tam Yedek'
        WHEN 'I' THEN 'Diferansiyel'
        WHEN 'L' THEN 'Log Yedek'
        ELSE bs.type
    END                         AS YedekTipi,
    bs.backup_start_date        AS BaslangicZamani,
    bs.backup_finish_date       AS BitisZamani,
    DATEDIFF(SECOND, bs.backup_start_date, bs.backup_finish_date) AS SureSaniye,
    CAST(bs.backup_size / 1048576.0 AS DECIMAL(10,2))   AS BoyutMB,
    CAST(bs.compressed_backup_size / 1048576.0 AS DECIMAL(10,2)) AS SikistirilmisBoyutMB,
    CAST(
        (1.0 - CAST(bs.compressed_backup_size AS FLOAT) / bs.backup_size) * 100
    AS DECIMAL(5,2))            AS SikistirmaOrani,
    bmf.physical_device_name    AS DosyaYolu
FROM msdb.dbo.backupset bs
JOIN msdb.dbo.backupmediafamily bmf ON bs.media_set_id = bmf.media_set_id
WHERE bs.database_name = 'BLM4522_Proje4'
  AND bs.backup_start_date >= DATEADD(DAY, -30, GETDATE())
ORDER BY bs.backup_start_date DESC;
GO


-- ============================================================
-- RAPOR 2: Her veritabanı için en son yedekleme zamanı
-- ============================================================
SELECT
    database_name       AS VeritabaniAdi,
    MAX(CASE WHEN type = 'D' THEN backup_finish_date END) AS SonTamYedek,
    MAX(CASE WHEN type = 'I' THEN backup_finish_date END) AS SonDiferansiyel,
    MAX(CASE WHEN type = 'L' THEN backup_finish_date END) AS SonLogYedek
FROM msdb.dbo.backupset
WHERE database_name = 'BLM4522_Proje4'
GROUP BY database_name;
GO


-- ============================================================
-- RAPOR 3: Son tam yedekten bu yana geçen süre
-- ============================================================
SELECT
    database_name       AS VeritabaniAdi,
    MAX(backup_finish_date) AS SonTamYedekZamani,
    DATEDIFF(HOUR, MAX(backup_finish_date), GETDATE()) AS SaatOnce
FROM msdb.dbo.backupset
WHERE type = 'D'
  AND database_name = 'BLM4522_Proje4'
GROUP BY database_name;
GO


-- ============================================================
-- RAPOR 4: Geri yükleme (restore) geçmişi
-- ============================================================
SELECT
    rh.destination_database_name   AS HedefVeritabani,
    CASE rh.restore_type
        WHEN 'D' THEN 'Tam'
        WHEN 'I' THEN 'Diferansiyel'
        WHEN 'L' THEN 'Log'
        ELSE rh.restore_type
    END                             AS GeriYuklemeTipi,
    rh.restore_date                 AS GeriYuklemeZamani,
    rh.user_name                    AS KullaniciAdi,
    bs.backup_start_date            AS YedekAlinmaZamani
FROM msdb.dbo.restorehistory rh
JOIN msdb.dbo.backupset bs ON rh.backup_set_id = bs.backup_set_id
WHERE rh.destination_database_name = 'BLM4522_Proje4'
ORDER BY rh.restore_date DESC;
GO


-- ============================================================
-- RAPOR 5: SQL Agent Job çalışma geçmişi
-- ============================================================
SELECT TOP 20
    j.name              AS JobAdi,
    jh.run_date         AS CalismaGunu,
    jh.run_time         AS CalismaSaati,
    CASE jh.run_status
        WHEN 0 THEN 'Basarisiz'
        WHEN 1 THEN 'Basarili'
        WHEN 2 THEN 'Yeniden Deneniyor'
        WHEN 3 THEN 'Iptal Edildi'
    END                 AS Sonuc,
    jh.run_duration     AS SureSaniye,
    jh.message          AS Mesaj
FROM msdb.dbo.sysjobhistory jh
JOIN msdb.dbo.sysjobs j ON jh.job_id = j.job_id
WHERE j.name LIKE 'BLM4522_Proje4%'
  AND jh.step_id > 0  -- Sadece adım kayıtları (0 = job özeti)
ORDER BY jh.run_date DESC, jh.run_time DESC;
GO


-- ============================================================
-- RAPOR 6: Yedeklenmeyen veritabanlarını tespit et
-- ============================================================
SELECT
    d.name              AS VeritabaniAdi,
    d.recovery_model_desc AS KurtarmaModeli,
    MAX(bs.backup_finish_date) AS SonYedekZamani,
    CASE
        WHEN MAX(bs.backup_finish_date) IS NULL
            THEN 'HIC YEDEKLENMEMIS'
        WHEN DATEDIFF(HOUR, MAX(bs.backup_finish_date), GETDATE()) > 24
            THEN '24 SAATTEN FAZLA YEDEK YOK'
        ELSE 'Guncel'
    END                 AS Durum
FROM sys.databases d
LEFT JOIN msdb.dbo.backupset bs
    ON d.name = bs.database_name AND bs.type = 'D'
WHERE d.database_id > 4  -- Sistem veritabanlarını hariç tut
GROUP BY d.name, d.recovery_model_desc
ORDER BY SonYedekZamani ASC;
GO
