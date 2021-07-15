<# FireFox Browser Install
# CreatedBy 정석원 / 20.08.06

.SYNOPSIS 
FireFox 브라우저 인스톨을 위한 App Version, Architecture 검증
.NOTES
SCCM Script Run User (NT AUTHORITY\SYSTEM)
FireFox Package Update 를 위해 Mozilla 에서 제공하는 Update MAR DB 필요 
Package Upgrade Cmdlet 문서 참조
.DESCRIPTION
V1.0 
 - MAR DB 수동 업데이트 후 레지스트리 값 반영되지 않음. 수동 업데이트 작업 (L105~111)
 - Updater.exe Start cmdlet 구문 작성 시 UpdateLog Fail 발생. DOS Hardcoding Type 변경 (L86)
.COMPONENT
# Mozilla FTP Download Page
http://download.cdn.mozilla.net/pub/firefox/releases/$Version`/update/win64/ko/
http://download.cdn.mozilla.net/pub/firefox/releases/$Version`/update/win64/en-US/

# Mozilla Offline MAR Upgrdae Cmdlet
https://wiki.mozilla.org/Software_Update:Manually_Installing_a_MAR_file#Where_to_get_a_mar_file
#>

begin {
  [int]$Version = 81.0

  #$cre = New-Object System.Management.Automation.PSCredential('secuad\htd4231',('##Zjavbxj1'|ConvertTo-SecureString -AsPlainText -Force))
  $cre = '인증정보 제공'
  $se = New-PSSession 'DC Server' -Credential $cre
  Import-PSSession -Session $se -Module ActiveDirectory -AllowClobber | Out-Null
  $Name = 'Target PC Name'
  New-PSDrive HKU Registry Hkey_Users | Out-Null
  $Filelist = @("firefox-$Version.complete_en-US.mar", "firefox-$Version`.complete_ko-KR.mar")
  $LogFile = "C:\Temp\$env:COMPUTERNAME_`FireFoxBrowser_Upgrade.log"
  $Identity = (Get-ADUser $Name -Properties *).sid
  $RegPath = "HKU:\$Identity\Software\Microsoft\Windows\CurrentVersion\Uninstall"
	'Time,Message' > $LogFile
}

Process {
  $Store = Get-ItemProperty $RegPath\* | Where-Object { $_.Displayname -like '*fire*' }

  "$("{0:HH:mm:ss}" -f (Get-Date)), Software Identifying... "  >> $LogFile

  # 설치된 App Version 확인 후 해당 업데이트 파일 로컬경로로 복사
  try {
    
    "$("{0:HH:mm:ss}" -f (Get-Date)), Check Application Architecture.."  >> $LogFile

    if ($Store.DisplayVersion -lt $Version) {
      $FilePath = 'MarDB File Path'
      $FullPath = "$FilePath\firefox-$Version`.complete_$(if($Store.DisplayName -like '*en-US*'){'en-us'} else {'ko-kr'})`.mar" #architecture Condition 
      $Filelist | ForEach-Object { $FullPath -match $_ }
      $FileName = $Matches[0]
      Copy-Item $FullPath C:\Temp -FromSession $se -Force
      Rename-Item C:\Temp\$FileName 'Update.mar' -Force
      "$("{0:HH:mm:ss}" -f (Get-Date)), $FileName Copy Compleate"  >> $LogFile

      # 사용중인 프로세스 종료 
      try {
        $LiveCheck = Get-WmiObject win32_process -Filter "name like '%fire%'"
        if ($LiveCheck.count -gt 0) {
          $LiveCheck.Terminate()
        }
      }
      catch {
        "$("{0:HH:mm:ss}" -f (Get-Date)), Process Terminate Fail :`t$($_.Exception.Message)"  >> $LogFile
      }

      # 패키지 업그레이드
      try {
    
        "$("{0:HH:mm:ss}" -f (Get-Date)), Gathering Profile Path String.."  >> $LogFile
    
        $Switch = 0
        $UserProfilePath = Get-CimInstance Win32_UserProfile | Where-Object { <#$_.localpath -like "*$Name*" -or #>$_.LocalPath -like '*Administrator*' -and $_.LocalPath -notlike '*addc*' }
        $AppPath = 'Appdata\Local\Mozilla Firefox'
        if ($UserProfilePath.count -gt 1) { $Switch = '1' }
        [string]$ProfileFullPath = if ($Switch -eq 0) { "$($UserProfilePath.LocalPath)\$AppPath" } else { "C:\Users\$Name\$AppPath" }

        Set-Location $ProfileFullPath
        Copy-Item $ProfileFullPath\Updater.exe C:\Temp

        "$("{0:HH:mm:ss}" -f (Get-Date)), Firefox Browser $version Upgrade Start.."  >> $LogFile
    
        C:\temp\Updater.exe c:\temp $ProfileFullPath $ProfileFullPath
        Start-Sleep -Seconds 10
        #Start-Process C:\Temp\updater.exe -ArgumentList "C:\Temp $ProfileFullPath $ProfileFullPath" -Wait -Verb Runas

        if ((Get-Content C:\Temp\update.status) -eq 'succeeded') {
          "$("{0:HH:mm:ss}" -f (Get-Date)), Update Success"  >> $LogFile
        }
        else {
          "$("{0:HH:mm:ss}" -f (Get-Date)), Update Fail. Please Check Update.Log"  >> $LogFile
          break
        }
    

        "$("{0:HH:mm:ss}" -f (Get-Date)), $Filename Install Compleate" >> $LogFile
      }
      catch {
        "$("{0:HH:mm:ss}" -f (Get-Date)), Install Error :`t$($_.Exception.Message)"  >> $LogFile
      }

      # Registry Value Update
      $language = if ($store.displayname -like '*en-US*') { 'en' } else { 'ko' }
      [regex]$Regex = "[\d]{1,2}\.[\d]{1,2}\.[\d]{1,2}|[\d]{1,2}\.[\d]{1,2}|[\d]{1,2}\.[\d]{1,2}\.[\d]{1,2}[a-zA-Z]{1,2}"
      $CurrentVersion = $Regex.Match((Get-ChildItem $RegPath | Where-Object { $_.name -like '*mozilla*' }).name -split '\\' -match 'mozilla').value
      
      Set-ItemProperty "$RegPath\Mozilla Firefox $CurrentVersion (x64 $language)" -Name displayname -Value "Mozilla Firefox $Version (x64 $language)"
      Set-ItemProperty "$RegPath\Mozilla Firefox $CurrentVersion (x64 $language)" -Name Comments -Value "Mozilla Firefox $Version (x64 $language)"
      Set-ItemProperty "$RegPath\Mozilla Firefox $CurrentVersion (x64 $language)" -Name displayVersion -Value $Version
      
      Rename-Item "$RegPath\Mozilla Firefox $CurrentVersion (x64 $language)" -NewName "Mozilla Firefox $Version (x64 $language)"
    }
    else {
      "$("{0:HH:mm:ss}" -f (Get-Date)), This Version is Lastest."  >> $LogFile
      break
    }
  }
  catch {
    "$("{0:HH:mm:ss}" -f (Get-Date)), Copy Fail :`t$($_.Exception.Message)"  >> $LogFile
  }
  
}

end {
  
  [PSCustomObject]@{
    Name       = $env:COMPUTERNAME
    AppVersion = $((Get-ItemProperty HKU:\$Identity\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.displayname -like '*fire*' }).DisplayVersion
    )
  }

  $cre = ''
  Get-PSSession | Remove-PSSession
}

