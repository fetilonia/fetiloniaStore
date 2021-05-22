---
external help file: Win32_Service-help.xml
Module Name: Win32_Service
online version: 1.0.0
schema: 2.0.0
---

# Edit-WmiServiceStartMode

## SYNOPSIS
Win32_Service Class 를 기반으로 한 서비스 개체의 시작 모드를 제어합니다.

## SYNTAX

### ByName (Default)
```
Edit-WmiServiceStartMode [[-Name] <String[]>] [[-StartMode] <String>] [[-CimSession] <CimSession[]>]
 [[-ThrottleLimit] <Int32>] [-AsJob] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### InputObject (cdxml)
```
Edit-WmiServiceStartMode [-InputObject] <CimInstance[]> [[-StartMode] <String>] [[-CimSession] <CimSession[]>]
 [[-ThrottleLimit] <Int32>] [-AsJob] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
지정한 서비스의 Start Mode 를 제어 합니다.

## EXAMPLES

### Example 1 : 다중 세션의 서비스 상태가 Stop인 경우 Start 하고 시작 모드를 Manual 로 변경
```powershell
PS C:\> $Session = New-CimSession -ComputerName <ComputerName>,<ComputerName>,<ComputerName>...
PS C:\> $Service = Get-WmiService -Name BITS -CimSession $Session
PS C:\> Foreach($S in $Service) {
  if ($S.State -eq 'Stopped') {
    $S | Start-WmiService
  }
  if ($S.StartMode -ne 'Manual') {
    $S | Edit-WmiServiceStartMode -StartMode Manual
  }
  
}
PS C:\> Get-WmiService -CimSession $Session | Select-Object Name,StartMode,State, PSComputerName

Name StartMode State   PSComputerName
---- --------- -----   --------------
BITS Manual    Running <ComputerName>
BITS Manual    Running <ComputerName>
BITS Manual    Running <ComputerName>
...
```

이 예제는 여러개의 세션을 인스턴스화 하고 대상 세션의 지정된 서비스 상태를 확인 후 시작 모드를 지정된 값으로 변경합니다.
인스턴스화 된 다중세션은 Foreach 문으로 반복되며 각 객체가 루프될 때 마다 각 세션의 서비스를 확인 후 서비스가 중지 상태라면 서비스를 시작하고 시작 상태가 Manual 이 아니라면 Manual 로 변경합니다. 마지막으로 인스턴스 객체로 Name, StartMode, State, PSComputerName 객체를 호출하여 객체를 생성합니다.

### Example 2 : 로컬 서비스 문자열 중 VM을 포함하는 서비스의 시작모드를 모두 Disabled 로 변경
```powershell
PS C:\> $Service = Get-WmiService -Name *vm* -State Stopped | Edit-WmiServiceStartMode -StartMode Disabled
PS C:\> Get-WmiService -Name *vm* -State Stopped

ProcessId Name               StartMode State   Status ExitCode
--------- ----               --------- -----   ------ --------
0         vmicguestinterface Disabled  Stopped OK     1077
0         vmicheartbeat      Disabled  Stopped OK     1077
0         vmickvpexchange    Disabled  Stopped OK     1077
0         vmicrdv            Disabled  Stopped OK     1077
0         vmicshutdown       Disabled  Stopped OK     1077
0         vmictimesync       Disabled  Stopped OK     1077
0         vmicvmsession      Disabled  Stopped OK     1077
0         vmicvss            Disabled  Stopped OK     1077
```

이 예제는 여러개의 세션을 인스턴스화 하고 대상 세션의 지정된 서비스 상태를 확인 후 시작 모드를 지정된 값으로 변경합니다.
인스턴스화 된 다중세션은 Foreach 문으로 반복되며 각 객체가 루프될 때 마다 각 세션의 서비스를 확인 후 서비스가 중지 상태라면 서비스를 시작하고 시작 상태가 Manual 이 아니라면 Manual 로 변경합니다. 마지막으로 인스턴스 객체로 Name, StartMode, State, PSComputerName 객체를 호출하여 객체를 생성합니다.

## PARAMETERS

### -AsJob
Asjob 매개변수는 명령을 실행하는 백그라운드 작업을 시작합니다.

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

### -Name

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
문 종료 후 종료코드를 파이프라인으로 전달합니다.

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

### -StartMode
Windows 기본 서비스의 시작 모드입니다.



Boot Start ("Boot")

운영 체제 로더에 의해 시작된 장치 드라이버입니다. 이 값은 드라이버 서비스에만 유효합니다.


System ("System")

운영 체제 초기화 프로세스에 의해 장치 드라이버가 시작되었습니다. 이 값은 드라이버 서비스에만 유효합니다.


Auto Start ("Automatic")

시스템 시작 중에 서비스 제어 관리자가 서비스를 자동으로 시작합니다.


Demand Start ("Manual")

프로세스가 StartService 메서드를 호출 할 때 서비스 제어 관리자가 시작할 서비스입니다.


Disabled ("Disabled")

더 이상 시작할 수없는 서비스입니다.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2002
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
