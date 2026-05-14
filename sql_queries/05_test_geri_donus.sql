-- ADIM 5: Test ve Geri Dönüş Planı
-- BLM4522 - Proje 6: Veritabanı Yükseltme ve Sürüm Yönetimi

USE Northwind;

-- =============================================
-- 1. YÜKSELTMELERİ TEST ET
-- =============================================

-- Test 1: Yeni kolonlar doğru eklenmiş mi?
SELECT 
    COLUMN_NAME AS KolonAdi,
    DATA_TYPE AS VeriTipi,
    IS_NULLABLE AS NullOlabilirMi
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customers'
    AND COLUMN_NAME IN ('Email', 'GSM', 'KayitTarihi');

-- Test 2: Yeni indeksler oluşturulmuş mu?
SELECT 
    i.name AS IndexAdi,
    t.name AS TabloAdi,
    i.type_desc AS IndexTipi
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
WHERE i.name IN (
    'IX_Orders_OrderDate', 
    'IX_Orders_CustomerID',
    'IX_OrderDetails_ProductID'
);

-- Test 3: Stored Procedure çalışıyor mu?
EXEC sp_MusteriSiparisRaporu @MusteriID = 'ALFKI';

-- Test 4: Veri tipi güncellemesi doğru mu?
SELECT 
    COLUMN_NAME AS KolonAdi,
    DATA_TYPE AS VeriTipi
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Categories'
    AND COLUMN_NAME = 'Description';

-- Test 5: DDL Trigger değişiklikleri yakalamış mı?
SELECT 
    DegisiklikTipi,
    NesneAdi,
    DegisiklikYapanKisi,
    DegisiklikTarihi
FROM Sema_Degisiklik_Log
ORDER BY DegisiklikTarihi DESC;

-- =============================================
-- 2. GERİ DÖNÜŞ PLANI
-- =============================================

-- Geri alınabilir değişiklikleri listele
SELECT 
    SurumNo,
    DegisiklikAdi,
    DegisiklikTipi,
    GeriAlmaSorgusu
FROM DB_Surum_Takip
WHERE GeriAlınabilirMi = 1
ORDER BY SurumID DESC;

-- =============================================
-- 3. V1.2.0'I GERİ AL (örnek geri dönüş)
-- =============================================

-- Önce mevcut durumu gör (kolonlar var mı?)
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customers'
AND COLUMN_NAME IN ('Email', 'GSM', 'KayitTarihi');

-- Customers constraint'i kaldır
ALTER TABLE Customers
DROP CONSTRAINT DF__Customers__Kayit__1F98B2C1;

-- Customers kolonlarını kaldır
ALTER TABLE Customers
DROP COLUMN Email, GSM, KayitTarihi;

-- Employees constraint'i kaldır
ALTER TABLE Employees
DROP CONSTRAINT DF__Employees__IsAkt__208CD6FA;

-- Employees kolonunu kaldır
ALTER TABLE Employees
DROP COLUMN IsAktif;

-- Sürüm tablosuna geri alma kaydı ekle
INSERT INTO DB_Surum_Takip 
    (SurumNo, DegisiklikAdi, DegisiklikTipi, Aciklama, UygulayanKisi, GeriAlınabilirMi)
VALUES 
    ('v1.2.0-ROLLBACK', 'v1.2.0 geri alındı', 'ROLLBACK',
     'Customers ve Employees yeni kolonları kaldırıldı',
     SYSTEM_USER, 0);

-- =============================================
-- 4. GERİ ALMANIN BAŞARILI OLDUĞUNU KONTROL ET
-- =============================================

-- Boş gelmeli!
SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Customers'
AND COLUMN_NAME IN ('Email', 'GSM', 'KayitTarihi');

-- =============================================
-- 5. TÜM SÜREÇ SONUNDA SÜRÜM GEÇMİŞİNİ GÖR
-- =============================================
SELECT 
    SurumNo,
    DegisiklikAdi,
    DegisiklikTipi,
    UygulayanKisi,
    UygulamaTarihi
FROM DB_Surum_Takip
ORDER BY SurumID;