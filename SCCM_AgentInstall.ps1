
# Configuration Manager AGent ReInstall 

[cmdletbinding()]

param(
    [string[]]$Comp = $env:COMPUTERNAME,
    [string]$day = "{0:yyMMdd}" -f (get-date),
    [string]$date = "{0:yy-MM-dd}" -f (get-date),
    [string]$time = "{0:HH:mm:ss}" -f (get-date),
    [string]$LogTime = "{0:MM-dd-yyyy}" -f (get-date),
    [string]$LogPath = '\\ad1.dpi.co.kr\SYSVOL\dpi.co.kr\scripts\SCCMAgent\InstallLog'
)

$source = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\\* | Where-Object displayname -like '*confi*'

"Date,Time,Hostname,Message,Category,ResultCode" > "$Logpath\$day`_$Comp`_SCCMAgentJob.csv"
"$date,$time,$env:COMPUTERNAME,Collecting Configuration Manager Installation Info,Information,0" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"

#######################
#region Define cmdlet #
#######################

$ReInstall = 1
$DefaultPath = 'C:\Windows\ccmsetup'
$TempPath = 'C:\Temp'
$Argument = '/MP:nrsystemcenter.dpi.co.kr /logon SMSSITECODE=NR1 SMSSLP=nrsystemcenter.dpi.co.kr SMSCACHESIZE=5120 /skipprereq:scepinstall.exe, 0, false'
$Loop = {
    do {
        $LogCheck = Get-Content C:\windows\ccmsetup\Logs\ccmsetup.log | Select-String -Pattern 'return code 0' | Where-Object { $_ -match $LogTime }
    } until ($LogCheck)
}

<#
$param = @{
            FilePath     = 'C:\Windows\ccmsetup\ccmsetup.exe'
            ArgumentList = ' /MP:nrsystemcenter.dpi.co.kr /logon SMSSITECODE=NR1 SMSSLP=nrsystemcenter.dpi.co.kr SMSCACHESIZE=5120 /skipprereq:scepinstall.exe, 0, false'
            WindowStyle  = 'Hidden'
            Wait         = $true
        }
#>

$DefaultPathRun = { Start-Process -FilePath "$DefaultPath\ccmsetup.exe" -ArgumentList $Argument -Wait }
$TempPathRun = { Start-Process -FilePath "$TempPath\ccmsetup.exe" -ArgumentList $Argument -Wait }
$UnInstall = { Start-Process -FilePath "$TempPath\ccmsetup.exe" -ArgumentList ' /uninstall' -Wait }

##########################
#endregion Define cmdlet #
##########################


