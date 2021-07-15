
function SessionKill {
  <#
.SYNOPSIS
Remote Session Kill Function

.DESCRIPTION
Remote PC Session Force Kill

.PARAMETER Target
-Target 
Definition Target PC

.EXAMPLE
SessionKill -Target pcname

.NOTES
2020.11.23
  - Session Force Kill 명령어 작성

#>

  [cmdletbinding(SupportsShouldProcess)]
  param(
    [parameter(Mandatory)]
    [string]$Target
  )

  # 대상 PC 네트워크 확인
  $Ping = [System.Net.NetworkInformation.ping]::new().SendPingAsync($Target, 1).Result.status
  try {
    if ($Ping -eq 'success') {
      # 대상 PC Remote Service 확인
      $Service = (Get-Service -ComputerName $Target Winrm)
      if ($Service.Status -eq 'Stopped') {
        Write-Output 'WinRM Service Starting..'
        $Service.start()
        Write-Output 'WinRM Started'
      }
    }
    
    Write-Output "Join $Target Session"
    # 대상 PC PowerShell Session Join
    $Session = New-PSSession $Target
    Write-Output "Query Session $Target "
    # 대상 PC Logon Session 조회
    $quser = Invoke-Command -Session $Session -ScriptBlock { quser /server:localhost }
    Write-Output 'Creating DB Table'
    # 작업용 Small DB 생성
    ($quser | ForEach-Object { $_ -replace '\s{2,}', ',' }) -replace '사용자 이름', 'UserName' `
      -replace '세션 이름', 'SessionName' `
      -replace '상태', 'Status' `
      -replace '유휴 시간', 'RestTime' `
      -replace '로그온 시간', 'LogonTime' > "C:\Temp\$Target.txt"
    $Csv = Import-Csv "C:\Temp\$Target.txt"

    # 수집 DB 콘솔 출력
    $CSV

    # 작업 전 최종 확인 (ShouldProcess)
    if ($PSCmdlet.ShouldProcess($Target)) {
      if ($PSCmdlet.ShouldContinue('Do you Disconnect This Session?', `
          $(if ($CSV.Username.count -gt 1) {
              "Disconnect Session From $("$(($CSV.UserName) -join ',')"), SessionName : $("$(($CSV.SessionName) -join ',')") , ID($("$(($CSV.ID) -join ',')")"
            }
            else {
              "Disconnect Session From $($CSV.UserName), SessionName : $($CSV.SessionName) , ID($($CSV.ID))"
            })
        )) {
        if ($CSV.Username.count -gt 1) {
          foreach ($C in $CSV) {
            Invoke-Command $Session { param([int]$Input) logoff $input } -ArgumentList $C.ID
          } 
        }
        else {
          Invoke-Command $Session { param([int]$Input) logoff $input } -ArgumentList $CSV.ID
        }
      }
    }
  }
  catch {
    Write-Output "StartFail : $($_.exception.message)"
  }
}

$Receive = Read-Host '작업할 대상 컴퓨터 이름을 지정하세요.'

SessionKill -Target $Receive




