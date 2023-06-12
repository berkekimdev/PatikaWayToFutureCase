# Application Configuration & Deployment ( IP : 18.159.16.101:5000 )

##  Dockerfile Oluşturma

### 1- İlk olarak flask app'imizi bilgisayarımıza çekmemiz gerekiyor.

* Terminali açın ve projeyi klonlamak istediğiniz bir dizine geçin. Örneğin, ana dizine gitmek için aşağıdaki komutu kullanabilirsiniz:  
`` cd Downloads ``
* Klonlamak istediğiniz projenin GitHub deposunun URL'sini kopyalayın. 
* Terminalde aşağıdaki komutu kullanarak projeyi klonlayın:  
``git clone https://github.com/yikiksistemci/patika-bootcamp-flask``

### 2- requirements.txt oluşturma.
* Terminali açın ve Flask uygulamasının bulunduğu dizine gidin.
* requirements.txt oluşturun. Bunu isterseniz terminal üzerinden `` touch requirements.txt`` diyerek yapabilirsiniz.
* Dosyanın içeriğini düzenlemek için bir metin düzenleyici kullanabilirsiniz. Örneğin, "nano" metin düzenleyicisini kullanmak için aşağıdaki komutu kullanabilirsiniz:
``nano dosyaadi.txt``
* Açtığınız yere ``Flask==2.3.2`` yazınız.Flask uygulamanızın belirli bir sürümünün yüklenmesini istediğinizi belirtir. Bu durumda, 2.3.2 sürümünü kullanmak istediğinizi ifade eder.
* Metin düzenleyicisinde değişiklikleri kaydetmek ve çıkmak için genellikle Ctrl + X kombinasyonunu kullanabilirsiniz. Ardından, değişiklikleri kaydetmek için "Y" tuşuna basın ve Enter tuşuna basarak metin düzenleyiciden çıkın.


### 3- Dockerfile oluşturma

* Bir metin düzenleyici açın ve yeni bir dosya oluşturun. Dosyayı "Dockerfile" olarak adlandırın. Dockerfile dosyası, herhangi bir metin düzenleyiciyle oluşturulabilir, örneğin "nano", "vi", "gedit" gibi.

* Oluşturduğunuz Dockerfile'a  şu kodları kopyalayın.  

```
FROM python:3.8-slim-buster as builder

WORKDIR /app

RUN adduser --disabled-password --gecos '' appuser

USER appuser

COPY --chown=appuser:appuser requirements.txt requirements.txt

RUN pip3 install --user -r requirements.txt

FROM python:3.8-slim-buster as runner

WORKDIR /app

RUN adduser --disabled-password --gecos '' appuser

USER appuser

COPY --from=builder --chown=appuser:appuser /home/appuser/.local /home/appuser/.local
COPY --chown=appuser:appuser . /app

ENV PATH=/home/appuser/.local/bin:$PATH

CMD ["python3", "-m", "flask", "run", "--host=0.0.0.0"]
```

### **Güvenlik ve Performans**
* Docker image'ımızı oluştururken  güvenlik ve performans konusuna dikkat etmeliyiz.
* Güvenlik için **NON ROOT**  user kullanımı tercih ettim. Bu nedir diye sorarsak Docker konteynerlerinde varsayılan olarak süreçler root (kök) kullanıcısı kimliğiyle çalışır. Ancak, root ayrıcalıklarına sahip bir süreç, bir güvenlik açığı söz konusu olduğunda potansiyel olarak daha büyük riskler oluşturabilir. Bu nedenle, birçok güvenlik en iyi uygulaması, Docker konteynerlerinin root yerine non-root kullanıcı kimliğiyle çalışmasını önerir.
* Performans ve boyut için slim-buster ve **Multi-Stage Build** kullandım. Multi-stage build, Dockerfile içinde birden fazla yapı aşamasının kullanılmasını sağlar. Bu sayede, gereksinimleri oluşturma ve daha sonra nihai üretim görüntüsünü oluşturma gibi farklı aşamaları bir arada kullanabiliriz. Multi-stage build, son üretim görüntüsünü daha küçük boyutlarda ve gereksinimlere göre optimize edilmiş şekilde elde etmemizi sağlar.
* İlk versiyonuna göre bu sayede yaklaşık 8MB daha az bir boyutta image oluşturdum.

<img width="1200" alt="boyut8mb" src="https://github.com/sudkostik/ApplicationConfigurationDeployment/assets/104645493/fd79941c-9b76-456e-bcad-1333420c786d">

