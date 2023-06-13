## Infrastructure Management ( IP : 18.159.16.101:5000 ) 
* 2 Private ve 2 Public Subnet’i bulunan bir VPC yaratılması. Bu yaratacaginiz Subnet’lerin IP block'u 62 tane host alacabilecek.
* Bir tane EC2 Instance (makina) ayaga kaldırılıp bu makina Auto Scaling Group icinde olacak.
* Bu yarattiginiz EC2’nun önüne bir Application Load Balancer konumlanacak.


## İlk aşama VPC ve Subnetlerin yaratılması

* AWS Management Console'a giriş yapın ve Services altından VPC'yi seçin.
* Sol tarafta yer alan 'Your VPCs' seçeneğini tıklayın ve ardından 'Create VPC' seçeneğini seçin.
* Açılan formda, VPC için bir isim belirleyin ve IPv4 CIDR block olarak '10.0.0.0/16' (istersek fazla ip meşgul etmemek için 4 farklı subnete 62 host verebilecek minimum değere yakın bir aralık verebiliriz 10.0.0.0/22 gibi fakat böyle tercih ettim. Subnet kısmında ip bloklarına dikkat ettim) değerini girin ve 'Create' butonuna tıklayın.
### **Oluşmuş VPC**
![](https://github.com/sudkostik/PatikaWayToFutureCase/blob/main/Infrastructure/InfrasImages/olusmusvpc.png)

* VPC oluşturulduktan sonra, sol taraftaki 'Subnets' seçeneğine tıklayın ve 'Create subnet' butonuna tıklayın.
* Oluşturulan VPC'yi seçin, 2 private ve 2 public subnet için birer isim belirleyin ve CIDR bloğu olarak hepsine ayrı ip bloğu ve değerini girin. Bu, size 62 adet kullanılabilir IP adresi sağlasın. Bu işlemi toplamda 4 kere tekrar edin.IP bloğu atarken en çok dikkat etmeniz gereken noktalar şunlardır :  

**IP bloklarını en az 62 host alacak şekilde seçmemiz söylenmiş. Normalde ilk (network) adresi ve son (broadcast) adresi kullanılmaz. /26 seçersek normalde bu kurala uyar ve bize 64 ip verir ve ikisini kullanamazsak yeterli olur. Burda oluşan sorun AWS kendi bu IP'lerden 3 tanesini daha kullanıyor. O yüzden 59 tane kullanılabilir host kalıyor. Bu yüzden en minimum seviyede, fazladan ip bırakmayıp tasarruflu olmak için en yakın /25 bloğunu seçebiliriz.**  

**Availability Zone'u dikkatli seçmeliyiz. AWS'de subnetleri "eu-central-1a" ve "eu-central-1b" gibi farklı bölgeye ayırmak, yüksek erişilebilirlik, yedeklilik ve dağıtım esnekliği gibi faydalar sağlar.  Biz Frankfurt eu-central-1 seçiyoruz. Private ve Public subnetlerimizi adlandırırken bunları network grouplarına göre adlandırıyoruz. Mesela patika-wtf-public-1a subnetinin Availability Zone'u eu-central-1a seçtik. Diğer bir public subnetimiz yani patika-wtf-public-1b için eu-central-1b.Bu işlemleri private subnetler içinde yapıyoruz. patika-wtf-private-1a için eu-central-1a , patika-wtf-private-1b için eu-central-1b.**  

* Her biri için farklı CIDR blokları vermeliyiz (örneğin  public-1a 10.0.20.0/25 , public-1b 10.0.21.0/25 , private-1a 10.0.10.0/25 , private-1b 10.0.11.0/25 gibi ).
* İki subnet'i public, diğer ikisini private yapmak için, subnet detaylarında 'Modify auto-assign IP settings' seçeneğine tıklayın ve 'Enable auto-assign public IPv4 address' seçeneğini işaretleyin. Bu *işlemi sadece public yapmak istediğiniz subnet'ler için yapın.
 ### **Oluşan Bütün Subnetlerimiz**
 ![](https://github.com/sudkostik/PatikaWayToFutureCase/blob/main/Infrastructure/InfrasImages/olusmusbutunsubnet.png)

##  Internet Gateway VPC kaynaklarının halka açık IP adresleriyle İnternete bağlanması.
**İnternet Gateway, VPC içindeki kaynaklara, halka açık IP adreslerini kullanarak İnternet'e erişim sağlar. Bu sayede VPC'deki özel sunucular, uygulamalar veya hizmetler, kullanıcılara veya diğer İnternet kaynaklarına erişebilir.**
* VPC yönetim panelinde sol menüden "Internet Gateways" (İnternet Ağ Geçitleri) seçeneğini bulun ve tıklayın.

* Üst panelde "Create internet gateway" (İnternet ağ geçidi oluştur) düğmesini tıklayın.

* İnternet Gateway için bir ad belirleyin  ve "Create" düğmesine tıklayın.

* Oluşturulan Internet Gateway'in ayrıntıları görüntülenecektir. Internet Gateway, "Actions" (Eylemler) düğmesini kullanarak VPC'nize Attach düğmesiyle bağlayın.
 ### **Internet Gateways**
 
 ![](https://github.com/sudkostik/PatikaWayToFutureCase/blob/main/Infrastructure/InfrasImages/internetgateway.png)


## Route Tables Oluşturulması
**Route Tables, bir Amazon Virtual Private Cloud (VPC) içindeki trafik yönlendirmesini kontrol etmek için kullanılan bileşenlerdir. Route Tables, VPC içindeki alt ağlara veya alt ağa bağlı kaynaklara yönlendirme kuralları sağlar. Ayrıca, Internet Gateway, Sanal Özel Ağ (VPN) bağlantıları, NAT (Network Address Translation) ağ geçitleri gibi diğer ağ bileşenleriyle iletişimi sağlar.**

### **Public Route Table** 
* VPC yönetim panelinde sol menüden "Route Tables" (Yönlendirme Tabloları) seçeneğini bulun ve tıklayın.
* "Create" (Oluştur) düğmesini tıklayın. Public ve Private için iki farklı route table oluşturmalıyız. İlkini patika-wtf-public-rb diye isimlendirin. Subnet associations kısmından edit subnet associations'a tıklayarak public subnetlerimizi ekliyoruz. Edit routes diyerek Destination'u  0.0.0.0/0 (Anywhere) olan Internet gateway'imizi bağlayarak public subnetlerimizi internete açıyoruz.  
![](https://github.com/sudkostik/PatikaWayToFutureCase/blob/main/Infrastructure/InfrasImages/public%20route%20table.png)  


**Private route table'ımızı oluşturmadan önce NAT Gateway oluşturmamız lazım.Bu sayede private subnetlerimiz  halka açık İnternet'e erişebilmesini sağlayacak.**  
 #### **NAT Gateways**  

* VPC yönetim panelinde sol menüden "NAT Gateways" (NAT Geçitleri) seçeneğini bulun ve tıklayın.

* "Create NAT Gateway" (NAT Geçidi oluştur) düğmesini tıklayın.

* İlgili VPC'yi ve halka açık alt ağı (Public subnet) seçin, çünkü NAT Gateway halka açık alt ağlarda kullanılır.

* Etkinleştirmek istediğiniz Elastic IP adresini seçin (Allocate Elastic IP) veya yeni bir tane oluşturun.

* "Create NAT Gateway" (NAT Geçidi oluştur) düğmesini tıklayın.

### **Private Route Table**  
* Private subnetlerimiz için ise patika-wtf-private-rb adında bir route table oluşturuyoruz. Subnet associations kısmından edit subnet associations diyerek private subnetlerimizi ekliyoruz. Private subnetlerimizi internete direkt açmayacağız. Onun yerine Bir NAT gateway oluşturarak public subnetlerle iletişim kurarak internete bağlanmalarını sağlayacağız.Oluşturduğumuz NAT gateway'ini Edit Routes diyerek Destination'u 0.0.0.0/0 (Anywhere) ve Target'ını oluşturacağımız NAT'ı seçerek oluşturuyoruz.
![](https://github.com/sudkostik/PatikaWayToFutureCase/blob/main/Infrastructure/InfrasImages/privateroutetable.png)


## Network ACL 
**Network ACL (Access Control List), Amazon Virtual Private Cloud (VPC) üzerinde gelen ve giden ağ trafiğini kontrol etmek için kullanılan bir güvenlik bileşenidir. Network ACL'ler, VPC seviyesinde çalışır ve alt ağlar arasındaki trafiği yönetir.**

* VPC yönetim panelinde sol menüden "Network ACLs" (Ağ ACL'leri) seçeneğini bulun ve tıklayın.

* "Create network ACL" (Ağ ACL'si oluştur) düğmesini tıklayın.

* Oluşturulan Network ACL'ye patika-wtf-nacl ismini verin ve oluşturduğumuz VPC'yi seçin.

* Oluşturulan Network ACL'ye giriş ve çıkış trafiği için kurallar eklemek için "Inbound Rules" (Giriş Kuralları) ve "Outbound Rules" (Çıkış Kuralları) düğmelerini tıklayın.
* Subnet Associations kısmından edit Subnet Associations diyerek bütün subnetlerimizi ekliyoruz.

![](https://github.com/sudkostik/PatikaWayToFutureCase/blob/main/Infrastructure/InfrasImages/networkacl%20alt%C4%B1%20subnet.png)


* Her bir kural için aşağıdaki bilgileri sağlayın:
**Kaynak veya hedef IP adresleri
Protokol (örneğin, TCP, UDP, ICMP)
Bağlantı noktası aralığı
İzin veya reddetme
Kuralları ekledikten sonra "Save" (Kaydet) düğmesini tıklayın.**
#### **Inbound Rules** 
![](https://github.com/sudkostik/PatikaWayToFutureCase/blob/main/Infrastructure/InfrasImages/inboundrules.png)


#### **Outbound Rules**   
![](https://github.com/sudkostik/PatikaWayToFutureCase/blob/main/Infrastructure/InfrasImages/outboundrules.png)



## EC2 
**Amazon Elastic Compute Cloud (EC2), Amazon Web Services (AWS) tarafından sunulan bir hizmettir ve kullanıcılara sanal sunucular (EC2 örnekleri) oluşturma ve yönetme imkanı sağlar. EC2, esnek, ölçeklendirilebilir ve güvenilir bir şekilde uygulamaları barındırmak, çalıştırmak ve yönetmek için kullanılır.**

* EC2 yönetim panelinde "Instances" (Örnekler) seçeneğini bulun ve tıklayın.

* "Launch Instance" (Örnek Başlat) düğmesini tıklayın.
* Adını patika-wtf-nginx-web-02 koyuyoruz.

* EC2 örneği oluşturmak için kullanmak istediğiniz Amazon Machine Image (AMI) seçin. AMI, bir işletim sistemi ve ön yüklenmiş yazılım paketlerini içeren önceden yapılandırılmış bir görüntüdür. Biz Amazon Linux seçiyoruz(Amozon Linux 2023 AMI).

* EC2 örneği için örnek tipini (instance type) seçin. Bu, örneğin kaynaklarının (CPU, bellek, depolama vb.) boyutunu belirler. Biz ücretsiz kullanım sağladığı için t2.micro'yu seçiyoruz.

* Create new key pair diyerek patikakeypair adında bir  Key Pair oluşturuyoruz. Bu Key Pair sayesinde sunucumuza ssh üzerinden erişip gerekli kontrolünü yapabiliriz. Bu Key Pair'i kaybetmiyoruz.

* Network Settings kısmında VPC'mizi seçiyoruz ardından bir public subnet seçiyoruz patika-wtf-public-1a'yı seçin.
* Auto-assign public IP Enable işaretliyoruz.
* Create security group diyerek adını secure koyuyoruz.
* SSH Anywhere diyerek ardından new group diyerek yeni group rule ekliyoruz.  HTTP Anywhere , HTTPS Anywhere diyoruz.
* Launch Instance diyerek Instance'ımızı oluşturuyoruz.
![](https://github.com/sudkostik/PatikaWayToFutureCase/blob/main/Infrastructure/InfrasImages/ec2altiilkfoto.png)



## Elastic IPs 
* Bir Elastic IP oluşturup bunu Instance'ımıza Associate ediyoruz.
![](https://github.com/sudkostik/PatikaWayToFutureCase/blob/main/Infrastructure/InfrasImages/elasticip.png)


## Auto Scaling Group

**Auto Scaling Group (Otomatik Ölçeklendirme Grubu), Amazon Web Services (AWS) içinde yer alan bir hizmettir ve kaynakların otomatik olarak ölçeklendirilmesini sağlar. Auto Scaling Group, uygulamalarınızın veya hizmetlerinizin talebe göre artan veya azalan trafiği karşılamak için dinamik olarak kaynakları ölçeklendirmesine olanak tanır.**

* Instance'ımızı seçiyoruz ve Actions kısmından Instance Settings kısmına giderek ordan Attach to Scaling Group diyoruz.
![](https://github.com/sudkostik/PatikaWayToFutureCase/blob/main/Infrastructure/InfrasImages/autoscalinggorup.png)


* Bu kısımda mevcut bir Auto Scaling Group olmadığı için bir isim veriyoruz adını Patika ASG koyun. Attach butonuna tıkladığımızda bizim için bir Auto Scaling Group oluşturacak.
* Oluşturduğumuz Auto Scaling Group üzerinden Desired capacity , Minimum Capacity , Maximum Capacity gibi ayarları değiştirebiliyoruz. Bu ayarlar eğer bir Instance'ınız fazla yük altında kalır veya kapanırsa otomatik aynı tipte bir Instance yaratmasını sağlamak için var. Biz default ayarlarında tutuyoruz. Çünkü bir adeet EC2 Instance kullanmak istiyoruz.
![](https://github.com/sudkostik/PatikaWayToFutureCase/blob/main/Infrastructure/InfrasImages/autoscalinggroup2.png)



#### **Target Group**
* Bir Target Group oluşturun adını TargetGroupEc2 koyun. Bunları Listener'lara bağlayın.
* EC2 yönetim panelinde sol menüden "Target Groups" (Hedef Grupları) seçeneğini bulun ve tıklayın.

* "Create Target Group" (Hedef Grubu Oluştur) düğmesini tıklayın.

* Oluşturulan Target Group için bir ad belirleyin ve Instances seçin.

* "Health checks" (Sağlık Kontrolleri) adımında sağlık kontrolü ayarlarını yapılandırın. Örneğin, hangi protokol ve bağlantı noktası üzerinden sağlık kontrolü yapılacağını belirleyin.

* "Register Targets" (Hedefleri Kaydet) adımında hedef grubuna dahil etmek istediğiniz kaynakları (örneğin, EC2 örnekleri) seçin veya oluşturun.

* "Create" (Oluştur) düğmesini tıklayarak Target Group'un oluşturulmasını başlatın.
![](https://github.com/sudkostik/PatikaWayToFutureCase/blob/main/Infrastructure/InfrasImages/targetgroupalti.png)


* "Configure Routing" (Yönlendirmeyi Yapılandır) adımında, hangi hedef grubuna yönlendirme yapacağınızı belirleyin. Hedef grupları, yük dengeleyici tarafından yönlendirilen EC2 örneklerini içerir.

* "Register Targets" (Hedefleri Kaydet) adımında, yük dengeleyicinin yönlendireceği EC2 örneklerini seçin veya oluşturun.

* "Review" (Gözden Geçir) adımında yapılandırmalarınızı kontrol edin ve gerekli düzeltmeleri yapın.

* "Create" (Oluştur) düğmesini tıklayarak yük dengeleyicinin oluşturulmasını başlatın.


## Application Load Balancer

**Application Load Balancer (Uygulama Yük Dengeleyici), Amazon Web Services (AWS) içindeki bir hizmettir ve gelen web trafiğini birden fazla EC2 örneği arasında dağıtarak yükü dengeler. Application Load Balancer, uygulama düzeyinde yük dengelemesi yapar ve talebi gelen isteklere en uygun EC2 örneğine yönlendirir.**

* EC2 yönetim panelinde sol menüden "Load Balancers" (Yük Dengeleyiciler) seçeneğini bulun ve tıklayın.

* "Create Load Balancer" (Yük Dengeleyici Oluştur) düğmesini tıklayın.

* "Application Load Balancer"'ı seçin.

* Load Balancer'ın adını loadbalancerpatika-wtf koyun ve Scheme'yı Internet-facing seçin. IP adress type IPv4 olacak.
 ### **Network Mapping** 
* VPC'mizi seçin.
* Mappings 1. kısmında eu-central-1a subnet olarak patika-wtf-public-1a seçiniz.
* Mappings 2. kısmında eu-central-1b subnet olarak patika-wtf-public-1b seçiniz.

![](https://github.com/sudkostik/PatikaWayToFutureCase/blob/main/Infrastructure/InfrasImages/networkmapping.png)


* Security Group kısmında secure ismiyle tasarladığımız security group'u seçiniz.

### **Listeners And Routing**
* Listener HTTP:80 kısmında Target olarak oluşturduğumuz TargetGroupEc2'yi seçin.

**Create Load Balancer diyerek Load Balancer'ımızı oluşturun.**

![](https://github.com/sudkostik/PatikaWayToFutureCase/blob/main/Infrastructure/InfrasImages/loadbalanceraktif.PNG)




# Projemizin Infrastructure Management kısmı tamamlanmıştır. 



![](https://github.com/sudkostik/PatikaWayToFutureCase/blob/main/Infrastructure/InfrasImages/bitis.png)  









