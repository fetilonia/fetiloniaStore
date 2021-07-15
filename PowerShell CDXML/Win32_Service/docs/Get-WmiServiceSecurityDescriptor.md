---
external help file: Win32_Service-help.xml
Module Name: Win32_Service
online version: 1.0.0
schema: 2.0.0
---

# Get-WmiServiceSecurityDescriptor

## SYNOPSIS
WMI 메서드에서 호출이 성공했는지 알려주는 종료 코드와 함께 기본 상태 개체와 함께 보안 정보를 반환하는 GetSecurityDescriptor 메서드를 단일 함수로 사용할 수 있습니다.

## SYNTAX

### ByName (Default)
```
Get-WmiServiceSecurityDescriptor [[-Name] <String[]>] [[-CimSession] <CimSession[]>] [[-ThrottleLimit] <Int32>]
 [-AsJob] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### InputObject (cdxml)
```
Get-WmiServiceSecurityDescriptor [-InputObject] <CimInstance[]> [[-CimSession] <CimSession[]>]
 [[-ThrottleLimit] <Int32>] [-AsJob] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### Example 1 : Stand-alone 형식으로 실행
```powershell
PS C:\> Get-WmiServiceSecurityDescriptor -Name Bits

ControlFlags   : 32788
DACL           : {Win32_ACE, Win32_ACE, Win32_ACE, Win32_ACE}
Group          : Win32_Trustee
Owner          : Win32_Trustee
SACL           : {Win32_ACE}
TIME_CREATED   :
PSComputerName :
```

이 예제는 Get-WmiServiceSecurityDescriptor 함수를 독립형 (Stand-Alone) 으로 실행 합니다.

### Example 2 : 파이프라인 전달 형식으로 실행
```powershell
PS C:\> Get-WmiService Bits | Get-WmiServiceSecurityDescriptor

ControlFlags   : 32788
DACL           : {Win32_ACE, Win32_ACE, Win32_ACE, Win32_ACE}
Group          : Win32_Trustee
Owner          : Win32_Trustee
SACL           : {Win32_ACE}
TIME_CREATED   :
PSComputerName :
```

이 예제는 Get-WmiService 함수로 서비스를 조회 후 파이프라인에서 관련 Property 를 캡쳐 후 실행 합니다.

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

### Microsoft.Management.Infrastructure.CimInstance[]

## NOTES

## RELATED LINKS
