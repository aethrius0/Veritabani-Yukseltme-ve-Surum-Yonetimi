-- ADIM 1: Mevcut Veritabanı Durumunu Belgeleme
-- BLM4522 - Proje 6: Veritabanı Yükseltme ve Sürüm Yönetimi

USE Northwind;

-- 1. Veritabanı bilgilerini gör
SELECT 
    name AS VeritabaniAdi,
    compatibility_level AS UyumlulukSeviyesi,
    collation_name AS Collation,
    create_date AS OlusturmaTarihi,
    state_desc AS Durum
FROM sys.databases
WHERE name = 'Northwind';

-- 2. Tüm tabloları listele
SELECT 
    TABLE_SCHEMA AS Sema,
    TABLE_NAME AS TabloAdi,
    TABLE_TYPE AS Tip
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- 3. Tüm kolonları ve veri tiplerini listele
SELECT 
    TABLE_NAME AS TabloAdi,
    COLUMN_NAME AS KolonAdi,
    DATA_TYPE AS VeriTipi,
    CHARACTER_MAXIMUM_LENGTH AS MaxUzunluk,
    IS_NULLABLE AS NullOlabilirMi
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- 4. Mevcut indeksleri listele
SELECT 
    t.name AS TabloAdi,
    i.name AS IndexAdi,
    i.type_desc AS IndexTipi
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
WHERE i.name IS NOT NULL
ORDER BY t.name;

-- 5. Mevcut stored procedure'leri listele
SELECT 
    name AS ProcedureAdi,
    create_date AS OlusturmaTarihi,
    modify_date AS DegistirmeTarihi
FROM sys.procedures
ORDER BY name;