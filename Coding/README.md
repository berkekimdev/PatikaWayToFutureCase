# Coding Aşaması

* Bir GNU/Linux dagitiminda Root diski kullanim (doluluk) orani %90’i gecinde uyari veren bir
Shell Script yazılımı.
* Shell Script çalıştırıldığında eğer root diskinin kullanım oranı  %90'ı geçtiyse uyarı verir eğer geçmediyse o anki kullanım oranını ekrana yazdırır. 


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




