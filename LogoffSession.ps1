[cmdletbinding()]

param(
    [string]$Range
)

$1 = (quser) -replace '\s{2,}', ',' | Select-Object -Skip 1

$Result = @()

foreach ($data in $1) {
    $Source = $data -split ','

    if ($Source.Count -gt 5) {
        $Result += [pscustomobject]@{
            Name      = $Source[0]    
            Session   = $Source[1]
            ID        = $Source[2]
            Status    = $Source[3]
            RestTime  = $Source[4]
            LogonDate = $([regex]::Match($Source[5], '\d{4}-\d{2}-\d{2}').value)
        }
    }
    else {
        $Result += [pscustomobject]@{
            Name      = $Source[0]    
            Session   = '-'
            ID        = $Source[1]
            Status    = $Source[2]
            RestTime  = $Source[3]
            LogonDate = $([regex]::Match($Source[4], '\d{4}-\d{2}-\d{2}').value)
        }
    }
}
        
foreach ($ID in $Result) {
        
    $LogoffSession = [regex]::match($ID.RestTime, '[\d]{1,2}\+','').Result

    if ($LogoffSession -eq 'success') {
        if (([TimeSpan]$ID.RestTime).Hours -gt 4 ) {
            Start-Process Logoff -ArgumentList " $($Logoff.ID)"
        }
    }
    else {
        if (([TimeSpan]$ID.RestTime).Hours -gt 4 ) {
            Start-Process Logoff -ArgumentList " $($Logoff.ID)"
        }
    }
}


$Service = Get-WmiObject -Query "Select * From Win32_Service Where Name='TermService'"
        
Get-Process -id $($Service.ProcessID) | Stop-Process -Force
        
do { $ServiceCheck = (Get-Service TermService).Status } until ($ServiceCheck -eq 'Stopped')
        
$Service.StartService()
