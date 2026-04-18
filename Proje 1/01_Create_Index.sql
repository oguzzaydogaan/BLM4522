SELECT * FROM Musteriler WHERE Email = 'user4999@mail.com';

CREATE INDEX IX_Musteriler_Email ON Musteriler(Email);
GO

SELECT * FROM Musteriler WHERE Email = 'user4999@mail.com';