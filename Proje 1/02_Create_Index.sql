SELECT * FROM Musteriler WHERE Email = 'user499999@mail.com';

CREATE INDEX IX_Musteriler_Email ON Musteriler(Email);
GO

SELECT * FROM Musteriler WHERE Email = 'user499999@mail.com';

DROP INDEX IX_Musteriler_Email ON Musteriler;
GO

CHECKPOINT;
DBCC DROPCLEANBUFFERS;