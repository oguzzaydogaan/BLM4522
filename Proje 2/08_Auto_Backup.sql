DECLARE @dosyaYolu NVARCHAR(200)
SET @dosyaYolu = 'C:\Backup\BLM4522_Full_' + FORMAT(GETDATE(), 'yyyyMMdd') + '.bak'

BACKUP DATABASE [BLM4522] TO DISK = @dosyaYolu WITH INIT;
GO