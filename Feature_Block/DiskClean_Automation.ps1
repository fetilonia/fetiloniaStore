<#
.SYNOPSIS
  Windows Update 항목만 체크 후 디스크 정리 실행 스크립트
.DESCRIPTION
  전체 항목 체크 해제 후 업데이트 항목만 체크 하도록 구성됨.
.FORWARDHELPCATEGORY
  ScriptCommand
.INPUTS
  Inputs (if any)
.OUTPUTS
  Output (if any)
.NOTES
  20.11.05 테스트 완료
#>

param(
  [cmdletbinding()]
  [parameter(ValueFromPipeline)]
  [string]$path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\'
  )

begin {
  $ValueSet = Get-ChildItem $Path | ForEach-Object {
    [pscustomobject]@{
      Name  = $_.PSChildName;
      Type  = $_.GetValueKind('StateFlags0001');
      Value = $_.GetValue('StateFlags0001');
    }
  }
}

process {
  try {
    if (($ValueSet.Value -eq 2).count -gt 1) {
      Get-ChildItem $Path\* | ForEach-Object { Set-ItemProperty -Path $_.pspath -Name StateFlags0001 -Value 0 }
      Write-Output "$("{0:HH:mm:ss}" -f (Get-Date)) Check Reset" >> c:\temp\log.txt
      Set-ItemProperty -Path "$Path\Update Cleanup" -Name 'StateFlags0001' -Value 2 -Force
      Write-Output "$("{0:HH:mm:ss}" -f (Get-Date)) Special Value Set" >> c:\temp\log.txt
    }
    else {
      Set-ItemProperty -Path "$Path\Update Cleanup" -Name 'StateFlags0001' -Value 2 -Force
      "$("{0:HH:mm:ss}" -f (Get-Date)) Special Value Set" >> c:\temp\log.txt
    }
    if ((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup\' -Name stateflags0001).stateflags0001 -eq 2) {
      "$("{0:HH:mm:ss}" -f (Get-Date)) Disk Clean Start" >> c:\temp\log.txt
      Start-Process cleanmgr -ArgumentList ' /d c: sagerun:1 /verylowdisk /autoclean' -Wait
      Write-Output "$("{0:HH:mm:ss}" -f (Get-Date)) Update Cleanup Flags Value : $((Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup\' -Name stateflags0001).stateflags0001)" >> c:\temp\log.txt
    }
    
    
  }
  catch {
    "Exception:$($_.Exception.message)" >> c:\Temp\$env:COMPUTERNAME.txt
  }
}

