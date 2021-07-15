---
external help file: Win32_Service-help.xml
Module Name: Win32_Service
online version: 1.0.0
schema: 2.0.0
---

# Edit-WmiServiceProperty

## SYNOPSIS
Win32_Service Class 개체의 Property 수정 도구

## SYNTAX

### ByName (Default)
```
Edit-WmiServiceProperty [[-Name] <String[]>] [[-DisplayName] <String>] [[-PathName] <String>]
 [[-ServiceType] <UInt32>] [[-ErrorControl] <UInt32>] [[-StartName] <String>] [[-StartPassword] <String>]
 [-DesktopInteract] [[-LoadOrderGroup] <String>] [[-LoadOrderGroupDependencies] <String[]>]
 [[-ServiceDependencies] <String[]>] [[-CimSession] <CimSession[]>] [[-ThrottleLimit] <Int32>] [-AsJob]
 [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### InputObject (cdxml)
```
Edit-WmiServiceProperty [-InputObject] <CimInstance[]> [[-DisplayName] <String>] [[-PathName] <String>]
 [[-ServiceType] <UInt32>] [[-ErrorControl] <UInt32>] [[-StartName] <String>] [[-StartPassword] <String>]
 [-DesktopInteract] [[-LoadOrderGroup] <String>] [[-LoadOrderGroupDependencies] <String[]>]
 [[-ServiceDependencies] <String[]>] [[-CimSession] <CimSession[]>] [[-ThrottleLimit] <Int32>] [-AsJob]
 [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Edit-WmiServiceProperty 명령어는 CIM Protocol 을 사용한 로컬, 원격 시스템의 서비스의 속성을 관리할 수 있습니다.
개체제어를 위해 CIM Instance 를 생성해야 하며 원격 개체를 지정하지 않은 경우 로컬 시스템 서비스 속성을 제어합니다.

## EXAMPLES

### Example 1 : 대상 컴퓨터의 서비스 표시 이름 변경
```powershell
PS C:\> $Session = New-CimSession -ComputerName <ComputerName>
PS C:\> Edit-WmiServiceProperty -Name BITS -DisplayName 'Test'
PS C:\> Get-WmiService -Name BITS | Select-Object DisplayName

DisplayName
-----------
test
```

이 예제는 대상 서비스의 DisplayName 속성의 값을 'Test' 로 변경 합니다. Get-WmiServce 를 통해 서비스 검색 후 파이프라인 캡처를 통한 작업도 가능합니다.

### Example 2 : 서비스 로그온 계정 변경
```powershell
PS C:\> Get-WmiService -Name BITS | Edit-WmiServiceProperty -StartName '<Domain>\<Username>'
```

이 예제는 대상 서비스의 로그온 속성을 수정합니다. 서비스 시작 계정을 지정하는 경우 암호 입력란을 입력하지 않게 되면 자동으로 암호화된Null 처리를 합니다.

### Example 3 : 로컬 시스템 계정으로 실행 시 데스크탑과 상호작용 허용. 로그온 계정이 LocalSystem 이 아니라면 변경 후 체크박스 Enable
```powershell
PS C:\> $Service = Get-WmiService -Name BITS
PS C:\> if ($Service.StartName -ne 'LocalSystem')  {
          $Service | Edit-WmiServiceProperty -DesktopInteract
        }
PS C:\> $Service = Get-WmiService -Name BITS | Select DesktopInteract        

desktopinteract
---------------
          True
```

이 예제는 서비스의 데스크탑 상호작용 스위치를 Enable 합니다. 로그온 계정이 LocalSystem 일 때만 설정할 수 있으며 화면보호기 등 LogonUI.dll 프로세스를 거치기 전 단계의 
Idle 상태에서 데스크탑 환경과의 서비스 상호작용을 가능하게 합니다.

### Example 4 : 서비스 로그온 계정과 패스워드 변경
```powershell
PS C:\> $Service = Get-WmiService -Name BITS
PS C:\> $password = Read-Host 'Input Password'
PS C:\> $Service | Edit-WmiServiceProperty -StartName $cred.UserName -StartPassword $cred.Password
PS C:\> $Service | Select-Object StartName

StartName
---------
<Domain>/<UserName>
```

이 예제는 대상 서비스의 로그온 계정과 패스워드를 설정해서 지정한 계정이 아니면 서비스를 제어할 수 없도록 변경합니다.
변경 후에는 설정된 계정이 아닌 계정으로 서비스를 제어하려고 할 때 오류코드 15 (시스템이 지정된 드라이브를 찾을 수 없습니다) 를 반환하며 실패합니다.
파라미터에 대한 자세한 설명은 Help Edit-WmiServiceProperty -Full 을 입력 후 파라미터 설명을 참고하세요.

## PARAMETERS

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

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DesktopInteract
서비스가 데스크탑에서 창을 만들거나 통신 할 수 있는지 여부를 나타냅니다. 따라서 사용자와 어떤 방식으로든 상호작용 할 수 있습니다.
대화형 서비스는 로컬 시스템 계정으로 실행되어야 합니다. 대부분의 서비스는 대화형이 아닙니다. 즉 어떤식으로든 사용자와 통신하지 않습니다.

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
서비스의 표시 이름 제어

```yaml
Type: String
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
Type: UInt32
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject

```yaml
Type: CimInstance[]
Parameter Sets: InputObject (cdxml)
Aliases:

Required: True
Position: 명명됨
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -LoadOrderGroup
연관된 그룹 이름입니다. 로드 순서 그룹은 시스템 레지스트리에 포함되어 있으며 서비스가 운영 체제에로드되는 순서를 결정합니다. 
포인터가 NULL이거나 빈 문자열을 가리키는 경우 서비스는 그룹에 속하지 않습니다. 그룹 간의 종속성은 LoadOrderGroupDependencies 매개 변수에 나열되어야합니다. 

로드 순서 지정 그룹 목록의 서비스가 먼저 시작되고로드 순서 지정 그룹 목록에없는 그룹의 서비스가 시작된 다음 그룹에 속하지 않는 서비스가 시작됩니다. 
시스템 레지스트리에는 다음 위치에있는로드 순서 지정 그룹 목록이 있습니다. 

HKEY_LOCAL_MACHINE \ System \ CurrentControlSet \ Control \ ServiceGroupOrder

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LoadOrderGroupDependencies
이 서비스를 시작하기 전에 시작해야하는로드 순서 지정 그룹 목록입니다. 배열은 이중 널로 종료됩니다. 포인터가 NULL이거나 빈 문자열을 가리키는 경우 서비스에 종속성이 없습니다. 
서비스 및 서비스 그룹은 동일한 네임 스페이스를 공유하기 때문에 서비스 이름과 구분하기 위해 그룹 이름 앞에 SC_GROUP_IDENTIFIER (Winsvc.h 파일에 정의 됨) 문자를 붙여야합니다. 
그룹에 대한 종속성은 그룹의 모든 구성원을 시작하려고 시도한 후 그룹의 구성원 중 하나 이상이 실행중인 경우이 서비스를 실행할 수 있음을 의미합니다.

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

### -Name
대상 서비스 이름

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

### -PassThru
새로 생성되거나 수정된 개체를 숨기는 대신 전달하도록 강제하는 매개변수입니다.

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

### -PathName
서비스를 구현하는 실행 파일의 정규화 된 경로입니다 (예 : "\ SystemRoot \ System32 \ drivers \ afd.sys").

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ServiceDependencies
이 서비스를 시작하기 전에 시작해야하는 서비스 이름이 포함 된 목록입니다. 배열은 이중 NULL로 종료됩니다. 
포인터가 NULL이거나 빈 문자열을 가리키는 경우 서비스에 종속성이 없습니다. 서비스에 대한 종속성은이 서비스가 종속 된 서비스가 실행중인 경우에만 실행할 수 있음을 나타냅니다.

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

### -ServiceType
호출하는 프로세스에 제공되는 서비스 유형입니다. 


1 (0x1) 커널 드라이버 
2 (0x2) 파일 시스템 드라이버 
4 (0x4) 어댑터 
8 (0x8) 인식기 드라이버 
16 (0x10) 자체 프로세스 
32 (0x20) 프로세스 공유 
256 (0x100) 대화 형 프로세스

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

### -StartName
서비스가 실행되는 계정 이름입니다. 서비스 유형에 따라 계정 이름은 DomainName\Username 또는.\Username 형식 일 수 있습니다. 
서비스 프로세스는 실행될 때이 두 가지 형식 중 하나를 사용하여 기록됩니다. 계정이 기본 제공 도메인에 속하는 경우 .\Username 을 지정할 수 있습니다. 
NULL을 지정하면 서비스가 LocalSystem 계정으로 로그온됩니다. 
커널 또는 시스템 수준 드라이버의 경우 StartName에는 입출력 (I/O) 시스템이 장치 드라이버를로드하는 데 사용하는 드라이버 개체 이름 (즉, \FileSystem\Rdr 또는 \Driver\Xns)이 포함됩니다. 
NULL이 지정되면 드라이버는 서비스 이름을 기반으로 I/O 시스템에서 만든 기본 개체 이름 (예 :"DWDOM\Admin")으로 실행됩니다.

UPN (User Principal Name) 형식을 사용하여 시작 이름 (예 : Username @ DomainName)을 지정할 수도 있습니다.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartPassword
StartName 매개 변수로 지정된 계정 이름의 비밀번호입니다. 비밀번호를 변경하지 않는 경우 NULL을 지정하십시오. 서비스에 비밀번호가없는 경우 빈 문자열을 지정하십시오.

```yaml
Type: String
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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: 명명됨
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Microsoft.Management.Infrastructure.CimInstance[]

## OUTPUTS

### Microsoft.Management.Infrastructure.CimInstance

### Microsoft.Management.Infrastructure.CimInstance#Root/CIMV2/Win32_Service

## NOTES

## RELATED LINKS
