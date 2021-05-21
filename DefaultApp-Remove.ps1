#classicshell  
$ClassicShell = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\\* | Where-Object displayname -Match 'Classic\sShell'
 
if ([bool]$ClassicShell) {
  $UninstallString = [regex]::Match($ClassicShell.uninstallstring, '[A-Z0-9]{8}\-[A-Z0-9]{4}\-[A-Z0-9]{4}\-[A-Z0-9]{4}\-[A-Z0-9]{12}').value
  Start-Process MsiExec.exe "/X {$UninstallString} /quiet /norestart"
}
 
#Cortana, Skype 
$DefaultApp = 'Microsoft.SkypeApp', 'Microsoft.549981C3F5F10' | ForEach-Object { Get-AppxPackage -Name "$_" -AllUsers }
 
if ([bool]$DefaultApp) {
    
    foreach ($Apps in $DefaultApp) {
        $SIDs = $Apps.PackageUserInformation.UserSecurityID.SID
     
        # SID 기준 Loop
        foreach ($SID in $SIDs) {
           
          # 검색 앱 별로 동작 구분
          if ($Apps.name -like '*skype*') {
            # 검색한 패키지의 PackageUserInformation 에 등록된 User 전체 삭제
            $Apps | ForEach-Object { Remove-AppxPackage -User $SID -Package $Apps.PackageFullName }
          }
          else {
            $Apps | ForEach-Object { Remove-AppxPackage -User $SID -Package $Apps.PackageFullName }
     
            $Regpath = "registry::HKEY_USERS\$SID\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
             
            # Cortana Button Diable RegValue 가 없다면 생성
            if ([bool]$((Get-Item $Regpath).getvaluenames() | Where-Object { $_ -match 'ShowCortanaButton' })) {
              Set-ItemProperty -Path registry::HKEY_USERS\$SID\$Regpath -Name ShowCortanaButton -Type DWORD -Value 0
            }
          }
        }
      }
}
 
#Onedrive
$path = "$env:Windir\Syswow64\OneDriveSetup.exe"
$Process = Get-Process OneDrive
if ([bool]$Process) {
  Start-Process $path -NoNewWindow -PassThru
}