
# Configuration Manager AGent ReInstall 

[cmdletbinding()]

param(
    [string[]]$Comp = $env:COMPUTERNAME,
    [string]$day = "{0:yyMMdd}" -f (get-date),
    [string]$date = "{0:yy-MM-dd}" -f (get-date),
    [string]$time = "{0:HH:mm:ss}" -f (get-date),
    [string]$LogPath = '\\ad1.dpi.co.kr\SYSVOL\dpi.co.kr\scripts\SCCMAgent\InstallLog'
)

$source = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\\* | Where-Object displayname -like '*confi*'

"Date,Time,Message,Category,ResultCode" > "$Logpath\$day`_$Comp`_SCCMAgentJob.csv"
"$date,$time,Collecting Configuration Manager Installation Info,Information,0" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"

foreach ($com in $comp) {

    # SCCM Agent Install Check
    if (-not !$source) {

        #  Define Default Offer Variable
        [version]$CompareVersion = '5.00.8968.1042'
        $CurrentVersion = [version]$source.DisplayVersion | Select-Object -expand Build
        $param = @{
            FilePath     = 'C:\Windows\ccmsetup\ccmsetup.exe'
            ArgumentList = ' /MP:nrsystemcenter.dpi.co.kr /logon SMSSITECODE=NR1 SMSSLP=nrsystemcenter.dpi.co.kr SMSCACHESIZE=5120 /skipprereq:scepinstall.exe, 0, false'
            WindowStyle  = 'Hidden'
            Wait         = $true
        }

        # SCCM Agent Health Check
        Start-Process C:\Windows\CCM\CcmEval.exe -Wait
        # Search to Health Check Compleate Value 
        $ccmevalLog = get-content C:\windows\ccm\Logs\CcmEval.log | Select-String -Pattern 'with value 7' | 
        Where-Object { $_ -match $("{0:MM-dd-yyyy}" -f (Get-date)) -and $_ -like "*$("{0:HH:mm}" -f (Get-date))*" }

        # Installed Version Check
        if ($CurrentVersion -lt $CompareVersion.build) {
            try {
                "$date,$time,CCMsetup.exe File Copy to Temp Folder,information,0" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
                Copy-Item \\ad1.dpi.co.kr\NETLOGON\SCCMAgent\ccmsetup.exe c:\temp\
                Start-Sleep -Seconds 2
                try {
                    Start-Process @param -Wait
                    "$date,$time,SCCM Agent Install Compleate,Information,0" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
                }
                catch {
                    "$date,$time,Error : $($_.Exception.Message),InstallFail,20" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"    
                    exit
                }
            }
            catch {
                "$date,$time,Error : $($_.Exception.Message),CopyError,10" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
                exit
            }
            
        }
        else {
            "$date,$time,SCCM Agent Version is Newest ,VersionEnd ,100" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
        }
    }
    else {
        try {
            Copy-Item \\ad1.dpi.co.kr\NETLOGON\SCCMAgent\ccmsetup.exe c:\temp\
            $param.FilePath = '$Logpath\ccmsetup.exe'
            Start-Process @param
            "$date,$time,SCCM Agent Install Compleate,Information,0" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
        }
        catch {
            "$date,$time,Error : $($_.Exception.Message),InstallFail,20" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"    
            exit
        }
    }
    #  Check to SCCM Agent Health Value NotEqual 7
    if (!$ccmevalLog) {
        Start-Process C:\Windows\ccmsetup\ccmsetup.exe -ArgumentList '/uninstall' -wait
        "$date,$time,SCCM Agent UnInstall,Information,0" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
        Start-Process @param
        "$date,$time,SCCM Agent Install Compleate,Information,0" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
    }
}  

# Configuration Manager Agent Trigger Schedule Force Start

