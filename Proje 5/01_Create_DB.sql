-- Veri Temizleme ve ETL - Ham (Kirli) Veritabanı Oluşturma
CREATE DATABASE BLM4522_Proje5;
GO

USE BLM4522_Proje5;
GO

-- Ham müşteri tablosu (kasıtlı kirli veri içerir)
CREATE TABLE Ham_Musteriler (
    ID          INT IDENTITY(1,1),
    Ad          NVARCHAR(100),
    Soyad       NVARCHAR(100),
    Email       NVARCHAR(150),
    Telefon     NVARCHAR(50),
    Sehir       NVARCHAR(50),
    DogumTarihi NVARCHAR(20),   -- tarih string olarak saklanmış (hatalı tasarım)
    Cinsiyet    NVARCHAR(20),
    Maas        NVARCHAR(20)    -- sayı string olarak saklanmış (hatalı tasarım)
);
GO

-- Ham sipariş tablosu (kirli veri)
CREATE TABLE Ham_Siparisler (
    ID          INT IDENTITY(1,1),
    MusteriID   INT,
    UrunAdi     NVARCHAR(100),
    Miktar      NVARCHAR(10),   -- sayı string olarak (hatalı)
    BirimFiyat  NVARCHAR(20),   -- para birimi karışık (hatalı)
    SiparisTarihi NVARCHAR(30), -- tarih farklı formatlarda (hatalı)
    Durum       NVARCHAR(30)
);
GO

-- ============================================================
-- Kasıtlı olarak kirli veri ekleniyor:
-- NULL değerler, yinelenenler, format tutarsızlıkları,
-- büyük/küçük harf karışıklığı, geçersiz değerler
-- ============================================================
INSERT INTO Ham_Musteriler (Ad, Soyad, Email, Telefon, Sehir, DogumTarihi, Cinsiyet, Maas) VALUES
-- Normal kayıtlar
('Ahmet',   'Yılmaz',  'ahmet.yilmaz@gmail.com',  '0532-111-2233', 'İstanbul', '1990-05-15', 'E',      '8500'),
('Fatma',   'Kaya',    'fatma.kaya@hotmail.com',   '05321234567',   'Ankara',   '1985-11-20', 'K',      '7200'),
('Mehmet',  'Demir',   'mehmet@demir.net',         '(0533)3456789', 'İzmir',    '1978-03-08', 'Erkek',  '12000'),

-- Büyük/küçük harf tutarsızlığı
('AYŞE',    'ÇELIK',   'AYSE.CELIK@GMAIL.COM',    '05441234567',   'BURSA',    '1995-07-22', 'k',      '6500'),
('ali',     'öztürk',  'ali.ozturk@yahoo.com',     '05551234567',   'istanbul', '1988-12-01', 'e',      '9000'),

-- Boşluk sorunları
('  Zeynep ', ' Arslan',  ' zeynep@arslan.com ',  ' 05331234567 ', ' Ankara ', '1992-04-10', 'K',     '7800'),

-- NULL değerler
('Burak',   'Şahin',   NULL,                       '05561234567',   'İzmir',    '1991-09-30', 'E',      '8200'),
('Selin',   'Yıldız',  'selin@yildiz.com',         NULL,            'İstanbul', '1987-06-14', 'K',      NULL),
(NULL,      'Arslan',  'bilinmeyen@mail.com',       '05571234567',   NULL,       '1993-02-25', NULL,     '5500'),

-- Geçersiz email formatı
('Okan',    'Güneş',   'okan.gunes-gecersiz',      '05581234567',   'Ankara',   '1996-08-11', 'E',      '7100'),
('Pınar',   'Aydın',   '@hotmail.com',              '05591234567',   'İzmir',    '1984-01-05', 'K',      '9500'),

-- Geçersiz tarih
('Caner',   'Kılıç',   'caner@kilicmail.com',      '05601234567',   'İstanbul', '2050-15-99', 'E',      '6800'),
('Deniz',   'Ercan',   'deniz.ercan@gmail.com',    '05611234567',   'Bursa',    'dogum yok',  'K',      '8900'),

-- Negatif/geçersiz maaş
('Efe',     'Polat',   'efe.polat@gmail.com',      '05621234567',   'Ankara',   '1994-10-17', 'E',      '-500'),
('Gamze',   'Yurt',    'gamze@yurtmail.com',        '05631234567',   'İstanbul', '1989-03-28', 'K',      'bilinmiyor'),

-- Yinelenen kayıt (Ahmet Yılmaz tekrar)
('Ahmet',   'Yılmaz',  'ahmet.yilmaz@gmail.com',  '0532-111-2233', 'İstanbul', '1990-05-15', 'E',      '8500'),
('ahmet',   'yilmaz',  'ahmet.yilmaz@gmail.com',  '05321112233',   'istanbul', '1990-05-15', 'erkek',  '8500'),

-- Telefon format tutarsızlığı
('Hakan',   'Çetin',   'hakan.cetin@gmail.com',   '+90 532 123 45 67', 'İzmir', '1986-07-19','E',     '11000'),
('İrem',    'Doğan',   'irem.dogan@hotmail.com',  '532.234.56.78', 'Ankara',   '1993-11-08', 'K',      '8300');
GO

INSERT INTO Ham_Siparisler (MusteriID, UrunAdi, Miktar, BirimFiyat, SiparisTarihi, Durum) VALUES
-- Normal
(1,  'Laptop',       '2',  '15000 TL',    '2024-01-15',   'Tamamlandı'),
(2,  'Mouse',        '5',  '250',          '15/02/2024',   'tamamlandi'),
(3,  'Klavye',       '3',  'TL 450',       '2024.03.10',   'TAMAMLANDI'),

-- Geçersiz miktar
(4,  'Monitör',      '-1', '4500',         '2024-04-05',   'Tamamlandı'),
(5,  'Yazıcı',       'uc', '3500',         '2024-05-20',   'Beklemede'),

-- Geçersiz fiyat
(6,  'Laptop',       '1',  '-15000',       '2024-06-12',   'Tamamlandı'),
(7,  'Tablet',       '2',  'fiyat yok',    '2024-07-01',   'İptal'),

-- NULL değerler
(8,  NULL,           '3',  '500',          '2024-08-15',   'Tamamlandı'),
(9,  'Kulaklık',     NULL, '800',          '2024-09-22',   NULL),
(NULL,'Kamera',      '1',  '12000',        '2024-10-10',   'Beklemede'),

-- Tarih format tutarsızlığı
(1,  'SSD',          '4',  '1200',         'Ocak 2024',    'Tamamlandı'),
(2,  'RAM',          '2',  '600',          '20240301',     'Tamamlandı');
GO

-- Ham veri özeti
SELECT 'Ham_Musteriler' AS Tablo, COUNT(*) AS ToplamSatir FROM Ham_Musteriler
UNION ALL
SELECT 'Ham_Siparisler', COUNT(*) FROM Ham_Siparisler;
GO