foreach ($com in $comp) {

    # SCCM Agent Install Check
    if (-not !$source) {

        #  Define Default Offer Variable
        [version]$CompareVersion = '5.00.8968.1042'
        $CurrentVersion = [version]$source.DisplayVersion | Select-Object -expand Build

        # Installed Version Check
        if ($CurrentVersion -lt $CompareVersion.build) {
            try {
                "$date,$time,$env:COMPUTERNAME,CCMsetup.exe File Copy to Temp Folder,information,0" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
                Copy-Item \\ad1.dpi.co.kr\NETLOGON\SCCMAgent\ccmsetup.exe c:\temp\
                Start-Sleep -Seconds 2
                try {
                    &$DefaultPathRun
                    &$Loop

                    "$date,$time,$env:COMPUTERNAME,SCCM Agent Install Compleate,Information,0" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
                }
                catch {
                    "$date,$time,$env:COMPUTERNAME,Error : $($_.Exception.Message),InstallFail from Setup Loop,20" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"    
                    exit
                }
            }
            catch {
                "$date,$time,$env:COMPUTERNAME,Error : $($_.Exception.Message) from File Copy Action,CopyError,10" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
                exit
            }
            
        }
        else {
            "$date,$time,$env:COMPUTERNAME,SCCM Agent Version is Newest ,VersionEnd ,100" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
            $ReInstall = 0
        }
    }
    else {
        "$date,$time,$env:COMPUTERNAME,SCCM Agent Not Installed Check,information,0" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
        try {
            "$date,$time,$env:COMPUTERNAME,CCMsetup.exe File Copy to Temp Folder,information,0" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
            Copy-Item \\ad1.dpi.co.kr\SYSVOL\dpi.co.kr\scripts\SCCMAgent\ccmsetup.exe c:\temp\
            &$TempPathRun
            &$Loop
            $ReInstall = 0

            "$date,$time,$env:COMPUTERNAME,SCCM Agent Install Compleate,Information,0" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
        }
        catch {
            "$date,$time,$env:COMPUTERNAME,Error : $($_.Exception.Message) from NotInstalled to Setup Action,InstallFail,20" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"    
            exit
        }
    }

    # SCCM Agent Health Check
    Start-Process C:\Windows\CCM\CcmEval.exe -Wait
    # Search to Health Check Compleate Value 
    $ccmevalLog = get-content C:\windows\ccm\Logs\CcmEval.log | Select-String -Pattern 'with value 7' | 
    Where-Object { $_ -match $("{0:MM-dd-yyyy}" -f (Get-date)) }

    #  Check to SCCM Agent Health Value NotEqual 7
    if (!$ccmevalLog) {
        try {
            if ($ReInstall -eq 1) {
                &$UnInstall
                &$Loop
                "$date,$time,$env:COMPUTERNAME,SCCM Agent UnInstall Compleate,Information,0" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
            }
            else {
                "$date,$time,$env:COMPUTERNAME,Agent reInstall Process Check,Information,0" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
            }
        }
        catch {
            "$date,$time,$env:COMPUTERNAME,Error : $($_.Exception.Message), from after Health Check Uninstall Action,20" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"    
            exit
        }
        
        Copy-Item \\ad1.dpi.co.kr\SYSVOL\dpi.co.kr\scripts\SCCMAgent\ccmsetup.exe c:\temp\
        try {
            &$TempPathRun
            &$Loop

            "$date,$time,$env:COMPUTERNAME,SCCM Agent reInstall Compleate,Information,0" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
        }
        catch {
            "$date,$time,$env:COMPUTERNAME,Error : $($_.Exception.Message), from after ReInstall at UnInstall Action,20" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"    
            exit
        }
    }
    else {
        "$date,$time,$env:COMPUTERNAME,Asset Scheduled Task Compleate,Information,0" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
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
    # Client 에 할당된 Scheduled Trigger Task 일괄 실행
    Invoke-WmiMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule $_ -ThrottleLimit 10 
}

# SCCM Agent 정책 할당 평가 , 정책 평가 후 재요청 Method 실행
([wmiclass]"root\ccm:SMS_Client").EvaluateMachinePolicy()
([wmiclass]"root\ccm:SMS_Client").RequestMachinePolicy([uint32]1)
    

# Task 완료 상태 출력 HashTable 작성

$HeadValue = 0
$ReturnTask += [pscustomobject]@{Hostname = $env:COMPUTERNAME }

foreach ($SCCMTask in $Task) {

    $ReturnTask | Add-Member -MemberType NoteProperty `
        -Name $($Head[$HeadValue]) `
        -Value $(if ($SCCMTask.ReturnValue -ne $null) { 
            $SCCMTask.ReturnValue 
            "$date,$time,$env:COMPUTERNAME,$($Head[$HeadValue]) Value is $($SCCMTask.ReturnValue),TaskResult,200" >> "$Logpath\$day`_$comp`_SCCMAgentJob.csv"
        } 
        else { 'OK' }
    )

    $HeadValue++
}

$ReturnTask | Add-Member -MemberType NoteProperty -Name SendTime -Value $("{0:HH:mm:ss}" -f (get-date))

$ReturnTask | Export-Csv -NoTypeInformation -NoClobber -Encoding UTF8 "\\ad1.dpi.co.kr\SYSVOL\dpi.co.kr\scripts\SCCMAgent\TaskStatus\$day`_SCCM_Agent_TaskStatus.csv" -Append

exit