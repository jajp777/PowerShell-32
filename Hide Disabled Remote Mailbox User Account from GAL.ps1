# If you have an Office 365 hybrid and a user is disabled on-premise and their Exchange Online license is removed, then they will become a UserMailbox recipient on-premise.
# This means if you attempt to use recipient type UserMailbox or RemoteMailbox it won't work as there is no mailbox on-premise or remote.
# Use recipient type MailUser to get all disabled on-premise user objects that had a remote mailbox but now disabled.

$Users = Get-User -ResultSize Unlimited | Where-Object {$_.UserAccountControl -like '*AccountDisabled*' -and $_.RecipientType -eq 'MailUser' -and $_.DistinguishedName -like '*disabled*' } 

ForEach ($User in $Users) { 
    Set-ADObject -Identity $User.DistinguishedName -Replace @{msExchHideFromAddressLists = $true} 
    Set-ADObject -Identity $User.DistinguishedName -Clear ShowinAddressBook
}