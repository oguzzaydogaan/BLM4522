USE BLM4522;
GO

-- 1. Müşteriler tablosuna 5000 adet rastgele müşteri ekleyelim
DECLARE @i INT = 1;
WHILE @i <= 5000
BEGIN
    INSERT INTO Musteriler (Ad, Soyad, Email)
    VALUES (
        'MusteriAd' + CAST(@i AS NVARCHAR(10)), 
        'Soyad' + CAST(@i AS NVARCHAR(10)), 
        'user' + CAST(@i AS NVARCHAR(10)) + '@mail.com'
    );
    SET @i = @i + 1;
END;
GO

-- 2. Ürünler tablosuna 3 ürün ekleyelim
INSERT INTO Urunler (UrunAdi, Fiyat, StokAdedi) VALUES 
('Laptop', 25000.00, 10),
('Mouse', 500.00, 50),
('Klavye', 1200.00, 30);

-- 3. Siparisler tablosuna rastgele siparişler ekleyelim
DECLARE @j INT = 1;
WHILE @j <= 2000
BEGIN
    INSERT INTO Siparisler (MusteriID, UrunID, Adet)
    VALUES (
        ABS(CHECKSUM(NEWID())) % 5000 + 1, -- Rastgele bir MusteriID
        ABS(CHECKSUM(NEWID())) % 3 + 1,    -- Rastgele bir UrunID (1, 2 veya 3)
        ABS(CHECKSUM(NEWID())) % 5 + 1     -- 1 ile 5 arası adet
    );
    SET @j = @j + 1;
END;
GO