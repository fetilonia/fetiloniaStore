---
external help file: Win32_Service-help.xml
Module Name: Win32_Service
online version: 1.0.0
schema: 2.0.0
---

# Set-PauseWmiService

## SYNOPSIS
대상 서비스 개체에 PauseService 를 전달해 서비스를 일시 중지 합니다.

## SYNTAX

### ByName (Default)
```
Set-PauseWmiService [[-Name] <String[]>] [[-CimSession] <CimSession[]>] [[-ThrottleLimit] <Int32>] [-AsJob]
 [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### InputObject (cdxml)
```
Set-PauseWmiService [-InputObject] <CimInstance[]> [[-CimSession] <CimSession[]>] [[-ThrottleLimit] <Int32>]
 [-AsJob] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### Example 1 : 대상 서비스 일시 중지
```powershell
PS C:\> Get-WmiService Was | Set-PauseWmiService
PS C:\> Get-WmiService Was

ProcessId Name StartMode State  Status ExitCode
--------- ---- --------- -----  ------ --------
4376      WAS  Manual    Paused OK     0
```

이 예제는 WAS 서비스를 일시 중지 합니다.

### Example 2 : 서비스가 중지 가능한지 확인 후 서비스 중지
```powershell
PS C:\> Get-WmiService -AcceptPause | Select -First 1 | Foreach-Object {if($_.AcceptPause) {Set-PauseWmiService $_}}
PS C:\> Get-WmiService -AcceptPause

ProcessId   Name    StartMode   State   Status  ExitCode
---------   ----    ---------   -----   ------  --------
<ID>        <Name>  Manual      Paused  OK      0
```

이 예제는 일시 중지가 가능한 서비스 중 1 개체를 선택해서 AcceptPuase Property 의 Bool 값이 True 인 경우 서비스 일시 중지를 실행합니다.

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
관리되는 기능의 표시를 제공하는 서비스의 고유 식별자입니다.

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
