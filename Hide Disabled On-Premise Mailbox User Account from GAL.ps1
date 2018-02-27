$Mailboxes = Get-User -Resultsize Unlimited | Where-Object {$_.UserAccountControl -like '*AccountDisabled*' -and $_.RecipientType -eq 'UserMailbox' -and $_.DistinguishedName -like '*disabled*' } | Get-Mailbox | Where-Object {$_.HiddenFromAddressListsEnabled -eq $false}

ForEach ($Mailbox in $Mailboxes) { Set-Mailbox -HiddenFromAddressListsEnabled $true -Identity $Mailbox }