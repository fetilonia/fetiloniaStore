Function Get-FirewallRule
{
    param($Name, $direction, $Enabled, $Protocol, $profile, $action, $grouping)

$Rules = (New-Object -ComObject HNetCfg.FwPolicy2).rules
if ($name) {$rules = $Rules | ? {$_.name -like $name}}
if ($direction) {$Rules = $Rules | ? {$_.direction -eq $direction}}
if ($Enabled) {$Rules = $Rules | ? {$_.Enabled -eq $Enabled}}
if ($Protocol) {$Rules = $Rules | ? {$_.protocol -eq $Protocol}}
if ($profile) {$Rules = $Rules | ? {$_.profiles -band $profile}}
if ($action) {$Rules = $Rules | ? {$_.Action -eq $action}}
if ($grouping) {$Rules = $Rules | ? {$_.Grouping -like $grouping}}

$Rules}
