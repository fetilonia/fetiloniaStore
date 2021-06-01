$dnsrecord = Import-Csv \\nrsystemcenter\SCCM_Package\Etc\AD\All_DNS_Report.csv
$IPRecord = $dnsrecord | Where-Object { $_.ip -like '10.1.1.*' -or $_.recorddata.ipv4address -like '10.1.12.*' -or $_.recorddata.ipv4address -like '58.*' }
$GroupData = $IPRecord | Group-Object ip


$Arr = @()
foreach ($Array in @($(1..255 | ForEach-Object { "10.1.1.$_" }), $(1..255 | ForEach-Object { "10.1.12.$_" }), $(1..255 | ForEach-Object { "58.151.72.$_" }))) {
    foreach ($IP in $Array) {
    
        $DNSRecordOffline = 0
        $Source = ($GroupData | Where-Object name -eq $IP).group.hostname
        $Check = @()

        $Arr += [pscustomobject]@{
            IP            = $IP
            Hostname      = $(if (($GroupData | Where-Object name -eq $ip).count -gt 1) {
                    $Check += $Source | ForEach-Object { [pscustomobject]@{
                            Name = $_
                            Ping = [System.Net.NetworkInformation.Ping]::new().SendPingAsync($_, 1).result.Status 
                        }
                    }

                    if (!($Check | Where-Object { $_ -match 'Success' })) {
                        $DNSRecordOffline = 1
                        
                    }
                    else { $Check.Where( { $_ -match 'success' }, 'First', 1).Name }
                }
                else { $Source })
            Online        = $(if ([System.Net.NetworkInformation.Ping]::new().SendPingAsync($IP, 1).result.status -eq 'success') { 'True' } else { 'False' })
            FragmentCache = $(if ($DNSRecordOffline -eq 1) { $Source -join ',' })
        }

        Clear-Variable -Name Check, Source
    }
}
    