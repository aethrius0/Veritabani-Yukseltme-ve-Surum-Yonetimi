-- ADIM 3: DDL Trigger ile Şema Değişikliklerini Takip
-- BLM4522 - Proje 6: Veritabanı Yükseltme ve Sürüm Yönetimi

USE Northwind;

-- =============================================
-- 1. ŞEMA DEĞİŞİKLİK LOG TABLOSU OLUŞTUR
-- =============================================
CREATE TABLE Sema_Degisiklik_Log (
    LogID INT PRIMARY KEY IDENTITY,
    DegisiklikTipi VARCHAR(100),
    NesneAdi VARCHAR(200),
    NesneTipi VARCHAR(100),
    DegisiklikYapanKisi VARCHAR(100),
    DegisiklikTarihi DATETIME DEFAULT GETDATE(),
    SorguMetni NVARCHAR(MAX)
);

-- =============================================
-- 2. DDL TRIGGER OLUŞTUR
-- =============================================
CREATE TRIGGER TR_Sema_Degisiklik_Takip
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE,
    CREATE_INDEX, DROP_INDEX,
    CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE,
    CREATE_VIEW, ALTER_VIEW, DROP_VIEW
AS
BEGIN
    DECLARE @EventData XML = EVENTDATA();
    
    INSERT INTO Sema_Degisiklik_Log 
        (DegisiklikTipi, NesneAdi, NesneTipi, DegisiklikYapanKisi, SorguMetni)
    VALUES (
        @EventData.value('(/EVENT_INSTANCE/EventType)[1]', 'NVARCHAR(100)'),
        @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'NVARCHAR(200)'),
        @EventData.value('(/EVENT_INSTANCE/ObjectType)[1]', 'NVARCHAR(100)'),
        @EventData.value('(/EVENT_INSTANCE/LoginName)[1]', 'NVARCHAR(100)'),
        @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)')
    );
END;

-- =============================================
-- 3. DDL TRIGGER'I TEST ET
-- =============================================

-- Yeni tablo oluştur (trigger bunu yakalayacak)
CREATE TABLE Test_Tablo (
    TestID INT PRIMARY KEY IDENTITY,
    TestAdi VARCHAR(100),
    TestTarihi DATETIME DEFAULT GETDATE()
);

-- Tabloyu değiştir (trigger bunu yakalayacak)
ALTER TABLE Test_Tablo
ADD TestAciklama NVARCHAR(500);

-- Yeni bir index oluştur (trigger bunu yakalayacak)
CREATE INDEX IX_Test_TestAdi
ON Test_Tablo (TestAdi);

-- Stored Procedure oluştur (trigger bunu yakalayacak)
GO
CREATE PROCEDURE sp_Test_Procedure
AS
BEGIN
    SELECT * FROM Test_Tablo;
END;
GO

-- =============================================
-- 4. DEĞİŞİKLİK LOGLARINI GÖZLEMLE
-- =============================================
SELECT 
    LogID,
    DegisiklikTipi,
    NesneAdi,
    NesneTipi,
    DegisiklikYapanKisi,
    DegisiklikTarihi,
    LEFT(SorguMetni, 100) AS SorguBaslangici
FROM Sema_Degisiklik_Log
ORDER BY DegisiklikTarihi DESC;