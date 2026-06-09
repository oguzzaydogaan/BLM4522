USE master;
GO

IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'MasterKey@Proje3!2026';
END;
GO

CREATE CERTIFICATE TDE_BLM4522_Sertifika
    WITH SUBJECT = 'BLM4522 Proje3 TDE Sertifikasi',
         EXPIRY_DATE = '2030-12-31';
GO

USE BLM4522_Proje3;
GO

CREATE DATABASE ENCRYPTION KEY
    WITH ALGORITHM = AES_256
    ENCRYPTION BY SERVER CERTIFICATE TDE_BLM4522_Sertifika;
GO

-- ============================================================
-- ADIM 2: TDE'yi Etkinleştir
-- ============================================================
ALTER DATABASE BLM4522_Proje3 SET ENCRYPTION ON;
GO

-- ============================================================
-- ADIM 3: Şifreleme Durumunu Doğrula
-- ============================================================
SELECT
    db.name                      AS VeritabaniAdi,
    dek.encryptor_type           AS SifreleyiciTipi,
    dek.key_algorithm            AS Algoritma,
    dek.key_length               AS AnahtarUzunlugu,
    dek.encryption_state_desc    AS SifrelemeDurumu,
    dek.percent_complete         AS TamamlanmaYuzdesi,
    dek.create_date              AS OlusturmaTarihi
FROM sys.dm_database_encryption_keys dek
JOIN sys.databases db ON dek.database_id = db.database_id
WHERE db.name = 'BLM4522_Proje3';
GO

-- Tüm veritabanlarının şifreleme durumunu listele
SELECT
    name            AS VeritabaniAdi,
    is_encrypted    AS Sifreli
FROM sys.databases
ORDER BY name;
GO

-- Sertifika bilgilerini listele
SELECT
    name            AS SertifikaAdi,
    subject         AS Konu,
    expiry_date     AS SonKullanma,
    start_date      AS BaslangicTarihi,
    pvt_key_encryption_type_desc AS AnahtarSifrelemeTipi
FROM sys.certificates
WHERE name = 'TDE_BLM4522_Sertifika';
GO
