# Ekle-Kullanıcı
<p>
Active Directory'e toplu kullanıcı eklemeye yarayan Powershell scripti. CSV dosyasından veya komut satırından kullanıcı adları alınır ve Active Directory'e tek seferde eklenir. 
</p>
<p>Kullanıcılar aynı şehir, departman, ülke vb. gibi aynı özelliklere sahip olurlar. Aynı organization Unite taşınabilir ve aynı gruba eklenebilirler.</p>
# Gereklilikler
<p>Bu scriptin çalışması için en düşük Windows Server 2008 R2 üzerinde Active Directory Domain Services kurulu olmalıdır.</p>

# Kurulum
1. Belgeler\WindowsPowerShell\Modules\EkleKullanici\ klasörünü oluşturun
2. EkleKullanici.psm1 dosyasını oluşturduğunuz klasöre kopyalayın.

# Kullanım
<code>Ekle-Kullanici -KullaniciAdi salih,hasan,ismail,can -EkranAdi "Salih Emre","Hasan","İsmail","Ali Can"</code><br>
Tüm kullanıcılar için geçerli olacak parolayı iki defa yazın. Kullanıcılar ayarlanan parolayı değiştirmek zorunda kalacaklar.
Yukarıdaki komut emre, hasan, ismail, can kullanıcılarını AD'ye ekler. Şehir İstanbul ve Ülke bilgisi TR olacaktır. Kullanıcılar -KullaniciAdi parametresine yazılan adlarla oturum açacaklar. <br><br>
-EkranAdi parametresi Active Directory'deki DisplayName özelliğidir.
<p><code>Ekle-Kullanici -csvmi $true -CSVDosya "CSVDosyası\Yolu\dosya.csv"</code></p>
<p>Kullanıcı adlarını CSV dosyasından alır.</p>

<p>Kullanıcı adı sayısı kadar ekran adı değeri olmalı</p>
# Parametreler
<p>
<code>[String[]] KullaniciAdi</code>: Eklenen kullanıcıların oturum açarken kullanacağı ad. Birden fazla değer alabilir.<br><br>
<code>[String[]] EkranAdi</code>: Kullanıcıların tam adı. Birden fazla değer alabilir<br><br>
<code>[String] Sehir</code>: Kullanıcıların bulunduğu şehir<br><br>
<code>[String] Ulke</code>: Kullanıcıların bulunduğu ülke. İki harf olmak zorunda. Örn: Türkiye için TR yazın.<br><br>
<code>[String] Departman</code>: Kullanıcıların çalıştığı departman<br><br>
<code>[boolean] Etkin</code>: Eklenen kullanıcıları etkin (enabled) veya pasif (disabled) olup olmayacağını belirler. Öntanımlı değer <code>$true</code>, kullanıcılar aktiftir.<br><br>
<code>[String] OU</code>: Kullanıcıların ekleneceği organizational unit. Öntanımlı değer "Users". Tırnak içinde yazın<br><br>
<code>[String] Grup</code>: Kullanıcıların ekleneceği grup. Öntanımlı değer "Domain Users". Tırnak içinde yazın, kullanıcılar hem sizin istediğiniz grubun hem de Domain Users grubunun üyesi olacaklar<br><br>
<code>[boolean] csvmi</code>: Kullanıcı listesi CSV dosyasından alınacaksa $true değeriyle beraber bu parametreyi kullanın<br><br>
<code>[String] CSVDosya</code>: CSV dosyasının yolu.
</p>

# Karşılaşabileceğiniz Hatalar
### Missing an argument for parameter 
<p>Muhtemelen bir parametreye değer girmediniz. Boş kalan bir şey var.</p>
### The password does not meet the length, complexity, or history requirement of the domain.
<p>Ayarladığınız parola domaininizin güvenlik gereksinimlerinin altında kalmış daha güçlü bir parola yazın</p>
### The operation could not be performed because the object's parent is either uninstantiated or deleted
<p>Organizational unit yok. Oluşturun veya yazımınızı kontrol edin</p>
### Cannot find an object with identity: < grup > under:
<p>Grup yok. Oluşturun veya yazımınızı kontrol edin</p>
### Select : Property "DisplayName" cannot be found.
### You cannot call a method on a null-valued expression
<p>Yukarıdaki iki hata da CSV dosyasının düzgün olmamasından dolayı ortaya çıkar. CSV dosyanızın içeriğini aşağıdakine benzer yapın:

Name,DisplayName<br>
hasan,"Hasan"<br>
idris,"İdris"<br>
emre,"Emre Can"

İsimleri kendi kullanıcılarınızınkilerle değiştirin.
### Exception calling "Get" with "1" argument(s): "Index was outside the bounds of the array."
EkranAdi'na girilen değerlerin sayısıyla KullaniciAdi'na girilenlerin sayısı aynı değil. 3 KullaniciAdi değeri varsa 3 de EkranAdi değeri olmak zorunda.
