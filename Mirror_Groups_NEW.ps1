Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

Write-Host "Loading..."
#Install-Module MSOnline
#Write-host "1"
#Install-Module AzureADPreview -Force
#Write-host "2"
Import-Module ActiveDirectory
Import-Module ExchangeOnlineManagement
Write-Host "Modules loaded"

$Source = Read-Host -Prompt "Please enter the USERNAME of the user to be copied"
$Dest = Read-Host -Prompt "Please enter the USERNAME of the user to receive group memberships"

$badgroup = Get-ADGroup -Identity excludegroup
$Recipients = "email1","email2"
$Sender = Read-Host -Prompt "Please enter YOUR EMAIL address"
$SenderUser = $Sender.substring(0,$Sender.Length-10)

$CopyFromUser = Get-ADUser $Source -prop MemberOf
$CopyToUser = Get-ADUser $Dest -prop MemberOf
$MailUser = Get-ADUser $Dest -Properties DisplayName | Select -ExpandProperty DisplayName
$Signature = Get-ADUser -Identity $SenderUser -Properties DisplayName | Select -ExpandProperty DisplayName

foreach($group in $CopyFromUser.memberof){ 
    if (($group -ne $badgroup) -and ($group -notlike '*string*')){
    Add-ADGroupMember -Identity $group -Members $CopyToUser
    write-output $group
    }
    elseif($group -eq $badgroup){Send-MailMessage -From $Sender -To $Recipients -Subject "ExcludeGroup membership requested for $($MailUser)" -Body "Good day,
ExcludeGroup membership has been requested for $($MailUser). Do you approve?

Kind Regards,
$($Signature)" -SmtpServer smtp.xxx.net} 
    }
