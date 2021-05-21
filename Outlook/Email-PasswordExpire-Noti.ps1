<#
이 스크립트는 DC 의 모든 사용자 중 패스워드 만료일자가 90일이 지났지만
Today - 10 보다 낮은 User Object 를 필터링 후 개체의 Email 주소로 $From 변수의 주소로 메일을 작성한다.

Line 15, 21, 34, 61 을 수정해서 사용하면 된다.

Created by : fetilonia

#>


################################
#region      Variables         #
################################

# Email account to send the email from
$From = "Search Account"

# Mail server to send the email from
$SMTPServer = "SMTP Server"

# Subject of the email
$MailSubject = "Send Mail Subject"

# Number of days before password expires to start sending the emails
$DaysBeforeExpiry = "10"

# Maximum password age - Maximum amount of days until a password expires. This is an optional variable, if this is left commented,
# the script will find the maximum password age from the group policy's password policy.
$maxPasswordAge = '90'


# Do you wish to setup this script for testing? (Yes/No)
$SetupForTesting = "No"
# What username do you wish to test with?
$TestingUsername = "Test User SamAccountName"


################################
#endregion Variables           #
################################

### Attempts to Import ActiveDirectory Module. Produces error if fails.

Try { Import-Module ActiveDirectory -ErrorAction Stop }
Catch { Write-Host "Unable to load Active Directory module, is RSAT installed?"; Break }

### Set the maximum password age based on group policy if not supplied in parameters.

if ($maxPasswordAge -eq $null) {
	$maxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
}

if ($SetupForTesting -eq "Yes") {
	$CommandToGetInfoFromAD = Get-ADUser -Identity $TestingUsername -properties PasswordLastSet, PasswordExpired, PasswordNeverExpires, EmailAddress, GivenName
	Clear-Variable DaysBeforeExpiry
	$DaysBeforeExpiry = "1000"
}
else {
	
	$CommandToGetInfoFromAD = Get-ADUser -SearchBase <#OU Name#> -Filter * `
		-properties PasswordLastSet, PasswordExpired, PasswordNeverExpires, EmailAddress, GivenName | `
		Where-Object { $_.distinguishedname -notlike '<#Filter Condition#>' -and ($_.passwordlastset + [timespan]::FromDays(90)) -lt (get-date).AddDays(-10) }
           
}



#Run the command to get information from Active Directory

foreach ($ADs in $CommandToGetInfoFromAD) {
	$Today = (Get-Date)
	$UserName = $ADs.Name
	if ((($ADs.passwordlastset + [timespan]::FromDays(90)) -lt (get-date).AddDays(-10) -and $ADs.PasswordExpired) -or !$ads.PasswordExpired -and !$ADs.PasswordNeverExpires) {
		$ExpiryDate = ($ADs.PasswordLastSet + $maxPasswordAge)
		$ExpiryDateForEmail = $("{0:dddd, MM월 dd일 yyyy년 tt hh:mm }" -f ($ExpiryDate))
		$DaysLeft = ($ExpiryDate - $Today).days
		if ($DaysLeft -lt $DaysBeforeExpiry) {
			$MailProperties = @{
				From       = $From
				To         = $Ads.MailAddress
				Subject    = $MailSubject
				SMTPServer = $SMTPServer
			}
			### Message Body for email





			$MsgBody = @"
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<div>
<div style=width 350;height;250>
<H1><span style="text-decoration: underline;font-family: Malgun Gothic;font-size: 25pt;font-weight:bold">$UserName</span>&nbsp님</H1>
<br><br>
현재 사용중인 <span style="color: rgb(255, 0, 0);"><b>비밀번호의</b> </span> 만료 기간은 <b>$ExpiryDateForEmail</b> 입니다.</span>
<br><br>
$(if($DaysLeft -lt 0) {'현재 사용 중인 비밀 번호가 <b>만료</b> 되었습니다.'} else {"비밀 번호가 만료 되기 까지 <b>$DaysLeft</b> 일 남았습니다."})
<br><br>
$(if($DaysLeft -lt 0) {'비밀번호를 <span style="color: rgb(255, 0, 0);"><b>변경</b></style> <span style = "color: rgb(0,0,0)";>하셔야 합니다.</span><br><br> <span style = "color: rgb(0,0,0)";>비밀번호를 변경하지 않게 되면 원활한 서비스를 이용하실 수 없습니다.</span><br><br>'} 
	else {'비밀번호 만료 이전에 비밀번호가 <span style="color: rgb(255, 0, 0);"><b>변경</b></span>되지 않으면 사용중인 서비스는 이용이 중지 됩니다.<br><br>'})
<span style = "color: rgb(0,0,0)";>(ex) 개인PC 로그인, Citrix files, Noroo Drive, 이메일, 프린터 etc)</span>
<br><br><br>
<h2><span style = "color: rgb(0, 0, 0);font-size: 20pt;font-weight:bold;"><b>비밀번호 변경 방법</b></span></h2>
<span style = "color: rgb(0,0,0)";>CTRL + ALT + DEL을 누르고 <b>"암호 변경"</b>을 선택하여 Windows 암호를 변경하십시오.</span>
<br><br>
암호 변경 방법 ☞ Click <b><a href=$link><span style="font-color: red;font-weight: bold;">(noroo.com)</a></b></span>
<br><br>
<h2><span style = "font-size: 20pt;color: rgb(0, 0, 0);"><b>문의 사항</b></span></h2>


<span style="color: rgb(0, 121, 172);font-weight: bold;">DIT 고객지원팀 (헬프데스크) Customer Service Team</span>
<br><br>
<hr align="left" width="790";>
<br>
<div style = "width = 300px, height=200px; margin-left:350px;>
<div stle ="width=200px;height=150px;text-align:right">
E-Mail : <a href="mailto:ithelpdesk@noroo.com">ithelpdesk@noroo.com</a></span>
<br>
협업사이트 : <a href="https://ecm.noroo.com/cop/help" target="_blank">ecm.noroo.com/cop/help</a>
<br>
정책 문의 및 장애 접수 : <b>1833-8373</b>
<br><br>
<span style="font-size:15pt";><b>그룹 시스템 관리자</b></style>
<br>
<b><a href="mailto:email@domain.com">nrgsysadmin@noroo.com</a></b>
</div>
</div>
"@
			
			
			

			### Sends email to user with the message in $MsgBody variable and the supplied @MailProperties.
			Send-MailMessage @MailProperties -Encoding([System.Text.encoding]::UTF8) -body $MsgBody -BodyAsHtml
		}
	}	  
	
}



<#
Version Notes:
1.0 - Intial Release - 기본 프레임워크 생성 및 검색 조건자 지정. ((패스워드 변경일자 + 90일)<(오늘날짜 - 10))
					   HTML 기본 형식 지정. 추후 CSS Style 지정 후 지저분한 Line 별 Span Type 수정 예정.
#>