$ReturnTask = @()
$head = @(
   '하드웨어 인벤토리',
   '소프트웨어 인벤토리',
   ' 데이터 검색 레코드',
   ' 파일 컬렉션',
   ' 컴퓨터 정책 할당 요청',
   ' 컴퓨터 정책 평가',
   ' 기본 MP 작업 새로 고침',
   ' LS(위치 서비스) 새로 고침 위치 작업',
   ' LS (위치 서비스) 시간 제한 새로 고침 작업',
   ' 소프트웨어 계량 생성 사용 보고서',
   ' 원본 업데이트 메시지',
   ' 머신 정책 에이전트 정리',
   ' 정책 에이전트 유효성 검사 머신 정책 / 할당',
   ' MP의 AD에서 인증서 다시 시도/새로 고침',
   ' 소프트웨어 업데이트 할당 평가 주기',
   ' 전송되지 않은 상태 메시지 보내기',
   ' 상태 시스템 정책 캐시 정리',
   ' 업데이트 원본으로 검색',
   ' 저장소 정책 업데이트',
   ' 상태 시스템 정책 대량 송신 낮음',
   ' 애플리케이션 관리자 정책 작업',
   ' 전원 관리 시작 요약 작성기'
)

$task = @(
    "{00000000-0000-0000-0000-000000000001}", # 하드웨어 인벤토리
    "{00000000-0000-0000-0000-000000000002}", # 소프트웨어 인벤토리
    "{00000000-0000-0000-0000-000000000003}", # 데이터 검색 레코드
    "{00000000-0000-0000-0000-000000000010}", # 파일 컬렉션
    "{00000000-0000-0000-0000-000000000021}", # 컴퓨터 정책 할당 요청
    "{00000000-0000-0000-0000-000000000022}", # 컴퓨터 정책 평가
    "{00000000-0000-0000-0000-000000000023}", # 기본 MP 작업 새로 고침
    "{00000000-0000-0000-0000-000000000024}", # LS(위치 서비스) 새로 고침 위치 작업
    "{00000000-0000-0000-0000-000000000025}", # LS (위치 서비스) 시간 제한 새로 고침 작업
    "{00000000-0000-0000-0000-000000000031}", # 소프트웨어 계량 생성 사용 보고서
    "{00000000-0000-0000-0000-000000000032}", # 원본 업데이트 메시지
    "{00000000-0000-0000-0000-000000000040}", # 머신 정책 에이전트 정리
    "{00000000-0000-0000-0000-000000000042}", # 정책 에이전트 유효성 검사 머신 정책 / 할당
    "{00000000-0000-0000-0000-000000000051}", # MP의 AD에서 인증서 다시 시도/새로 고침
    "{00000000-0000-0000-0000-000000000108}", # 소프트웨어 업데이트 할당 평가 주기
    "{00000000-0000-0000-0000-000000000111}", # 전송되지 않은 상태 메시지 보내기
    "{00000000-0000-0000-0000-000000000112}", # 상태 시스템 정책 캐시 정리
    "{00000000-0000-0000-0000-000000000113}", # 업데이트 원본으로 검색
    "{00000000-0000-0000-0000-000000000114}", # 저장소 정책 업데이트
    "{00000000-0000-0000-0000-000000000116}", # 상태 시스템 정책 대량 송신 낮음
    "{00000000-0000-0000-0000-000000000121}", # 애플리케이션 관리자 정책 작업
    "{00000000-0000-0000-0000-000000000131}"    # 전원 관리 시작 요약 작성기
) | 
ForEach-Object {
    Invoke-WmiMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule $_ -ThrottleLimit 10 
}

# Task 완료 상태 출력 HashTable 작성

$HeadValue = 0
$ReturnTask += [pscustomobject]@{Hostname = $env:COMPUTERNAME }

foreach ($SCCMTask in $Task) {

    $ReturnTask | Add-Member -MemberType NoteProperty `
                             -Name $($Head[$HeadValue]) `
                             -Value $(if ($SCCMTask.ReturnValue -ne $null) { 
                                 $SCCMTask.ReturnValue 
                                 "$date,$time,$($Head[$HeadValue]) Value is $($SCCMTask.ReturnValue),TaskResult,200" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
                                } 
                                 else { 'OK' }
                                )

    $HeadValue++
}

$ReturnTask | Export-Csv -NoTypeInformation -NoClobber -Encoding UTF8 "\\ad1.dpi.co.kr\SYSVOL\dpi.co.kr\scripts\SCCMAgent\TaskStatus\$day`_SCCM_Agent_TaskStatus.csv" -Append

exit