### **Dockerfile'da yazan kodlar ne işe yarıyor**
``FROM python:3.8-slim-buster as builder``
Bu komut, Docker imajının temelini oluşturacak olan başka bir Docker imajını belirtir. Burada, Python 3.8 sürümünün 'slim-buster' varyantını temel alıyoruz. 'Slim-buster' varyantı, Debian Buster tabanlı ve sadece Python 3.8 yüklemesi içeren bir imajdır ve boyutu azdır. Ayrıca bu aşamayı 'builder' olarak adlandırıyoruz. Bu, birden fazla aşamalı bir Docker imajı oluştururken bu aşamayı daha sonra referans alabilmemizi sağlar.

``WORKDIR /app``
Bu komut, Docker konteynerindeki çalışma dizinini '/app' olarak belirler. Bu, konteynerdeki komutların bu dizin içinde çalışacağını belirtir.

``RUN adduser --disabled-password --gecos '' appuser``
Bu komut, 'appuser' adında bir kullanıcı oluşturur. Bu kullanıcının şifresi devre dışı bırakılmıştır ('--disabled-password') ve bu kullanıcı için ek bilgi girişi yapılmasına gerek yoktur ('--gecos ""').

``USER appuser``
Bu komut, Docker imajı içerisindeki sonraki komutların 'appuser' kullanıcısı tarafından çalıştırılacağını belirtir.

``COPY --chown=appuser:appuser requirements.txt requirements.txt``
Bu komut, Docker imajını oluşturan kişinin yerel dosya sisteminden 'requirements.txt' dosyasını konteynerin içine '/app' dizinine kopyalar. Dosyanın sahibi ve grubu 'appuser' olarak belirlenir.

``RUN pip3 install --user -r requirements.txt``
Bu komut, 'requirements.txt' dosyasında belirtilen Python bağımlılıklarını kurar.

``FROM python:3.8-slim-buster as runner``
Bu, ikinci aşamadır ve yine Python 3.8 sürümünün 'slim-buster' varyantını temel alıyoruz. Bu aşamayı 'runner' olarak adlandırıyoruz.

``WORKDIR /app, RUN adduser --disabled-password --gecos '' appuser, ve USER appuser``
Bu komutlar, ilk aşamada yaptıklarımızın aynısını yapar: çalışma dizinini belirler, bir kullanıcı oluşturur ve bu kullanıcıyı aktif kullanıcı olarak belirler.

``COPY --from=builder --chown=appuser:appuser /home/appuser/.local /home/appuser/.local``
Bu komut, ilk aşamadaki 'builder' imajından '/home/appuser/.local' dizinini kopyalar. Bu dizin, ilk aşamada kurduğumuz Python paketlerini içerir.

``COPY --chown=appuser:appuser . /app``
Bukomut, Docker imajını oluşturan kişinin yerel dosya sisteminden mevcut dizini ('.') konteynerin içine '/app' dizinine kopyalar. Dosyaların sahibi ve grubu 'appuser' olarak belirlenir.

``ENV PATH=/home/appuser/.local/bin:$PATH``
Bu komut, konteynerin PATH çevre değişkenini günceller ve '/home/appuser/.local/bin' dizinini ekler. Bu, ilk aşamada kurduğumuz Python paketlerinin komutlarının doğrudan kullanılabilir olmasını sağlar.

``CMD ["python3", "-m", "flask", "run", "--host=0.0.0.0"]``
* Bu komut, konteyner çalıştırıldığında varsayılan olarak çalıştırılacak komutu belirler. Burada, Flask uygulamasını başlatmak için Python 3'ün '-m' (module) seçeneğini kullanıyoruz ve Flask'ı tüm ağ arayüzlerinden erişilebilir hale getiriyoruz ('--host=0.0.0.0').

* Bu Dockerfile, uygulamanın bağımlılıklarını kurmak ve uygulamayı çalıştırmak için iki aşamalı bir süreç kullanır. İlk aşama ('builder'), uygulamanın Python bağımlılıklarını kurar. İkinci aşama ('runner'), bu bağımlılıkları ve uygulama kodlarını içeren yeni bir Docker imajı oluşturur ve uygulamayı çalıştırır. Bu yaklaşım, nihai imajın boyutunu azaltmaya yardımcı olur çünkü sadece uygulamanın çalıştırılmasına gerek duyan dosyaları ve bağımlılıkları içerir.


