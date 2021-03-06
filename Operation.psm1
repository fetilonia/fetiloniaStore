<#
.SYNOPSIS
  
.DESCRIPTION
  Functino Array
.EXAMPLE
  적용 방법
  Ctrl + G Line Number 바로가기

  131Line - "Domain\MyAccount" , "MyPassWord" 수정
  139Line - 'MyLogPath' 수정
  509Line - 'MyPath' 수정
  
.NOTES
  Module Version 1.0.0 Function List
  
  Version 1.2

 #Requires -RunAsAdministrator
  
#>

#endregion Function List
 

#region Global Data

# 단축명령어 섹션
Set-Alias gs Get-Service
Set-Alias enp Enter-PSSession
Set-Alias gad Get-ADUser
Set-Alias gac Get-ADComputer

# 인증정보 제공 섹션
New-PSDrive HKU Registry HKEY_Users | Out-Null
New-PSDrive HKCR Registry HKEY_CLASSES_ROOT
$Global:char = [char]27

# 모듈정보 제공 섹션
#$FilePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\Operation"

<# 콘솔 커스터마이징 섹션
$Date = "{0:yyMMdd}" -f (Get-Date)
$Global:char = [char]27
$LogPath = 'D:\업무관련\DailyScriptLog'
$LogFileName = "PowerShell_WorkingLog_($PID)_$Date.log"
$RunUser = whoami
$Message = @"
$(if ($RunUser -like '*htd*') {
  "현재 실행된 콘솔은 관리자 계정$Global:char[31m ($RunUser)$Global:char[0m 으로 실행 되었습니다."
}
else {
  "현재 실행된 콘솔은 $Global:char[31m ($RunUser)$Global:char[0m 계정으로 실행 되었습니다."
})


