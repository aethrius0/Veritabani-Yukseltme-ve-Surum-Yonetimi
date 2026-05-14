-- ADIM 2: Veritabanı Yükseltme Planı
-- BLM4522 - Proje 6: Veritabanı Yükseltme ve Sürüm Yönetimi

USE Northwind;

-- =============================================
-- 1. SÜRÜM TAKİP TABLOSU OLUŞTUR
-- =============================================
CREATE TABLE DB_Surum_Takip (
    SurumID INT PRIMARY KEY IDENTITY,
    SurumNo VARCHAR(20) NOT NULL,
    DegisiklikAdi VARCHAR(200) NOT NULL,
    DegisiklikTipi VARCHAR(50) NOT NULL, -- 'TABLE', 'COLUMN', 'INDEX', 'PROCEDURE'
    Aciklama NVARCHAR(500),
    UygulayanKisi VARCHAR(100),
    UygulamaTarihi DATETIME DEFAULT GETDATE(),
    GeriAlınabilirMi BIT DEFAULT 1,
    GeriAlmaSorgusu NVARCHAR(MAX)
);

-- 2. Mevcut sürümü kaydet
INSERT INTO DB_Surum_Takip 
    (SurumNo, DegisiklikAdi, DegisiklikTipi, Aciklama, UygulayanKisi, GeriAlınabilirMi)
VALUES 
    ('v1.0.0', 'Baslangic Surumu', 'INITIAL', 
     'Northwind veritabanı başlangıç sürümü', 
     SYSTEM_USER, 0);

-- 3. Sürüm tablosunu kontrol et
SELECT * FROM DB_Surum_Takip;

-- =============================================
-- 4. YÜKSELTİLECEK ALANLARI TESPİT ET
-- =============================================

-- Eski veri tiplerini bul (ntext, text, image gibi eskimiş tipler)
SELECT 
    TABLE_NAME AS TabloAdi,
    COLUMN_NAME AS KolonAdi,
    DATA_TYPE AS EskiVeriTipi
FROM INFORMATION_SCHEMA.COLUMNS
WHERE DATA_TYPE IN ('ntext', 'text', 'image')
ORDER BY TABLE_NAME;

-- NULL olabilen kritik kolonları bul
SELECT 
    TABLE_NAME AS TabloAdi,
    COLUMN_NAME AS KolonAdi,
    DATA_TYPE AS VeriTipi
FROM INFORMATION_SCHEMA.COLUMNS
WHERE IS_NULLABLE = 'YES'
    AND COLUMN_NAME LIKE '%ID%'
ORDER BY TABLE_NAME;

-- =============================================
-- 5. YÜKSELTİLECEK NOKTALARI RAPORLA
-- =============================================
SELECT 
    'Eskimiş Veri Tipi' AS SorunTipi,
    TABLE_NAME AS TabloAdi,
    COLUMN_NAME AS KolonAdi,
    DATA_TYPE AS Detay
FROM INFORMATION_SCHEMA.COLUMNS
WHERE DATA_TYPE IN ('ntext', 'text', 'image')
UNION ALL
SELECT 
    'İndeks Eksik' AS SorunTipi,
    t.name AS TabloAdi,
    '' AS KolonAdi,
    'İndeks sayısı: ' + CAST(COUNT(i.index_id) AS VARCHAR) AS Detay
FROM sys.tables t
LEFT JOIN sys.indexes i ON t.object_id = i.object_id
GROUP BY t.name
HAVING COUNT(i.index_id) < 2
ORDER BY SorunTipi;