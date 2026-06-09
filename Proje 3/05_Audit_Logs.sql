-- SQL Server Audit - Kullanıcı Aktivitesi İzleme ve Denetim

-- ============================================================
-- ADIM 1: Server Audit Oluştur
-- NOT: C:\Audit\ klasörünün SQL Server servis hesabınca yazılabilir olması gerekir.
--      Klasörü oluşturmak için: MKDIR C:\Audit
-- ============================================================
USE master;
GO

CREATE SERVER AUDIT BLM4522_Proje3_Audit
    TO FILE (
        FILEPATH          = 'C:\Audit\',
        MAXSIZE           = 100 MB,
        MAX_ROLLOVER_FILES = 5,
        RESERVE_DISK_SPACE = OFF
    )
    WITH (
        QUEUE_DELAY = 1000,
        ON_FAILURE  = CONTINUE
    );
GO

ALTER SERVER AUDIT BLM4522_Proje3_Audit WITH (STATE = ON);
GO


-- ============================================================
-- ADIM 2: Veritabanı Audit Specification Oluştur
-- ============================================================
USE BLM4522_Proje3;
GO

CREATE DATABASE AUDIT SPECIFICATION BLM4522_Proje3_DbAudit
    FOR SERVER AUDIT BLM4522_Proje3_Audit

    -- Musteriler: SELECT izleme (hassas veri erişimi - TCNO, DogumTarihi)
    ADD (SELECT ON OBJECT::dbo.Musteriler BY PUBLIC),

    -- Hesaplar: tüm değişiklikler (bakiye manipülasyonu riski)
    ADD (INSERT, UPDATE, DELETE ON OBJECT::dbo.Hesaplar BY PUBLIC),

    -- Islemler: tüm değişiklikler
    ADD (INSERT, UPDATE, DELETE ON OBJECT::dbo.Islemler BY PUBLIC)

    WITH (STATE = ON);
GO


-- ============================================================
-- ADIM 3: Audit Durumunu Doğrula
-- ============================================================
SELECT
    sa.name             AS AuditAdi,
    sa.type_desc        AS HedefTip,
    sa.is_state_enabled AS Aktif,
    saf.path            AS DosyaYolu
FROM sys.server_audits sa
LEFT JOIN sys.server_file_audits saf ON sa.audit_id = saf.audit_id
WHERE sa.name = 'BLM4522_Proje3_Audit';

SELECT
    das.name             AS SpecAdi,
    das.is_state_enabled AS Aktif
FROM sys.database_audit_specifications das
WHERE das.name = 'BLM4522_Proje3_DbAudit';
GO


-- ============================================================
-- ADIM 4: Test İşlemleri (audit kayıtları oluşturur)
-- ============================================================

-- Hassas veri okuma - audit kaydı oluşturur
SELECT TOP 5 MusteriID, Ad, Soyad, TCNO FROM Musteriler;

-- Hesap güncelleme
UPDATE Hesaplar SET Bakiye = Bakiye + 500 WHERE HesapID = 1;

-- Yeni işlem ekleme
INSERT INTO Islemler (HesapID, IslemTipi, Tutar, Aciklama)
VALUES (1, 'Para Yatirma', 500.00, 'Audit test - para yatirma');

-- Silme işlemi (audit kaydı oluşturur)
DELETE FROM Islemler WHERE Aciklama = 'Audit test - para yatirma';
GO


-- ============================================================
-- ADIM 5: Audit Kayıtlarını Oku
-- NOT: Dosya yolu SQL Server'ın C:\Audit\ konumuna göre ayarlanır.
-- ============================================================
SELECT TOP 20
    event_time                      AS IslemZamani,
    session_server_principal_name   AS KullaniciAdi,
    database_name                   AS VeritabaniAdi,
    schema_name                     AS SemaAdi,
    object_name                     AS NesneAdi,
    action_id                       AS IslemKodu,
    statement                       AS SQLCumlesi,
    succeeded                       AS Basarili
FROM sys.fn_get_audit_file(
    'C:\Audit\BLM4522_Proje3_Audit*.sqlaudit',
    DEFAULT,
    DEFAULT
)
ORDER BY event_time DESC;
GO

-- Kullanıcı bazlı özet rapor
SELECT
    session_server_principal_name   AS KullaniciAdi,
    action_id                       AS IslemKodu,
    object_name                     AS NesneAdi,
    COUNT(*)                        AS IslemSayisi,
    MIN(event_time)                 AS IlkIslem,
    MAX(event_time)                 AS SonIslem
FROM sys.fn_get_audit_file(
    'C:\Audit\BLM4522_Proje3_Audit*.sqlaudit',
    DEFAULT,
    DEFAULT
)
GROUP BY session_server_principal_name, action_id, object_name
ORDER BY IslemSayisi DESC;
GO


-- ============================================================
-- TEMİZLİK (isteğe bağlı - yeniden test için)
-- ============================================================
-- ALTER DATABASE AUDIT SPECIFICATION BLM4522_Proje3_DbAudit WITH (STATE = OFF);
-- DROP DATABASE AUDIT SPECIFICATION BLM4522_Proje3_DbAudit;
-- USE master;
-- ALTER SERVER AUDIT BLM4522_Proje3_Audit WITH (STATE = OFF);
-- DROP SERVER AUDIT BLM4522_Proje3_Audit;
GO
