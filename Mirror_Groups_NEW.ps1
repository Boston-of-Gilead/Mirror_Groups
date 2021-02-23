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

$badgroup = Get-ADGroup -Identity badgroupname
$Recipients = "email1","email2","email3"
$Sender = Read-Host -Prompt "Please enter YOUR EMAIL address"
$SenderUser = $Sender.substring(0,$Sender.Length-10)

$CopyFromUser = Get-ADUser $Source -prop MemberOf
$CopyToUser = Get-ADUser $Dest -prop MemberOf
$MailUser = Get-ADUser $Dest -Properties DisplayName | Select -ExpandProperty DisplayName
$Signature = Get-ADUser -Identity $SenderUser -Properties DisplayName | Select -ExpandProperty DisplayName

foreach($group in $CopyFromUser.memberof){ 
    if (($group -ne $badgroup) -and ($group -notlike '*<exclude string>*')){
    Add-ADGroupMember -Identity $group -Members $CopyToUser
    write-output $group
    }
    elseif($group -eq $badgroup){Send-MailMessage -From $Sender -To $Recipients -Subject "MaximoUsers membership requested for $($MailUser)" -Body "Good day,
BadGroup membership has been requested for $($MailUser). Do you approve?

Kind Regards,
$($Signature)" -SmtpServer <fqdn>}
    }
    #else{}

#$CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} | Where{$CopyFromUser.MemberOf -ne "badgroupname"} | Add-ADGroupMember -Members $CopyToUser | if ($CopyFromUser.MemberOf -eq "badgroupname"){
#Send-MailMessage -From $Sender -To $Recipient -Subject "BadGroup membership requested for $($touser)" -Body "Good day,
#BadGroup membership has been requested for $($touser) as well. Do you approve?" -SmtpServer <fqdn>}