---
external help file: Win32_Service-help.xml
Module Name: Win32_Service
online version:
schema: 2.0.0
---

# Get-WmiService

## SYNOPSIS
Get-Service 에서 반환되는 항목보다 자세한 정보를 얻기 위해 사용합니다.
Win32_Service Class 를 기반으로 동작하며 복잡한 WMI Method 를 간단한 명령어 방식으로 실행할 수 있습니다.

## SYNTAX

### ByName (Default)
```
Get-WmiService [-AcceptPause] [-AcceptStop] [[-CheckPoint] <UInt32[]>] [[-CreationClassName] <String[]>]
 [-DelayedAutoStart] [[-Description] <String[]>] [-DesktopInteract] [[-DisplayName] <String[]>]
 [[-ErrorControl] <String[]>] [[-ExitCode] <UInt32[]>] [[-BeforeInstallDate] <DateTime>]
 [[-AfterInstallDate] <DateTime>] [[-Name] <String[]>] [[-ExcludeName] <String[]>] [[-PathName] <String[]>]
 [[-ServiceSpecificExitCode] <UInt32[]>] [[-ServiceType] <String[]>] [-Started] [[-StartMode] <String[]>]
 [[-StartName] <String[]>] [[-State] <String[]>] [[-Status] <String[]>] [[-TagId] <UInt32[]>]
 [[-MinWaitHint] <UInt32>] [[-MaxWaitHint] <UInt32>] [[-CimSession] <CimSession[]>] [[-ThrottleLimit] <Int32>]
 [-AsJob] [<CommonParameters>]
```

### ByProcessId
```
Get-WmiService [-AcceptPause] [-AcceptStop] [[-CheckPoint] <UInt32[]>] [[-CreationClassName] <String[]>]
 [-DelayedAutoStart] [[-Description] <String[]>] [-DesktopInteract] [[-DisplayName] <String[]>]
 [[-ErrorControl] <String[]>] [[-ExitCode] <UInt32[]>] [[-BeforeInstallDate] <DateTime>]
 [[-AfterInstallDate] <DateTime>] [[-PathName] <String[]>] [[-ProcessId] <UInt32[]>]
 [[-ServiceSpecificExitCode] <UInt32[]>] [[-ServiceType] <String[]>] [-Started] [[-StartMode] <String[]>]
 [[-StartName] <String[]>] [[-State] <String[]>] [[-Status] <String[]>] [[-TagId] <UInt32[]>]
 [[-MinWaitHint] <UInt32>] [[-MaxWaitHint] <UInt32>] [[-CimSession] <CimSession[]>] [[-ThrottleLimit] <Int32>]
 [-AsJob] [<CommonParameters>]
```

## DESCRIPTION
Win32_Service Class 에서 확인할 수 있는 Property 기반 항목을 매개변수 형식으로 간단하게 조회할 수 있습니다.

## EXAMPLES

### Example 1 : 서비스 State 가 Stopped 인 개체만 검색
```powershell
PS C:\> Get-WmiService -State Stopped
```

이 예제는 Win32_Service Class 에서 조회가능한 Property 중 State 항목이 Stopped 인 개체를 조회합니다.

### Example 2 : 서비스 일시 중지를 지원하는 개체 검색
```powershell
PS C:\> Get-WmiService -AcceptPause
```

이 예제는 일시중지를 지원하는 서비스 항목을 조회합니다.

### Example 3 : 서비스 일시 중지와 중지를 지원하는 개체 검색
```powershell
PS C:\> Get-WmiService -AcceptPause -AcceptStop
```

이 예제는 일시중지와 중지를 지원하는 서비스 항목을 조회합니다.

### Example 4 : 지정 기간 사이에 설치된 서비스 검색
```powershell
PS C:\> $MinDate = "2021-01-01"
PS C:\> $MaxDate = "2021-02-01"
PS C:\> Get-WmiService -BeforeInsatllDate $MinDate -AfterInstallDate $Maxdate
```

