function LogonEvent {

    [cmdletbinding()]

    param (
        [string]$Username
    )

    Get-WinEvent -FilterHashtable @{logname = 'security'; data = "$Username" ; starttime = ((Get-date).AddHours(-1)); id = '4624' } | 
    Select-Object @{n = 'LogonComputerName'; e = { [regex]::Match($_.message, '워크스테이션 이름:\s(.*)').value -replace '워크스테이션 이름:\s', '' } }, 
    @{n = 'Domain'; e = { [regex]::Match($_.message, '계정 도메인:\s\s(.*)').value -replace '계정 도메인:\s\s', '' } }, 
    @{n = 'AccountName'; e = { ([regex]::Match($_.message, '새 로그온:[\s\S]+?계정 이름:\s\s(.*)').value) | 
            ForEach-Object { [regex]::Match($_, '[A-Z]{3}[0-9]{6}').value } } 
    },
    @{n = 'IP'; e = { [regex]::Match($_.message, '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b').value } },
    @{n = 'CallProcess'; e = { [regex]::Match($_.message, '프로세스 이름:\s(.*)').value -replace '프로세스 이름:\s\s', '' } },
    @{n = 'AuthPackage'; e = { [regex]::Match($_.message, '인증 패키지:\s(.*)').value -replace '인증 패키지:\s', '' } },
    TimeCreated
}

