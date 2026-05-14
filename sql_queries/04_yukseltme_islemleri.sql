-- ADIM 4: Gerçek Yükseltme İşlemleri
-- BLM4522 - Proje 6: Veritabanı Yükseltme ve Sürüm Yönetimi

USE Northwind;

-- =============================================
-- 1. V1.1.0 - ESKİMİŞ VERİ TİPLERİNİ GÜNCELLE
-- =============================================

-- Önce mevcut durumu gör
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE DATA_TYPE IN ('ntext', 'text', 'image')
ORDER BY TABLE_NAME;

-- Categories tablosundaki Description kolonunu güncelle
ALTER TABLE Categories
ALTER COLUMN Description NVARCHAR(MAX);

-- Sürüm tablosuna kaydet
INSERT INTO DB_Surum_Takip 
    (SurumNo, DegisiklikAdi, DegisiklikTipi, Aciklama, UygulayanKisi, GeriAlmaSorgusu)
VALUES 
    ('v1.1.0', 'Categories.Description ntext→nvarchar(max)', 'COLUMN',
     'Eskimiş ntext veri tipi nvarchar(max) ile değiştirildi',
     SYSTEM_USER,
     'ALTER TABLE Categories ALTER COLUMN Description ntext');

-- =============================================
-- 2. V1.2.0 - YENİ KOLONLAR EKLE
-- =============================================

-- Customers tablosuna yeni kolonlar ekle
ALTER TABLE Customers
ADD Email NVARCHAR(100) NULL,
    GSM NVARCHAR(20) NULL,
    KayitTarihi DATETIME DEFAULT GETDATE();

-- Employees tablosuna yeni kolon ekle
ALTER TABLE Employees
ADD IsAktif BIT DEFAULT 1;

-- Sürüm tablosuna kaydet
INSERT INTO DB_Surum_Takip 
    (SurumNo, DegisiklikAdi, DegisiklikTipi, Aciklama, UygulayanKisi, GeriAlmaSorgusu)
VALUES 
    ('v1.2.0', 'Customers tablosuna yeni kolonlar eklendi', 'COLUMN',
     'Email, GSM, KayitTarihi kolonları eklendi',
     SYSTEM_USER,
     'ALTER TABLE Customers DROP COLUMN Email, GSM, KayitTarihi'),
    ('v1.2.0', 'Employees tablosuna IsAktif kolonu eklendi', 'COLUMN',
     'Çalışan aktiflik durumu takibi için kolon eklendi',
     SYSTEM_USER,
     'ALTER TABLE Employees DROP COLUMN IsAktif');

-- =============================================
-- 3. V1.3.0 - YENİ İNDEKSLER EKLE
-- =============================================

-- Sık sorgulanan kolonlara indeks ekle
CREATE NONCLUSTERED INDEX IX_Orders_OrderDate
ON Orders (OrderDate);

CREATE NONCLUSTERED INDEX IX_Orders_CustomerID
ON Orders (CustomerID)
INCLUDE (OrderDate, ShippedDate);

CREATE NONCLUSTERED INDEX IX_OrderDetails_ProductID
ON [Order Details] (ProductID)
INCLUDE (UnitPrice, Quantity);

-- Sürüm tablosuna kaydet
INSERT INTO DB_Surum_Takip 
    (SurumNo, DegisiklikAdi, DegisiklikTipi, Aciklama, UygulayanKisi, GeriAlmaSorgusu)
VALUES 
    ('v1.3.0', 'Orders tablosuna indeksler eklendi', 'INDEX',
     'OrderDate ve CustomerID kolonlarına indeks eklendi',
     SYSTEM_USER,
     'DROP INDEX IX_Orders_OrderDate ON Orders; DROP INDEX IX_Orders_CustomerID ON Orders');

-- =============================================
-- 4. V1.4.0 - YENİ STORED PROCEDURE EKLE
-- =============================================
GO
CREATE PROCEDURE sp_MusteriSiparisRaporu
    @MusteriID NVARCHAR(10)
AS
BEGIN
    SELECT 
        c.CustomerID,
        c.CompanyName,
        c.Email,
        COUNT(o.OrderID) AS ToplamSiparis,
        SUM(od.UnitPrice * od.Quantity) AS ToplamTutar,
        MAX(o.OrderDate) AS SonSiparisTarihi
    FROM Customers c
    LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
    LEFT JOIN [Order Details] od ON o.OrderID = od.OrderID
    WHERE c.CustomerID = @MusteriID
    GROUP BY c.CustomerID, c.CompanyName, c.Email;
END;
GO

INSERT INTO DB_Surum_Takip 
    (SurumNo, DegisiklikAdi, DegisiklikTipi, Aciklama, UygulayanKisi, GeriAlmaSorgusu)
VALUES 
    ('v1.4.0', 'sp_MusteriSiparisRaporu procedure eklendi', 'PROCEDURE',
     'Müşteri sipariş raporu için yeni stored procedure',
     SYSTEM_USER,
     'DROP PROCEDURE sp_MusteriSiparisRaporu');

-- =============================================
-- 5. TÜM SÜRÜM DEĞİŞİKLİKLERİNİ GÖZLEMLE
-- =============================================
SELECT 
    SurumNo,
    DegisiklikAdi,
    DegisiklikTipi,
    UygulayanKisi,
    UygulamaTarihi
FROM DB_Surum_Takip
ORDER BY SurumID;