이 예제는 MinDate 변수에 지정한 날짜와 MaxDate 변수에 지정한 날짜 사이에 해당하는 InstallDate Property 값을 검색합니다.

### Example 5 : Service 의 PathName 이 특정 문자열을 포함하는 개체를 검색
```powershell
PS C:\> $path = 'apsrv'
PS C:\> Get-WmiService -PathName "*$path*"
```

이 예제는 PathName Property 에서 Path 변수에 지정한 문자열을 포함하는 개체를 반환합니다.

## PARAMETERS

### -AcceptPause
서비스를 일시 중지 할 수 있는지 여부를 나타냅니다.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AcceptStop
서비스를 중지 할 수 있는지 여부를 나타냅니다.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AfterInstallDate
InstallDate Property 를 쿼리할 때 Max 값이 되는 DateTime (ex."2011-01-05")

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AsJob
백그라운드 Job 생성

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BeforeInstallDate
InstallDate Property 를 쿼리할 때 Min 값이 되는 DateTime (ex."2011-01-05")

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CheckPoint
장기 시작, 중지, 일시 중지 또는 계속 작업 중에 진행 상황을보고하기 위해 서비스가 주기적으로 증가하는 값입니다. 
예를 들어 서비스는 시작될 때 초기화의 각 단계를 완료 할 때이 값을 증가시킵니다. 서비스에서 작업을 호출하는 사용자 인터페이스 프로그램은이 값을 사용하여 긴 작업 동안 서비스의 진행 상황을 추적합니다. 이 값은 유효하지 않으며 서비스에 보류중인 시작, 중지, 일시 중지 또는 계속 작업이없는 경우 0 이어야합니다.

```yaml
Type: UInt32[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CimSession
원격으로 대상 세션을 작업 할 때 사용합니다. 정의 항목은 다중을 허용하며 인스턴스화 된 객체를 호출합니다.

```yaml
Type: CimSession[]
Parameter Sets: (All)
Aliases: Session

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CreationClassName
인스턴스 생성에 사용되는 상속 체인에 나타나는 첫 번째 구체적인 클래스의 이름입니다. 클래스의 다른 키 속성과 함께 사용되는 경우이 속성을 사용하면이 클래스 및 해당 하위 클래스의 모든 인스턴스를 고유하게 식별 할 수 있습니다.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DelayedAutoStart
true 이면 다른 자동 시작 서비스가 시작되고 잠시 지연된 후 서비스가 시작됩니다. 이 속성은 Windows Server® 2016 및 Windows® 10 이전에는 지원되지 않습니다.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Description
개체에 대한 설명입니다.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DesktopInteract
서비스가 데스크톱에서 창을 만들거나 통신 할 수 있는지 여부를 나타냅니다. 따라서 사용자와 어떤 방식 으로든 상호 작용할 수 있습니다. 
대화 형 서비스는 로컬 시스템 계정으로 실행되어야합니다. 대부분의 서비스는 대화 형이 아닙니다. 즉, 어떤 식 으로든 사용자와 통신하지 않습니다.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayName
서비스 스냅인에 표시되는 서비스의 이름입니다. 이 문자열의 최대 길이는 256 자입니다. 
표시 이름과 서비스 이름 (레지스트리에 저장 됨)이 항상 같지는 않습니다. 예를 들어 DHCP 클라이언트 서비스의 서비스 이름은 Dhcp이지만 표시 이름은 DHCP 클라이언트입니다. 
이름은 서비스 제어 관리자에서 대소 문자가 유지됩니다. 그러나 DisplayName 비교는 항상 대소 문자를 구분하지 않습니다. 제약 : Name 속성과 동일한 값을 적용합니다. 

예 : "Atdisk"

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ErrorControl
서비스가 시작 중 시작되지 않는 경우 오류의 심각도 설정. 이 값은 실패가 발생하는 경우 시작 프로그램이 취한 조치를 나타냅니다.



