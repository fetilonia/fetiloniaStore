function Invoke-ACL {
    [cmdletbinding()]

    param(
        [parameter(Mandatory, position = 1, HelpMessage = 'Define Target ACL Object Fullpath')]    
        [string[]]$Path,

        [parameter(Position = 2, HelpMessage = 'domain\User')]
        [System.Security.Principal.NTAccount]$Account,

        [parameter(position = 3, HelpMessage = 'Refference a [Enum]::GetNames([Security.AccessControl.FileSystemRight]) ')]
        [System.Security.AccessControl.FileSystemRights]$Permission,

        [Parameter(Position = 4, HelpMessage = '0 = None, 1 = ContainerInherit, 2 = ObjectInherit, 3= Both')]
        [System.Security.AccessControl.InheritanceFlags]$Inherit,

        [Parameter(Position = 5, HelpMessage = '0 = None, 1 = NoPropagateInherit, 2 = InheritOnly, 3 = Both')]
        [System.Security.AccessControl.PropagationFlags]$Propagation,

        [Parameter(Position = 6, HelpMessage = '0 = Allow, 1 = Deny')]
        [System.Security.AccessControl.AccessControlType]$Access

    )

    begin {
        # Define Test Path 
        $Rule = New-Object System.Security.AccessControl.FileSystemAccessRule($Account, $Permission, $Access, $Inherit, $Propagation)
        $InformationPreference = 'Continue'
        $VerbosePreference = 'Continue'
        $DebugPreference = 'Continue'
    }

    process {
        # Select Work Item
        do {
            Write-Host -ForegroundColor Green '1 - Query'
            Write-Host -ForegroundColor Yellow '2 - Add'
            Write-Host -ForegroundColor DarkRed '3 - Remove'
            Write-Host -ForegroundColor Red '4 - Modify Inherit ACE'
            [ValidateRange(1, 3)][int]$SelectItem = Read-Host "Choose Item Number ( 1 - 3 )"
        } until ($SelectItem -match '[1-4]')

        # Set System Path ACL 
        $ACL = Get-Acl $Path

        foreach ($p in $Path) {

            switch ($SelectItem) {
                1 {
                    (Get-acl $P).Access | Format-Table 
                    break
                }

                2 {
                    try {
                        $ACL.SetAccessRule($Rule)
                        $ACL | Set-Acl $p
                    }
                    catch {
                        write-debug "error : $($_.Exception.message)"
                    }
                    break
                }

                3 {
                    try {
                        $ACL.RemoveAccessRule($Rule)
                        $ACL | Set-Acl $p
                    }
                    catch {
                        write-debug "error : $($_.Exception.message)"
                    }
                    break
                }

                4 {
                    do {
                        Write-Host -ForegroundColor Green '1 - Allow Inherit'
                        Write-Host -ForegroundColor DarkRed '2 - Remove Inherit Current ACE'
                        Write-Host -ForegroundColor Yellow '2 - Deny Inherit and Proect Current ACE'
                        Write-Host -ForegroundColor  '2 - Deny Inherit and Proect Current ACE'
                        [ValidateRange(1, 3)][int]$SelectItem = Read-Host "Choose Item Number ( 1 - 3 )"
                    } until ($SelectItem -match '[1-4]') 
                    try {
                        $ACL.SetAccessRuleProtection($true,$false)
                        $ACL | Set-Acl $p
                    }
                    catch {
                        Write-Debug "error :$($_.Excpetion.message)"
                    }
                }
            }
        }
    }
}