모든 명령어는 조회를 제외한 변경사항이 발생할 경우 확인 및 Whatif 를 통한 검증 후 작업 바랍니다.
작업 내역 기록 : $Global:char[36m $LogFileName$Global:char[0m

"@
Write-Host $Message

# 콘솔 로그 기록
if (-not (Test-Path $LogPath\$Date)) {
  New-Item D:\업무관련\DailyScriptLog -Name $Date -ItemType Directory
}
Start-Transcript -Path "$LogPath\$date\$LogFileName"
#>

# 어플리케이션 제공 정보

#endregion 

#region Function Group

# 프롬프트 커스터마이징 (pwsh 5.0 higher)
function prompt {
  $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = [Security.Principal.WindowsPrincipal] $identity
  $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
    
  "$Global:char[42m[$("{0:HH:mm:ss}" -f(Get-Date))]$Global:char[0m$Global:char[3m$(if($principal.IsInRole($adminRole)){'[ADMIN]'}else{'[USER]'})`@$($ExecutionContext.SessionState.Path.CurrentLocation)$('>' * ($NestedPromptLevel + 1)) "
  $Host.UI.RawUI.WindowTitle = "$("{0:MM-dd}" -f (Get-Date)) Powershell 관리자 콘솔 - ID($PID)"

}

# 프롬프트 커스터마이징 (pwsh 5.0 lower)
function prompt {
    #$char = [char]27
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal] $identity
    $adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
      
    "[$("{0:yyyy-MM-dd HH:mm:ss}" -f(Get-Date))]$(if($principal.IsInRole($adminRole)){'[ADMIN]'}else{'[USER]'})`@$($ExecutionContext.SessionState.Path.CurrentLocation)$('>' * ($NestedPromptLevel + 1)) "
    $Host.UI.RawUI.WindowTitle = "$("{0:MM-dd}" -f (Get-Date)) NPMESDL01 Administrators 그룹 멤버 - ID($PID)"
  
  }

#>
# 현재 실행 계정이 속한 그룹 Boolean
Function Test-Role {
  
  [cmdletbinding(SupportsShouldProcess)]

  Param(
    [Parameter(Position = 0, ValueFromPipelineByPropertyName)]  
    [string[]]$Comp,
    [Parameter(Position = 1, ValueFromPipelineByPropertyName)]  
    [Security.Principal.WindowsBuiltinRole][string]$Role = 'Administrator'
  )

  begin {

  }
  
  process {
    if ($PSCmdlet.ShouldProcess($Comp)) {
      if ($PSCmdlet.ShouldContinue('이 작업을 실행하시겠습니까?', '== 운영 관리자 콘솔==')) {
        $Arr = @()
        $Comp | ForEach-Object {
          if ([System.Net.NetworkInformation.Ping]::new().SendPingAsync("$_", 1).Result.status -eq 'success') {
            if ((Get-Service -ComputerName $_ winrm).status -eq 'Stopped') {
              (Get-Service -ComputerName $_ winrm).start()
            }
            $Name = $_ -replace '^[A-Z]{1}[0-9]{3}', ''
            $UPN = '@DomainFQDN'
            $Argument = @{
              ComputerName = $_
              ScriptBlock  = {
                
                [pscustomobject]@{
                  Name      = $env:COMPUTERNAME
                  AdminRole = $Role
                }
              }
            }
            $Arr += Invoke-Command -ComputerName $_ -ScriptBlock {
              (param [string]$data)
              
              $Principal = [Security.Principal.WindowsPrincipal]([Security.Principal.WindowsIdentity]::new($In + $UPN))
              $RoleReport = $Principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
              [pscustomobject]@{
                Name      = $env:COMPUTERNAME
                AdminRole = $RoleReport
              }
            } -ArgumentList $_
            
          }
          else {
            $Arr + [pscustomobject]@{
              Name      = $_
              AdminRole = 'NotConnect'
            }
          }
        }
        $Arr | Select-Object Name, 
        AdminRole
      }
    }
    
  }
  End {
    
  }
}

# winrm config


function wrm {
	
	
  [cmdletbinding(SupportsShouldProcess)]
  param([parameter(mandatory = $true)]$hostname)

  if ($PSCmdlet.ShouldProcess($Comp)) {
    if ($PSCmdlet.ShouldContinue("이 작업을 실행하시겠습니까? ($Global:char[42m[$hostname]$Global:char[0m Remote Connect)", "`t==`t명령 실행 전 확인`t==")) {
      if (!([System.Net.NetworkInformation.Ping]::new().SendPingAsync("$hostname", 1)).result.status) {
        try {
          if ((Get-Service -ComputerName $hostname winrm).Status -eq 'running') {
            (Get-Service -ComputerName $hostname winrm).stop()
            Start-Sleep 3
            (Get-Service -ComputerName $hostname winrm).start()
            Write-Host -ForegroundColor Green 'Service Running.WINRM Service Restart'
            enp -ComputerName $hostname
          }
          else {
            <#  #>
            (Get-Service -ComputerName $hostname winrm).start()
            Write-Host -ForegroundColor DarkYellow 'WINRM Service Start'
            enp -ComputerName $hostname 
          }
        }
        catch {
          Write-Output 'Service has Not Start:' $_.exception.message
        }
    
      }
      else { Write-Warning 'Not Online' }
    }
  }
}

# SCCM Agent 설치
function CI {
  [CmdletBinding(SupportsShouldProcess)]
  param($Comp)

  if ($PSCmdlet.ShouldProcess($Comp)) {
    if ($PSCmdlet.ShouldContinue("이 작업을 실행하시겠습니까? ($Global:char[42m[$comp]$Global:char[0m SCCM Agent 5.00.8790.1007 $Global:char[31mInstall$Global:char[0m)", "`t==`t명령 실행 전 확인`t==")) {
      $Service = Get-Service -ComputerName $Comp WinRM
      if ($Service.Status -eq 'Stopped') { $Service.Start(); Write-Host -ForegroundColor Green 'Service Start' }
  
      Invoke-Command $Comp -ScriptBlock ${function:SCCMAgentInstall}
    }
  }
}



# SCCM Agent 설치 Main

function SCCMAgentInstall {
  
  $Credential = [System.Management.Automation.PSCredential]::new("domain\domainadmin", $("password" | ConvertTo-SecureString -AsPlainText -Force))
  $Session = New-PSSession -ComputerName d009td4231 -Credential $Credential
  $Path = Test-Path C:\windows\ccmsetup
  if ($Path -eq $false) {
    New-Item -Name ccmsetup -Path C:\Windows -ItemType Directory | Out-Null
  }
  Start-Sleep -Seconds 2
  Copy-Item D:\ccmsetup.exe c:\Windows\ccmsetup\ -FromSession $Session -Force -ErrorAction SilentlyContinue
  
  Start-Process C:\Windows\CCMSetup\ccmsetup.exe -ArgumentList ' /MP:SCCMServerNetbios.DomainFQDN SMSSITECODE=SA1 SMSSLP=SCCMServerNetbios.DomainFQDN SMSCACHESIZE=5120' -Wait -ErrorAction SilentlyContinue

  [pscustomobject] @{
    Name    = $env:COMPUTERNAME
    Service = $(if (!(gcim win32_service | Where-Object { $_.name -eq 'ccmsetup' })) { 'Fail. Check Event Log' } else { 'Installing..' })

  } | Format-Table
}

  
# 공유폴더 관리

function ManageSMB {
    
  param([parameter(mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    $path)

    
  foreach ($user in $1) {
        
    $acl = Get-Acl $path
    $ar = New-Object System.Security.AccessControl.FileSystemAccessRule($user, "modify", "allow")
    $acl.SetAccessRule($ar)
    Set-Acl $path $acl
    icacls $path /T /inheritance:e
  }

}

Function Get-Software {

  [OutputType('System.Software.Inventory')]
  [Cmdletbinding()] 
  Param( 
    [Parameter(ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)] 
    [String[]]$Computername = $env:COMPUTERNAME
  )         
  Begin {
  }
  Process {     
    ForEach ($Computer in  $Computername) { 

      If (Test-Connection -ComputerName  $Computer -Count  1 -Quiet) {
        $Paths = @("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall", "SOFTWARE\\Wow6432node\\Microsoft\\Windows\\CurrentVersion\\Uninstall")         
        ForEach ($Path in $Paths) { 
          Write-Verbose  "Checking Path: $Path"
          #  Create an instance of the Registry Object and open the HKLM base key 
          Try { 
            $reg = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine', $Computer, 'Registry64') 
          }
          Catch { 
            Write-Error $_ 
            Continue 
          } 
          #  Drill down into the Uninstall key using the OpenSubKey Method 
          Try {
            $regkey = $reg.OpenSubKey($Path)  
            # Retrieve an array of string that contain all the subkey names 
            $subkeys = $regkey.GetSubKeyNames()      
            # Open each Subkey and use GetValue Method to return the required  values for each 
            ForEach ($key in $subkeys) {   

              Write-Verbose "Key: $Key"
              $thisKey = $Path + "\\" + $key 

              Try {  
                $thisSubKey = $reg.OpenSubKey($thisKey)   
                # Prevent Objects with empty DisplayName 
                $DisplayName = $thisSubKey.getValue("DisplayName")

                If ($DisplayName -AND $DisplayName -notmatch '^Update  for|rollup|^Security Update|^Service Pack|^HotFix') {
                  $Date = $thisSubKey.GetValue('InstallDate')
                  If ($Date) {

                    Try {
                      $Date = [datetime]::ParseExact($Date, 'yyyyMMdd', $Null)
                    }
                    Catch {
                      Write-Warning "$($Computer): $_ <$($Date)>"
                      $Date = $Null
                    }
                  } 

                  # Create New Object with empty Properties 
                  $Publisher = Try {
                    $thisSubKey.GetValue('Publisher').Trim()
                  } 
                  Catch {
                    $thisSubKey.GetValue('Publisher')
                  }

                  $Version = Try {
                    #Some weirdness with trailing [char]0 on some strings
                    $thisSubKey.GetValue('DisplayVersion').TrimEnd(([char[]](32, 0)))
                  } 
                  Catch {
                    $thisSubKey.GetValue('DisplayVersion')
                  }

                  $UninstallString = Try {
                    $thisSubKey.GetValue('UninstallString').Trim()
                  } 
                  Catch {
                    $thisSubKey.GetValue('UninstallString')
                  }

                  $InstallLocation = Try {
                    $thisSubKey.GetValue('InstallLocation').Trim()
                  } 
                  Catch {
                    $thisSubKey.GetValue('InstallLocation')
                  }

                  $InstallSource = Try {
                    $thisSubKey.GetValue('InstallSource').Trim()
                  } 
                  Catch {
                    $thisSubKey.GetValue('InstallSource')
                  }

                  $HelpLink = Try {
                    $thisSubKey.GetValue('HelpLink').Trim()
                  } 
                  Catch {
                    $thisSubKey.GetValue('HelpLink')
                  }

                  $Object = [pscustomobject]@{
                    Computername    = $Computer
                    DisplayName     = $DisplayName
                    Version         = $Version
                    InstallDate     = $Date
                    Publisher       = $Publisher
                    UninstallString = $UninstallString
                    InstallLocation = $InstallLocation
                    InstallSource   = $InstallSource
                    HelpLink        = $thisSubKey.GetValue('HelpLink')
                    EstimatedSizeMB = [decimal]([math]::Round(($thisSubKey.GetValue('EstimatedSize') * 1024) / 1MB, 2))
                  }
                  $Object.pstypenames.insert(0, 'System.Software.Inventory')
                  Write-Output $Object
                }
              }
              Catch {
                Write-Warning "$Key : $_"
              }   
            }
          }
          Catch { }   
          $reg.Close() 
        }                  
      }
      Else {
        Write-Error  "$($Computer): unable to reach remote system!"
      }
    } 
  } 
}  



function Get-LogonUsers {

  [cmdletbinding()]
    
  param([parameter(mandatory = $true)]
    [string]$IP = 'localhost',
    [string]$GroupName = 'LogonUsers')
 
  $list = @() 
  
  $IP | ForEach-Object {
    $IP = $_
    $computer = [ADSI]"WinNT://$IP,computer"
	
    $computer.psbase.children | Where-Object { $_.psbase.schemaClassName -eq 'group' -and $_.name -eq $GroupName } | ForEach-Object {
      #   "`tGroup: " + $Group.Name
      $group = [ADSI]$_.psbase.Path
      $group.psbase.Invoke("Members") | ForEach-Object {
        $us = $_.GetType().InvokeMember("Adspath", 'GetProperty', $null, $_, $null)
        $us = $us -replace "WinNT://", ""
        $class = $_.GetType().InvokeMember("Class", 'GetProperty', $null, $_, $null)
        $list += New-Object psobject -property @{Group = $group.Name; Member = $us; MemberClass = $class; IP = $IP }
        #   "`t`tMember: $us ($Class)"
        $list#.member 
   
    
      }
    }
  }
}

function Get-hostname {
  param(
    [string[]]$Switchs,
    [Switch]$IP,
    [Switch]$Hostname
  )

  $Result = @()

  foreach ($Switch in $Switchs) {
  
    $HostHeadPattern = "[a-zA-Z]{1}[0-9]{3}" 
    $MatchPatterns = [regex]"$HostHeadPattern[a-zA-Z]{2}[0-9]{4}|$HostHeadPattern[a-zA-Z]{1}[0-9]{5}|$HostHeadPattern[0-9]{6}"
    $IpPattern = [regex]'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'

    $Result += [pscustomobject]@{
      Input   = $Switch
      Convert = if ([regex]::match($Switch, '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b').Success -eq $true) { $MatchPatterns.Match([System.Net.Dns]::GetHostEntry($Switch).HostName).Value } else
      { $IpPattern.Match([System.Net.Dns]::GetHostEntry($Switch).AddressList.IPAddressToString).Value }
    }
  }
  
  $Result

  
}

## JAVA 최신버전 이하 삭제

function OldJava {

  $Path = 'HKLM:\SOFTWARE\Microso
  ft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
  $Source = Get-ItemProperty $Path | Where-Object { $_.displayname -match 'java\s[0-9]\supdate' }

  foreach ($SS in $Source) {
   
    $Ver = [version]$SS.DisplayVersion
    $Argerment = ($SS).uninstallstring -replace '^[a-zA-Z\D\d]{12}', '' 
    switch ($Ver) {
      { $Ver.major -le 7 } { break; }
      { $Ver.major -gt 7 } {
        if ($Ver.build -lt 2610) {
          Write-Warning -Message "Java Oldest Version $ver Find. Uninstall"
          Start-Process msiexec -ArgumentList "$Argerment /quiet /qn" -Wait
          if (!(Get-Process jre*) -eq $false) {
            Get-Process jre* | Stop-Process -Force
          }
          Write-Output -Message "Uninstall Compleate Java Old Version "
        }
      }
    }
  }
  # Reporting Data Revision
  $Source = Get-ItemProperty $Path | Where-Object { $_.displayname -match 'java\s[0-9]\supdate' }
  $Source | ForEach-Object {
    [pscustomobject]@{
      Name    = $_.Displayname
      Version = $_.DisplayVersion
    }
  } | Export-Csv C:\Temp\$env:COMPUTERNAME`.csv -NoTypeInformation -NoClobber -Encoding UTF8
}


# ping
function tc {
 
  param([string[]]$ip = $_)

  ($ip).foreach( {
      $Network = [System.Net.NetworkInformation.Ping]::New().SendPingAsync("$_", 1).Result.Status
      Write-Host "$_ is :" -NoNewline 
      if ($Network -eq 'Success') {
        Write-Host -ForegroundColor Green "`tOnline"
      }
      else {
        Write-Host -ForegroundColor Red "`tNotOnline"
      }
    })
}

