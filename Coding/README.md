# Coding Aşaması

* Bir GNU/Linux dagitiminda Root diski kullanim (doluluk) orani %90’i gecinde uyari veren bir
Shell Script yazılımı.
* Shell Script çalıştırıldığında eğer root diskinin kullanım oranı  %90'ı geçtiyse uyarı verir eğer geçmediyse o anki kullanım oranını ekrana yazdırır.  
*  **Kullanıcının  bu  uyarıyı sürekli terminalden göremeyeceğini varsayarsak ekstra kod eklemeleri yapabiliriz. Mail göndererek kullancıyı bilgilendirme işlemi en aşağıya yazıldı.** - [Mail Gönderme](https://github.com/sudkostik/PatikaWayToFutureCase/blob/main/Coding/README.md#mail-g%C3%B6ndererek-kullan%C4%B1c%C4%B1y%C4%B1-s%C3%BCrekli-uyarma)



## Kurulum
* Debian 11 gibi bir GNU/Linux dağıtımını sanal makinanıza veya bilgisayarınıza kurunuz.
* nano metin düzenleycisini indirin.
``` 
sudo su 
apt install nano 
```
## Programlama Süreci

* Metin düzenleyici olarak "nano" veya "vim" gibi bir düzenleyici kullanarak yeni bir dosya oluşturun.  

1- Ardından disk_usage.sh adında bir dosya oluşturalım:


```
nano disk_usage.sh
```  
2- Düzenleyicide, aşağıdaki Shell Script kodlarını yazın:

``` 
#!/bin/bash

check_disk_usage() {
	local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
	if [ $disk_usage -gt 90 ]; then
		echo "Uyarı: Root diskinin kullanım oranı $disk_usage%'ı geçti!"
	else
		echo "Root diski kullanım oranı şu anda $disk_usage%, %90'ı geçmedi."
	fi
}

check_disk_usage
``` 
*  "check_disk_usage" fonksiyonu root diskinin kullanım oranını kontrol eder ve uygun mesajları yazdırır. Son satırda, fonksiyon çağrılır ve script çalıştırıldığında disk kullanım oranı kontrol edilir.

3- Shell Script'i kaydedin ve çıkın. Eğer "nano" kullanıyorsanız, Ctrl+X tuş kombinasyonunu kullanarak kaydedip çıkabilirsiniz.
4- Dosyayı çalıştırılabilir hale getirin.
```
chmod +x disk_usage.sh
```
5- Script'i çalıştırın:
```
./disk_usage.sh
```
* Terminalde oluşacak görüntü şuna benzer olacaktır. 

![](https://github.com/sudkostik/PatikaWayToFutureCase/blob/main/Coding/CodingImages/UsageReport.png)  

## Kullanılan Kodların Açıklamaları
`(#!/bin/bash `: Bu, betiğin yorumlanması gereken dilin Bash olduğunu belirtir. Bu, genellikle betik dosyalarının en üstünde bulunur ve betiğin nasıl çalıştırılacağını belirler.

`check_disk_usage fonksiyonu`: Bu, root diskinin doluluk oranını kontrol eden bir fonksiyon oluşturur.

`local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')`: Bu satır, root diskinin doluluk oranını hesaplar ve sonucu disk_usage değişkenine atar.  
`df -h / `: Bu komut, "/" yani root diskinin disk kullanım bilgisini human-readable formatında (yani insanların anlayabileceği bir biçimde, GB, MB, KB gibi) verir.  
`awk 'NR==2 {print $5}'`: Bu komut, df komutunun çıktısını işler. NR==2 ifadesi ile df çıktısının ikinci satırını seçer ve {print $5} ile beşinci sütunu (diskin doluluk oranını) yazdırır.   
`tr -d '%'`: Bu komut, awk'ın çıktısından yüzde sembolünü çıkarır. Böylece disk doluluk oranını bir sayı olarak işleyebiliriz.   
`if [ $disk_usage -gt 90 ]; then ... fi`: Bu satırlar, disk_usage değişkeninin 90'dan büyük olup olmadığını kontrol eder. Eğer büyükse, "Uyarı: Root diskinin kullanım oranı $disk_usage%'ı geçti!" mesajını yazdırır. Eğer 90'dan büyük değilse, "Root diski kullanım oranı şu anda $disk_usage%, %90'ı geçmedi." mesajını yazdırır. 

`check_disk_usage` : Bu satır, check_disk_usage fonksiyonunu çağırır. Bu, betiğin ana işlevini gerçekleştirir. Fonksiyon çağrıldığında, disk kullanımını kontrol eder ve uygun mesajı yazdırır.

## Mail Göndererek Kullanıcıyı Sürekli Uyarma
* Kullanıcının sürekli olarak bilgilendirilmesini istiyorsak mail üzerinden Root diski kullanım oranı %90'ı geçerse mail göndermesini sağlayan bir shell script yazabiliriz. Az önce yazdığımız koda sadece  ``| mail -s "Disk Usage Alert" user@example.com`` eklememiz yeterli.  
* Bu Shell Script'in sürekli arka planda çalışması gerekiyor ki kullanıcıyı uyarabilsin. En alt kısımda bunu nasıl yapabileceğinizi anlattım.

### Mail gönderen Shell Script
```
#!/bin/bash

check_disk_usage() {
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
    if [ "$disk_usage" -gt 90 ]; then
        echo "Uyarı: Root diskinin kullanım oranı $disk_usage%'ı geçti!" | mail -s "Disk Usage Alert" user@example.com
    else
        echo "Root diski kullanım oranı şu anda $disk_usage%, %90'ı geçmedi."
    fi
}

check_disk_usage
``` 
### Arka Planda Shell Script Çalıştırılması
* Eğer bu dosyanın sürekli olarak arka planda çalışmasını istiyorsanız, systemd hizmet dosyası oluşturmanız gerekmektedir.
* ``/etc/systemd/system/`` dizininde disk_kullanimi.service adında bir dosya oluşturun. Örneğin, ``sudo nano /etc/systemd/system/disk_kullanimi.service`` komutunu kullanarak bir metin düzenleyici açabilirsiniz.

* Aşağıdaki hizmet tanımını hizmet dosyasına yapıştırın:
```

[Unit]
Description=Disk Kullanımı Kontrolü
After=network.target

[Service]
ExecStart=/path/to/disk_kullanimi.sh
Restart=always

[Install]
WantedBy=multi-user.target

```
* ExecStart satırındaki /path/to/disk_kullanimi.sh ifadesini, "disk_kullanimi.sh" dosyasının gerçek yolunu gösteren doğru bir yol ile değiştirin.

* Dosyayı kaydedin ve kapatın.

* Hizmeti etkinleştirin ve başlatın:

```
sudo systemctl enable disk_kullanimi.service
sudo systemctl start disk_kullanimi.service

```
* Artık script, sistem başlangıcında otomatik olarak başlayacak ve sürekli arka planda çalışmaya devam edecektir. Root diski kullanım oranı %90'ı geçtiğinde script, belirttiğiniz e-posta adresine bir uyarı mesajı gönderecektir.

* Hizmeti durdurmak isterseniz, aşağıdaki komutu kullanabilirsiniz:

``` 
sudo systemctl stop disk_kullanimi.service

```





