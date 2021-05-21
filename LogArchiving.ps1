function LogArchive {
    [cmdletbinding()]
     
    param(
      [parameter(Mandatory)]  
      [ValidateSet('yyyyMMdd', 'yyyyMM', 'yyyy')]
      [string]$date,
      [string]$Path,
      [String]$TargetPath
    )
     
     
    $Source = Get-ChildItem $Path -file -Recurse | ForEach-Object { [pscustomobject]@{name = $_.name; time = $("{0:$date}" -f ($_.lastwritetime)); path = $_.fullname } }
    $SourceGroup = $Source | Group-Object time
    foreach ($date in $SourceGroup.name) { 
      $Source | Where-Object time -eq $date | Compress-Archive -DestinationPath "$TargetPath\$date.zip"
    }
  }
  #Example : LogArchive -date yyyy -Path $env:temp -TargetPath $env:temp