# RD User Session Send Message

Function RDMSG {

  param($Username,
    $PCname)

  $1 = query session $Username /server:$PCname | Select-Object -Skip 1 | ForEach-Object { $_.split('', [System.StringSplitOptions]::RemoveEmptyEntries) }

  Send-RDUserMessage -HostServer $env:COMPUTERNAME -UnifiedSessionID $1[2] -MessageTitle "경고" -MessageBody "현재 사용중인 PC 환경에서 문제가 발생하여 로그오프가 필요합니다.  문의사항은 101-7404 로 연락 주세요."

}

# Windows 10 LockScreen 이미지 변경
function ImgDel {
  try {
    # OS 확인
    $osver = (Get-WmiObject cim_operatingsystem).Caption
    # 키 존재 유무 확인 (Win10)
    if ($osver -eq 'Microsoft Windows 10 Enterprise') {
      if ((Test-Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP) -eq $true) {
        try {
        
          Remove-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP -Force
        
        }
        catch { $_.Exception.Message }
      } 
      # 키 없음  
      else { "$("{0:HH:mm:ss}" -f (Get-Date)) $Env:COMPUTERNAME Not Find Key" | Out-File \\nrsystemcenter\sccm_package\etc\Reulst.txt -Append -Encoding UTF8 }
    }
    # 파일 유무 확인 (Win7)
    else {
      if ((Test-Path C:\Windows\System32\oobe\info\backgrounds\Backgrounddefault.jpg) -eq $true) {
        
        Remove-Item C:\Windows\System32\oobe\info\backgrounds\Backgrounddefault.jpg
      }

      else { "$("{0:HH:mm:ss}" -f (Get-Date)) $Env:COMPUTERNAME Not Found File" | Out-File \\nrsystemcenter\sccm_package\etc\Reulst.txt -Append -Encoding UTF8 }
    }
    # 결과값 정의
    $Compare = if ($osver -eq 'Microsoft Windows 10 Enterprise') { Test-Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP\ }
    else { Test-Path C:\Windows\System32\oobe\info\backgrounds\Backgrounddefault.jpg }

    # False 일 때 결과값 전송
    if ($Compare -eq $false) {
      "$("{0:HH:mm:ss}" -f (Get-Date)) $Env:COMPUTERNAME Run Compleate" | Out-File \\nrsystemcenter\sccm_package\etc\Reulst.txt -Append -Encoding UTF8
    }
    
  }
  catch { $_.Exception.Message }

  <#
$1 = Import-Csv d:\1.csv
$2 = $1 | Group-Object hostname | ForEach-Object { 
  if ($_.Group.value -eq 'Run Compleate') {
    [pscustomobject]@{
      Time     = ($_.group.time | Sort-Object -Descending | Select-Object -first 1);
      Hostname = ($_.group.Hostname | Sort-Object -Descending | Select-Object -first 1); 
      Status   = 'Success'
    }
  }
    else {
      [PSCustomObject]@{
        Time     = ($_.group.time | Sort-Object -Descending | Select-Object -first 1);
        Hostname = ($_.group.Hostname | Sort-Object -Descending | Select-Object -first 1); 
        Status   = 'Pass'
      }
    }
    
  } 

  $2 | Sort-Object > d:\1.txt
#>
}