Ignore    사용자에게 알림 표시 안함
Normal    사용자에게 알림 표시. 일반적으로 이것은 사용자에게 문제를 알리는 메시지 상자를 표시합니다.
Servere   마지막으로 성공한 구성으로 시스템이 다시 시작됩니다.
Critical  시스템이 올바른 구성으로 다시 시작하려고 합니다. 서비스가 두번째로 시작되지 않으면 시작이 실패합니다.
Unknown   오류의 심각도를 알 수 없습니다.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: Ignore, Normal, Severe, Critical, Unknown

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludeName
제외할 이름을 지정합니다. (ex. Get-WmiService -Name vm* -ExcludeName *w* vm으로 시작하지만 w 문자열이 포함된 항목을 제외합니다.)


```yaml
Type: String[]
Parameter Sets: ByName
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExitCode
서비스 시작 또는 중지시 발생한 오류를 정의하는 Windows 오류 코드입니다. 이 속성은 오류가이 클래스가 나타내는 서비스에 고유하고 오류에 대한 정보를 ServiceSpecificExitCode 속성에서 사용할 수있는 경우 ERROR_SERVICE_SPECIFIC_ERROR (1066)로 설정됩니다. 서비스는 실행시 및 정상 종료 시 다시 이 값을 NO_ERROR 로 설정합니다.

```yaml
Type: UInt32[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxWaitHint
보류중인 시작, 중지, 일시 중지 또는 계속 작업에 필요한 예상 시간 (밀리 초) 입니다. 지정된 시간이 경과 한 후 서비스는 증분 된 CheckPoint 값 또는 CurrentState를 변경하여 SetServiceStatus 메서드를 다음 번 호출합니다. WaitHint에서 지정한 시간이 지나고 CheckPoint가 증가하지 않았거나 CurrentState가 변경되지 않은 경우 서비스 제어 관리자 또는 서비스 제어 프로그램은 오류가 발생한 것으로 간주합니다. 이 값은 WaitHint 의 값의 최대치를 설정하고 설정 값 의 아래로만 표시합니다.

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinWaitHint
보류중인 시작, 중지, 일시 중지 또는 계속 작업에 필요한 예상 시간 (밀리 초) 입니다. 지정된 시간이 경과 한 후 서비스는 증분 된 CheckPoint 값 또는 CurrentState를 변경하여 SetServiceStatus 메서드를 다음 번 호출합니다. WaitHint에서 지정한 시간이 지나고 CheckPoint가 증가하지 않았거나 CurrentState가 변경되지 않은 경우 서비스 제어 관리자 또는 서비스 제어 프로그램은 오류가 발생한 것으로 간주합니다. 이 값은 WaitHint 의 값의 최대치를 설정하고 설정 값 의 위로만 표시합니다.

```yaml
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
관리되는 기능의 표시를 제공하는 서비스의 고유 식별자입니다. 이 기능은 개체의 Description 속성에 설명되어 있습니다.

```yaml
Type: String[]
Parameter Sets: ByName
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PathName
서비스를 구현하는 서비스 바이너리 파일에 대한 완전한 경로입니다. 예 : "\ SystemRoot \ System32 \ drivers \ afd.sys"

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProcessId
서비스의 프로세스 식별자입니다.

```yaml
Type: UInt32[]
Parameter Sets: ByProcessId
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServiceSpecificExitCode
서비스가 시작되거나 중지되는 동안 발생하는 오류에 대한 서비스 별 오류 코드입니다. 종료 코드는이 클래스가 나타내는 서비스에 의해 정의됩니다. 
이 값은 ExitCode 속성 값이 ERROR_SERVICE_SPECIFIC_ERROR (1066) 인 경우에만 설정됩니다.

```yaml
Type: UInt32[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServiceType
호출 프로세스에 제공되는 서비스 유형입니다. 사용 가능한 값은 아래 내용을 참고해주세요.


'Kernel Driver', 'File System Driver', 'Adapter', 'Recognizer Driver', 'Own Process', 'Share Process', 'Interactive Process'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: Kernel Driver, File System Driver, Adapter, Recognizer Driver, Own Process, Share Process, Interactive Process

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartMode
Windows 기본 서비스의 시작 모드입니다.



Boot Start ("Boot")         운영 체제 로더에 의해 시작된 장치 드라이버입니다. 이 값은 드라이버 서비스에만 유효합니다.
System ("System")           운영 체제 초기화 프로세스에 의해 장치 드라이버가 시작되었습니다. 이 값은 드라이버 서비스에만 유효합니다.
Auto Start ("Automatic")    시스템 시작 중에 서비스 제어 관리자가 서비스를 자동으로 시작합니다.
Demand Start ("Manual")     프로세스가 StartService 메서드를 호출 할 때 서비스 제어 관리자가 시작할 서비스입니다.
Disabled ("Disabled")       더 이상 시작할 수없는 서비스입니다.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: Boot, System, Auto, Manual, Disabled

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartName
서비스가 실행되는 계정 이름입니다. 서비스 유형에 따라 계정 이름은 DomainName\Username 또는.\Username 형식 일 수 있습니다. 
서비스 프로세스는 실행될 때이 두 가지 형식 중 하나를 사용하여 기록됩니다. 계정이 기본 제공 도메인에 속하는 경우 .\Username 을 지정할 수 있습니다. 
NULL을 지정하면 서비스가 LocalSystem 계정으로 로그온됩니다. 
커널 또는 시스템 수준 드라이버의 경우 StartName에는 입출력 (I/O) 시스템이 장치 드라이버를로드하는 데 사용하는 드라이버 개체 이름 (즉, \FileSystem\Rdr 또는 \Driver\Xns)이 포함됩니다. 
NULL이 지정되면 드라이버는 서비스 이름을 기반으로 I/O 시스템에서 만든 기본 개체 이름 (예 :"DWDOM\Admin")으로 실행됩니다.

UPN (User Principal Name) 형식을 사용하여 시작 이름 (예 : Username @ DomainName)을 지정할 수도 있습니다.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Started
서비스가 시작되었는지 여부를 나타냅니다.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -State
기본 서비스의 현재 상태입니다. 사용 가능한 값은 아래 내용을 참고해주세요.


'Stopped', 'Start Pending', 'Stop Pending', 'Running', 'Continue Pending', 'Pause Pending', 'Paused', 'Unknown'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: Stopped, Start Pending, Stop Pending, Running, Continue Pending, Pause Pending, Paused, Unknown

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Status
개체의 현재 상태입니다. 다양한 작동 및 비 작동 상태를 정의 할 수 있습니다.  사용 가능한 값은 아래 내용을 참고해주세요.


'Degraded','Error','Lost Comm','No Contact','NonRecover','OK','Pred Fail','Service','Starting','Stopping','Stressed','Unknown'

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TagId
그룹에서이 서비스에 대한 고유 한 태그 값입니다. 값 0(Zero)은 서비스에 태그가 없음을 나타냅니다. 
태그는 HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\GroupOrderList 에 있는 레지스트리에서 태그 순서 벡터를 지정하여 로드 순서 그룹 내에서 서비스 시작을 주문하는 데 사용할 수 있습니다. 태그는 부팅 또는 시스템 시작 모드가 있는 커널 드라이버 및 파일 시스템 드라이버 시작 유형 서비스에 대해서만 평가됩니다.

```yaml
Type: UInt32[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ThrottleLimit
CIM Session 의 최대 갯수입니다. 기본 설정은 16개 입니다.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### 없음

## OUTPUTS

### Microsoft.Management.Infrastructure.CimInstance

### Microsoft.Management.Infrastructure.CimInstance#Root/CIMV2/Win32_Service

## NOTES

## RELATED LINKS
