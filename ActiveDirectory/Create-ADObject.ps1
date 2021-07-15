[cmdletbinding()]

param(
    [Parameter(Mandatory)]
    [ValidateSet('User', 'Computer', 'Group')]
    [String]$Identity
)

$obj = switch ($Identity) {
    'User' { Import-Csv C:\Users\dit221202\Desktop\CreateADUser.csv }
    'Computer' { Import-Csv C:\Users\dit221202\Desktop\CreateADComputer.csv }
    'Group' { Import-Csv C:\Users\dit221202\Desktop\CreateADGroup.csv }
}

$obj | Add-Member -MemberType NoteProperty -Name Class -Value $Identity

foreach ($data in $obj) {
    switch ($Identity) {
        'User' { 
            New-ADUser @data 
            Set-ADUser -Enabled:$true
        }
        'Computer' {
            New-ADComputer @data 
            Set-ADComputer -Enabled:$true
        }
        'Group' {
            New-ADGroup @data 
            Set-ADGroup -Enabled:$true
        }
    }

}