## Dockerhub
* Docker Container Registries (Docker Konteyner Kaynak Depoları) hizmetidir. DockerHub, Docker konteynerlerinin paylaşıldığı, depolandığı ve dağıtıldığı bir platformdur. Dockerhub sayesinde oluşturacağımız image'ı  dockerhub'a yükleyip uzaktaki Cloud sunucumuza indirip kurabileceğiz.

* Dockerhub'ta ilk olarak bir repository yaratmamız lazım. Buna çok dikkat etmelisiniz çünkü oluşturacağımız image ile aynı ada sahip olmalı. Ben bootcamp adında bir repository oluşturuyorum ve sudkostik/bootcamp adıyla image'ımı oluşturucam.
* 

<img width="1039" alt="dockerhub" src="https://github.com/sudkostik/ApplicationConfigurationDeployment/assets/104645493/c6ee1bb0-6cc2-4d74-8c1c-a4633a2f2787">

### 1- Docker Image Oluşturma
* Dockerfile ve flask app'imizin bulunduğu klasöre  terminal üzerinden gidiyoruz.
``sudo docker build -t <imaj-adı>:<sürüm> . `` formatında docker image'ımızı oluşturmamız lazım.  

``sudo docker build -t sudkostik/bootcamp:0.0.1 .``  gibi yazarak docker image'ınızı bu formatta oluşturun.

<img width="1200" alt="dockerimageolusturma" src="https://github.com/sudkostik/ApplicationConfigurationDeployment/assets/104645493/ca335caa-f8a6-4e15-8e91-80ec783665eb">

### 2- Docker Image'ınızı Dockerhub'a Yükleme
* İlk olarak Dockerhub'a giriş yapmalısınız.
* Terminal üzerinden``docker login`` diyerek kullanici adı ve şifrenizi giriniz.
* Ardından dockerhub'a oluşturduğunuz docker image'ı pushlamak için şu komutları kullanın
`` docker push <kullanıcı-adı>/<imaj-adı>:<sürüm>`` 

<img width="800" alt="dockerpush1" src="https://github.com/sudkostik/ApplicationConfigurationDeployment/assets/104645493/016a0c99-1480-46b3-a379-2258df8e3cdb">

* Artık docker image'ımızı ssh ile bağlanıp sunucumuza indirip kurabiliriz.


## SSH ile Sunucu yapılandırması 

* AWS üzerinden Instance'ımızı buluyoruz ve connect diyoruz.
* Önceden indirdiğimiz Key Pair'imiz ile sunucumuza bağlanacağız.
* Key Pairimizin bulunduğu klasöre gidip terminalden ilk olarak ``chmod 400 yourkeypair.pem`` çalıştırıyoruz.
* Bundan sonra ssh-i olarak yazan kodumuzu kopyalayıp terminale yazıp çalıştırıyoruz. Bu işlemde sunucumuza bağlanıyoruz.


<img width="799" alt="ssh15" src="https://github.com/sudkostik/ApplicationConfigurationDeployment/assets/104645493/f0df1ec8-6579-4ef9-a749-0958d64a905f">

**Şu komutları sırayla çalıştırmanız gerekiyor.**

* sudo -su (root'a geçiş yapıyoruz)
* yum update
* yum install nginx -y (Test edebilmek için kuruyoruz)
* systemctl start nginx (nginx'i çalıştırıyoruz)
* sudo yum install docker (docker kurulumu)
* sudo service docker start

* Artık sitemize giriş yapabiliriz : IP : 18.159.16.101 


<img width="828" alt="nginxgiris" src="https://github.com/sudkostik/ApplicationConfigurationDeployment/assets/104645493/7d8f44fc-bc9e-4caa-9b78-f1a165b0131c">


### Docker Image Kurulumu
* İlk olarak docker image'ımızı dockerhub üzerinden pull ediyoruz.
`` docker pull sudkostik/bootcamp:0.0.5 ``
* docker images yazarak indirilip indirilmediğini kontrol edebilirsiniz.
* Çalıştırma aşamasında ``` docker run -d -p 5000:5000 sudkostik/bootcamp:0.0.5 `` yazarak artık application'ımızı çalıştırıyoruz.
* Artık application'ımıza IP'mizin 5000. portundan erişebiliriz  IP : http://18.159.16.101:5000



<img width="424" alt="5000" src="https://github.com/sudkostik/ApplicationConfigurationDeployment/assets/104645493/3e3767b3-5ee0-4f28-a99f-9cd8532e4689">








