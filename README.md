# BLM4522 - Proje 6: Veritabanı Yükseltme ve Sürüm Yönetimi

## Proje Hakkında
Bu proje, Northwind veritabanı üzerinde sürüm yönetimi ve 
yükseltme tekniklerinin uygulanmasını kapsamaktadır.

## Kullanılan Teknolojiler
- Microsoft SQL Server 2025 Developer Edition
- SQL Server Management Studio (SSMS)
- Northwind örnek veritabanı

## Yapılan Çalışmalar

### Adım 1: Mevcut Veritabanı Durumunu Belgeleme
- Veritabanı bilgileri (uyumluluk seviyesi, collation) listelendi
- Tüm tablolar ve kolonlar belgelendi
- Mevcut indeksler ve stored procedure'ler listelendi

### Adım 2: Veritabanı Yükseltme Planı
- DB_Surum_Takip tablosu oluşturuldu
- Eskimiş veri tipleri (ntext, text, image) tespit edildi
- Yükseltilecek alanlar raporlandı
- v1.0.0 başlangıç sürümü kayıt altına alındı

### Adım 3: DDL Trigger ile Şema Değişikliklerini Takip
- Sema_Degisiklik_Log tablosu oluşturuldu
- TR_Sema_Degisiklik_Takip trigger'ı oluşturuldu
- CREATE, ALTER, DROP işlemleri otomatik loglanıyor
- Trigger test edildi, tüm değişiklikler yakalandı

### Adım 4: Gerçek Yükseltme İşlemleri
- v1.1.0: Categories.Description ntext→nvarchar(max) güncellendi
- v1.2.0: Customers tablosuna Email, GSM, KayitTarihi eklendi
- v1.2.0: Employees tablosuna IsAktif kolonu eklendi
- v1.3.0: Orders ve OrderDetails tablolarına indeksler eklendi
- v1.4.0: sp_MusteriSiparisRaporu stored procedure eklendi
- Tüm değişiklikler sürüm tablosuna kaydedildi

### Adım 5: Test ve Geri Dönüş Planı
- Tüm yükseltmeler test edildi
- Yeni kolonlar, indeksler ve stored procedure doğrulandı
- DDL Trigger'ın değişiklikleri yakaladığı doğrulandı
- v1.2.0 ROLLBACK örneği yapıldı
- Kolonlar başarıyla geri alındı ve doğrulandı
- Tüm sürüm geçmişi kayıt altında

## Dosya Yapısı
├── adim1_mevcut_durum.sql
├── adim2_yukseltme_plani.sql
├── adim3_ddl_trigger.sql
├── adim4_yukseltme_islemleri.sql
├── adim5_test_geri_donus.sql
└── README.md

## Sürüm Geçmişi
| Sürüm | Değişiklik | Tip |
|-------|------------|-----|
| v1.0.0 | Başlangıç sürümü | INITIAL |
| v1.1.0 | Eskimiş veri tipi güncellendi | COLUMN |
| v1.2.0 | Yeni kolonlar eklendi | COLUMN |
| v1.3.0 | İndeksler eklendi | INDEX |
| v1.4.0 | Stored Procedure eklendi | PROCEDURE |
| v1.2.0-ROLLBACK | Geri dönüş yapıldı | ROLLBACK |

## Sonuçlar
- DDL Trigger ile tüm şema değişiklikleri otomatik loglandı
- Sürüm takip tablosu ile değişiklikler belgelendi
- Başarılı rollback ile geri dönüş planı doğrulandı