# Reg Type, Value 포맷 변경
function get-reg {

  
  [cmdletbinding()]
  param($Path = 'registry::HKEY_USERS\S-1-5-21-3816738611-2589146622-315106094-53849\Software\Policies\Microsoft\Windows\Control Panel\Desktop\')

  $Result = @()
  $Key = Get-Item -Path "$Path"
  $Key.GetValueNames() | ForEach-Object {
    $Name = ($_)
    $Type = $($Key.GetValueKind($_))
    $Value = $($Key.GetValue($_))
    $Result += [pscustomobject]@{Name = $Name; Type = $Type; Value = $Value }
  }
  $Result
}

# Query 대상 구성 그룹 List 

function AccountGroups {

  [cmdletbinding()]
  param(
    # 구성 그룹 쿼리 모드 선택
    [Parameter(Mandatory, Position = 0)]
    [ValidateSet('Computer', 'User')]
    [String]$Type,
    # 검색어 지정
    [Parameter(Mandatory, Position = 1)]
    [String]$Searcher
  )

  $Groups = @()
  
  Switch ($type) {
    'Computer' {
      # Directoty Service Assembly Load
      $search = New-Object DirectoryServices.DirectorySearcher
      # LDAP Path String Replace
      $search.SearchRoot = 'LDAP://DC={0}' -f ($env:USERDNSDOMAIN -replace '\.', ',DC=')
      # Define Searcher String
      $search.Filter = "(&(objectcategory=computer)(cn=$($Searcher)))"

      try {
        $entry = $search.FindOne().GetDirectoryEntry()
        $entry.psbase.RefreshCache('tokenGroups')
        $entry.tokenGroups | ForEach-Object {
          $sid = New-Object System.Security.Principal.SecurityIdentifier $_, 0
          $Groups += [PSCustomObject]@{
            Name   = $Searcher
            Groups = $sid.Translate([System.Security.Principal.NTAccount]).Value
          }
        }
      }
      catch {
        "Groups could not be retrieved."
      }
    }

    'User' {
      try {
        # WindowsIdentity Assembly Data Based Data Parsing
        (([System.Security.Principal.WindowsIdentity]::GetCurrent()).Groups | ForEach-Object {
            $_.Translate([System.Security.Principal.NTAccount]) } | Sort-Object) -join "`r`n" -split '\n' | 
      ForEach-Object {
        [PSCustomObject]@{
          Name   = $Searcher
          Groups = $_
        }
      }
  }
  catch { "Groups could not be retrieved." }
}
}
$Groups | Select-Object *
}

# 로그인 실패 EventLog Message Format Sort
function TerminalLog([string]$Comp, [int]$Time) {

  $4625arr = @()

  $LogonFalse = [regex]" 로그온을 실패한 계정:[\s\S]+?계정 이름:\s\s(.*)"
  $Domain = [regex] "새 로그온:[\s\S]+?계정 도메인:\s\s(.*)|로그온을 실패한 계정:[\s\S]+?계정 도메인:\s\s(.*)"
  $WorkStation = [regex] "워크스테이션 이름:(.*)"
  $LogonType = [regex] "로그온 유형:(.*)"
  $IPAddress = [regex] "원본 네트워크 주소:(.*)"
  $Process = [regex] "프로세스 정보:[\s\S]+?프로세스 이름:\s(.*)|프로세스 정보:[\s\S]+?호출자 프로세스 이름:\s(.*)"
  $ErrInfo = [regex] "오류 정보:[\s\S]+?오류 이유:\s+(.*)"

  $Service = Get-Service -ComputerName $Comp Winrm
  if ($Service.Status -eq 'Stopped') {
    $Service.Start()
  }

  $Event = Invoke-Command -ComputerName $Comp -ScriptBlock {
    Get-WinEvent -FilterHashtable @{logname = 'Security'; Starttime = $((Get-Date).AddHours($time)); id = '4625' }  
  }
  foreach ($evt in $Event) {
    try {
      $4625 = [ordered]@{
        LogonID     = $(((($LogonFalse.Match($Event.Message) -split '\n') -match '계정 이름') -split ':')[1].trim() -replace '\$', '');
        Domain      = $(((($Domain.Match($Event.Message) -split '\n') -match '계정 도메인') -split ':')[1].trim());
        LogonType   = $(((($LogonType.Match($Event.Message) -split '\n') -match '로그온 유형') -split ':')[1].trim() -replace '\$', '');
        IP          = $(((($IPAddress.Match($Event.Message) -split '\n') -match '원본 네트워크 주소') -split ':')[1].trim());
        Message     = $(((($ErrInfo.Match($Event.Message) -split '\n') -match '오류 이유') -split ':')[1].trim());
        Process     = $(((($Process.Match($Event.Message) -split '\n') -match '호출자 프로세스 이름') -replace '호출자 프로세스 이름:', '').trim());
        WorkStation = $(((($WorkStation.Match($Event.Message) -split '\n') -match '워크스테이션 이름') -split ':')[1].trim());
        Date        = "{0:yy/MM/dd}" -f $($Event.TimeCreated);
        Time        = "{0:HH:mm:ss}" -f $($Event.TimeCreated);
      }
      $4625arr += New-Object psobject -property $4625
    }
    catch { "$($_.exception.message)" }        
  }
  
  $4625arr | Format-Table
}

function LogonUsers {
  <#
.SYNOPSIS
Remote PC LocalGroup Member Modify cmdlet

.DESCRIPTION
Remote PC LocalGroup Member Add and Delete

.PARAMETER ComputerName
Remote PC Hostname

.PARAMETER Username
Modify Target AD Username
 
.PARAMETER Groupname
Default Setting = LogonUsers
Target GroupName Editable

.PARAMETER Delete
Switch Paramter. Delete Operation

.PARAMETER Add
Switch Paramter. Add Operation

.EXAMPLE
LogonUsers -ComputerName TargetComputer -GroupName Administrators -Username ExamUser1, ExamUser2, ExamUser3 -Add

이 명령을 실행하면 ComputerName 은 TargetComputer, GroupName 은 Administrators 인 그룹에 Username ExamUser1,2,3 을 추가하게 됩니다.

.EXAMPLE
LogonUsers -ComputerName TargetComputer -Username ExamUser1 -Delete

이 명령을 실행하면 ComputerName 은 TargetComputer, GroupName 은 LogonUsers 인 그룹(Parameter Default Setting = LogonUsers)에서 Username ExamUser1 을 삭제하게 됩니다.

.EXAMPLE
LogonUsers -ComputerName TargetComputer -Query

이 명령을 실행하면 ComputerName 은 TargetComputer, GroupName 은 LogonUsers 의 (Parameter Default Setting = LogonUsers)의 멤버를 조회합니다.

.NOTES
20-12-04 Script Created.
#>

  [cmdletbinding(SupportsShouldProcess)]
  param(
    [parameter(Mandatory, position = 0)]
    [string]$ComputerName,
    [parameter(Mandatory, position = 1)]
    [string[]]$Username,
    [string]$Groupname = 'LogonUsers',
    [switch]$Delete,
    [Switch]$Add,
    [Switch]$Query
  )  

  begin {
    $Session = New-PSSession $ComputerName
    $VerbosePreference = 'continue'
    $DebugPreference = 'continue'
  }

  process {
    try {
      $Network = [System.Net.NetworkInformation.Ping]::new().SendPingAsync("$ComputerName", 1).Result.Status
      Write-Verbose -Message 'Checking Network Status..'
      if ($Network -eq 'success') {
        $PortNumber = '5985'
        Write-Verbose -message 'Checking Port Listen..'
        $PortCheck = Test-NetConnection $ComputerName -Port $PortNumber

        if ($PortCheck.TcpTestSucceeded) {
          Write-Verbose -message 'Checking Service..'
          $Service = Get-Service -ComputerName $Computername WinRM 
      
          if ($Service -eq 'Stopped') {
            Write-Host -fore cyan -message 'WinRM Service Start'
            $Service.start()
          }

          if ($PSCmdlet.ShouldProcess($ComputerName)) {
            if ($PSCmdlet.ShouldContinue("Do you Start $ComputerName LocalGroup : $Groupname Member Modify Process?", "Confirm Chcek")) {
              foreach ($User in $Username ) {
                if ($Add) {
                  Write-Verbose -Message "`nGroupname : $Groupname / Username : $user`tAdd"
                  Invoke-Command $Session { 
                    param([string]$Groupname, [string]$UserName)
                    Add-LocalGroupMember $Groupname $UserName } -ArgumentList $Groupname, $User
                }
                if ($Delete) {
                  Write-Verbose -Message "`nGroupname : $Groupname / Username : $user`tDelete"
                  Invoke-Command $session { 
                    param([string]$Groupname, [string]$UserName)
                    Remove-LocalGroupMember $Groupname $UserName } -ArgumentList $Groupname, $User
                }
                if ($Query) {
                  Write-Verbose -Message "`nGroupname : $Groupname Member Query"
                  Invoke-Command $session { 
                    param([string]$Groupname)
                    Get-LocalGroupMember $Groupname } -ArgumentList $Groupname
                }
              }
            }
          }
        }
        else {
          Write-Error -Message 'Port Block. 445 ADSI Retry'
          try {
            if ($Add) {
              LocalGroupModify -IP $ComputerName -Username $Username -GroupName $Groupname -add
            }
          
            if ($Delete) {
              LocalGroupModify -IP $ComputerName -Username $Username -GroupName $Groupname -delete
            }
          }
          catch {
            Write-Debug -Message "$($_.Exception.message)"      
          }
        }

        
      }
        
      $VerbosePreference = 'SilentlyContinue'
      $DebugPreference = 'SilentlyContinue'
    }
    catch {
      Write-Debug -Message "$($_.Exception.message)"
    }
  }
}



function LocalGroupModify {
  <#
  .SYNOPSIS
  Use this command when block WinRM(5985)
  
  .DESCRIPTION
  LocalGroup Member Moidfy Function
  
  .PARAMETER IP
  Target PC IP or Hostname
  
  .PARAMETER Username
  Working UserName
  
  .PARAMETER GroupName
  Working LocalGroup Name (Default=LogonUsers)
  
  .PARAMETER add
  Switch Add. Modifying Add LocalGroup Member
  
  .PARAMETER delete
  Switch Delete. Modifying Deleting LocalGroup Member
  
  .EXAMPLE
  LocalGroupModify 45.10.115.140 TD4231 -Add

  이 명령을 실행하면 LogonUsers 그룹에 TD4231 계정을 추가합니다.

  .EXAMPLE
  LocalGroupModify 45.10.115.140 TD4231 -Delete

  이 명령을 실행하면 LogonUsers 그룹에 TD4231 계정을 삭제합니다.
  
  .NOTES
  Created by. 정석원 (201223)
    - LogonUsers(WinRM) Function - 5985
    - LocalGroupModify(ADSI) Function - 445
  #>
  
  [cmdletbinding()]
        
  param(
    [parameter(Mandatory, position = 1)]  # Must Input Target
    [string]$IP,
    [parameter(position = 2)]             # Multi Input Username with comma (ex)123456, 789012)
    [string[]]$Username,
    [string]$GroupName = 'LogonUsers', # Default LocalGroup Name
    [Switch]$add, # Switch Param
    [Switch]$delete                       # Switch Param
  )

  # Target Network Status Check
  $Connect = [System.Net.NetworkInformation.ping]::new().SendPingAsync($ip, 1).Result.Status

  # Define Result Condition
  if ($Connect -eq 'Success') {

    # Default Multi Job Framework
    foreach ($Users in $Username) {
      $DomainName = $env:USERDOMAIN
      # Define Group Var
      $Group = [ADSI]"WinNT://$IP/$GroupName,group" 
      # Define User Var
      $Users = [ADSI]"WinNT://$DomainName/$Users,user"

    
      if ($add) {
        $Group.add($Users.Path)
        Write-Host "$Users ..." -NoNewline ; Write-Host "Insert Compleate" -ForegroundColor Green
      } 
      if ($delete) {
        $Group.remove($Users.Path)      
        Write-Host "$Users ..." -NoNewline ; Write-Host "Deete Compleate" -ForegroundColor Red
      }
    }
  }
  else {
    "Not Connect"
  }
}

# 원격 컴퓨터 CIM Method 전달

function Set-RemoteWork {
  <#
  .SYNOPSIS
  원격 컴퓨터 강제 로그오프, 재부팅 CIM Method 전달 도구
  
  .DESCRIPTION
  
  
  .PARAMETER ComputerName
  대상 컴퓨터 이름 지정
  
  .PARAMETER Reboot
  리부팅
  
  .PARAMETER Logoff
  로그오프
  
  .EXAMPLE
  Remote-Work -ComputerName <ComputerName> -Reboot
  이 명령어를 입력하면 대상 컴퓨터가 리부팅 됩니다.
  
  .EXAMPLE
  Remote-Work -ComputerName <ComputerName> -Logoff
  이 명령어를 입력하면 대상 컴퓨터의 연결된 모든 세션이 강제 로그오프 됩니다.

  .NOTES
  Created 21.01.15 
   - Logoff, Reboot CIM Method 전달 스크립트 작성
  #>
  [cmdletbinding(SupportsShouldProcess)]

  param (
    [string[]]$ComputerName,
    [switch]$Reboot,
    [Switch]$Logoff
  )

  foreach ($Computer in $Computername) {

    $opt = New-CimSessionOption -Protocol Dcom
    Write-Host "Join $COmputer CIM Session"
    $Session = New-CimSession -ComputerName $computer -SessionOption $opt
    $Query = "Select * from Win32_Operatingsystem"
    
    if ($Reboot) {
      Write-Host "Reboot $COmputer"
      if ($PSCmdlet.ShouldProcess($computer)) {
        if ($PSCmdlet.ShouldContinue("Do you Reboot Process Confirm? Target : $Computer", "Confirm Chcek")) {
          Invoke-CimMethod -Query $Query -CimSession $Session -MethodName Reboot | 
            Add-Member -MemberType ScriptProperty -Name ReturnValueFriendly -PassThru -Value {
              switch ([int]$this.ReturnValue) {
                0 { 'Success' }
                default { "Unknown Error $_" }
              }
            }
        }
      }
    }

    if ($Logoff) {
      Write-Host "Force Logoff Current Session."
      if ($PSCmdlet.ShouldProcess($computer)) {
        if ($pscmdlet.ShouldContinue("Do you Logoff All Session? Target : $Computer", "Confirm Chcek")) {
          Invoke-CimMethod -Query $Query -CimSession $Session -MethodName Win32Shutdown -Arguments @{Flags = 4 } | # 0 : Normal Logoff, 1 : Shutdown , 2 : Reboot, 8 : Power Off
          Add-Member -MemberType ScriptProperty -Name ReturnValueFriendly -PassThru -Value {
            switch ([int]$this.ReturnValue) {
              0 { 'Success' }
              default { "Unknown Error $_" }
            }
          }
      } 
    }
  }
      
  Write-Host "Remove $Computer CIM Session"
  Remove-CimSession -CimSession $Session
}
}

function Set-Quota {

  [cmdletbinding()]
  param (
    [parameter(ValueFromPipeline)]
    [string[]]$InputText
  )

  begin {
    $arr = @()
  }

  process {
    $DoubleQuota = '"'
    $arr += $DoubleQuota + $InputText + $DoubleQuota
  }  

  end {
    $arr -join ','
  }
  
}

function Get-CimSessionRecord {
  param(
    [string[]]$Target,
    [string]$protocol = 'dcom'
  )

  $VerbosePreference = 'continue'

  try {
    $opt = New-CimSessionOption -Protocol $protocol
  $Workload = @()

  Write-Verbose 'Filtering Online Object'

  # Filtering Online Object
  foreach ($T in $Target) {
    $workload += [pscustomobject]@{
      Name  = $T
      Check = $(if ([System.Net.NetworkInformation.Ping]::new().SendPingAsync($T, 1).Result.Status -eq 'success') { 'True' } else { 'False' })
    }
  }

  # Selct Online Object value is 'True' 
  $WorkTarget = $Workload | Where-Object { $_.Check -eq 'True' }
  
  # Offline Object Report
  $OfflineObject = $Workload | Where-Object check -eq 'False'
  if ($OfflineObject.count -gt 1) {
    $DebugPreference = 'continue'
    Write-Debug 'Reporting Offline Object'
    $OfflineObject | Out-GridView -Verbose
    $DebugPreference = 'SilentlyContinue'
  }
     
  # Online Object CIM Instance Create
  New-CimSession -ComputerName $WorkTarget.Name -SessionOption $opt
  }
  catch {
    $DebugPreference = 'continue'
    Write-Debug "Error:$($_.exception.message)"
  }
  

  $VerbosePreference = 'SilentlyContinue'
}


function Permissions {            

    param($GpoName = $ComboBox.SelectedItem)
    Import-Module GroupPolicy            
  
    $permsobj = Get-GPPermissions -Server IMADTP.samsungsecurities.local -Name $GPOName -All
    foreach ($perm in $permsobj) {            
  
      $obj = New-Object -TypeName PSObject -Property @{
        GPOName     = $GPOName
        AccountName = $($perm.trustee.name)
        AccountType = $($perm.trustee.sidtype.tostring())
        Permissions = $($perm.permission)
      }
  
      $obj | Select-Object GPOName, AccountName, AccountType, Permissions            
  
    }
  }
  
  $SearchButtonFunction = {
    $name = $TextBox.Text
                         
    $GPOReesult = Get-GPO -All | Where-Object { $_.displayname -like "*$name*" } | Sort-Object Displayname -Unique | Select-Object -ExpandProperty DisplayName
    foreach ($GPO in $GPOReesult) { $ComboBox.Items.Add($GPO) }        
          
    $ComboBox.Visible = $True
    $ComboBox.SelectedIndex = 0
    $ModeGroupBox.Enabled = $True
  }
  