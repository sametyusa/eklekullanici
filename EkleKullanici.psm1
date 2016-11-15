<#
.SYNOPSIS
    Tek satırda Active Directory'e birden fazla kullanıcı ekler.
.DESCRIPTION
    Bu script tek seferde birden fazla kullanıcıyı aynı özelliklerle, ülke, şehir, departman vs gibi, Active Directory'e ekler.
    Sistem yöneticisi tüm kullanıcılar için tek parola belirler. Kullanıcılar ilk oturum açışlarında parolalarını değiştirmek 
    zorundadır.
    Kullanıcılar için şehir ve ülke bilgisi öntanımlı olarak İstanbul ve TR'dir.
.EXAMPLE
    Ekle-Kullanici -KullaniciAdi samet,idris,hasan,emre
    samet,idris,hasan,emre kullanıcılarını ekler. Kullanıcılar yazılan adlarla oturum açar.
    Bu kullanıcıların öntanımlı Şehir(City) değeri İstanbul, Ülke (Country) değeri ise TR'dir.
.EXAMPLE
    Ekle-Kullanici -csvmi $true -CSVDosya ".\Documents\kullanicilar.csv"
    Kullanıcı adlarını CSV dosyasından alır. Kullanıcı isimleri CSV dosyasında alt alta yazılmış olmalıdır
.EXAMPLE
    Ekle-Kullanici -KullaniciAdi samet,ismail,salih -Departman "Bilgi İşlem" -Ulke TR -Sehir "İzmir" -OU "ik"
    Kullanıcılara departman, ülke ve şehir bilgileri ekler. ik organizational unitine tasir. Ülkeler kısa kodlu olmak zorundadır.
.EXAMPLE 
    Ekle-Kullanici -KullaniciAdi emre,hasan -OU "IT" -Departman "Bilgi İşlem" -Etkin:$False
    emre ve hasan kullanıcılarını IT organizational unitine pasif olarak (disabled) ekler.
.NOTES
    Copyright (c) 2016 Samet Yuşa
    sametyusa@gmail.com

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>

Import-Module ActiveDirectory
Function Ekle-Kullanici {
    [CmdletBinding()]
       Param (
            [String[]]$KullaniciAdi,
            [String[]]$EkranAdi,
            [String]$Sehir = "İstanbul",
            [String]$Ulke = "TR", #Kısa kodlar olmak zorunda
            [String]$Departman,
            [boolean]$Etkin=$True,
            [String]$OU="Users",
            [String]$Grup="Domain Users",
            [boolean]$csvmi=$false, #Kullanıcı adları .csv dosyasından alınacaksa $true olmalı
            [String]$CSVDosya
        )
    
Begin {
    if ($csvmi -eq $true -or $KullaniciAdi.Count -gt 0) {
        $ToplamSay = $KullaniciAdi.Count
        $dcAdi=(Get-ADDomain | Select -ExpandProperty DistinguishedName)
        $Parola = (Read-Host "Tüm kullanıcılar için parola belirleyin " -AsSecureString)
        $Parola2 = (Read-Host "Parolayi tekrar yazin " -AsSecureString)
        $p1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Parola))
        $p2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Parola2))
    }  
    else { 
        Write-Error "Hiç kullanıcı adı girilmedi. Yardım metnini görmek için help Ekle-Kullanici yazın"
        break 
    }
}
Process {
    
    if ($p1 -ceq $p2) {
     if ($csvmi -eq $false) { #Kullanıcı adlarını kullanıcı kendi giriyor
       if ($KullaniciAdi.Count -gt 0 -and $EkranAdi.Count -gt 0) { 
       For ($i -eq 0;$i -lt $KullaniciAdi.Count;$i++) {
      
        $Eklenen = $KullaniciAdi.Get($i)
        $ekra=$EkranAdi.Get($i)
        New-ADUser -Name $Eklenen -SamAccountName $Eklenen -DisplayName $ekra -AccountPassword $Parola `
       -Department $Departman -City $Sehir -Country $Ulke -ChangePasswordAtLogon:$true -Enabled:$Etkin
      
        Write-Verbose "$Eklenen eklendi"
       if ($OU -ne "Users") {
            Get-ADUser $Eklenen | Move-ADObject -TargetPath "OU=$OU,$dcAdi"
            Write-Verbose "$Eklenen $OU birimine taşındı"
       }
       if ($Grup -ne "Domain Users") {
            Add-ADGroupMember -Identity $Grup -Members $Eklenen
            Write-Verbose "$Eklenen, $Grup grubuna dahil edildi"
       }
      
        }
       
     } else {
            Write-Error "Ekran adı ya da kullanıcı adı girilmemiş." 
        }
      }
      else { #Kullanıcı adları CSV dosyasından alınacak
             $kadi=Import-CSV $CSVDosya | Select -ExpandProperty Name
            $eadi=Import-CSV $CSVDosya | Select -ExpandProperty DisplayName

        for ($z -eq 0;$z -lt $kadi.Count;$z++) {
            $bu=$kadi.Get($z) #Verbose metinleri için
             New-ADUser -Name $kadi.Get($z) -SamAccountName $kadi.Get($z) -DisplayName $eadi.Get($z) -AccountPassword $Parola `
           -Department $Departman -City $Sehir -Country $Ulke -ChangePasswordAtLogon:$true -Enabled:$Etkin
          
            Write-Verbose "$bu eklendi"
           if ($OU -ne "Users") {
                Get-ADUser $kadi.Get($z) | Move-ADObject -TargetPath "OU=$OU,$dcAdi"
                Write-Verbose "$bu $OU birimine taşındı"
           }
           if ($Grup -ne "Domain Users") {
            Add-ADGroupMember -Identity $Grup -Members $kadi.Get($z)
            Write-Verbose "$bu  $Grup grubuna dahil edildi"
             }
        }
      }
    }
    else { Write-Error "Yazdığınız parolalar eşleşmiyor"}
    
}
End{ #Write-Output  "$Toplamsay tane kullanıcı eklendi. Kullanıcılar ilk kez oturum açarken parolalarını değiştirmek zorunda."
}
}