$ErrorActionPreference = "Stop"
$domain = "example.com"
# $password = "ChangeMe" | ConvertTo-SecureString -asPlainText -Force
$password = Get-Content pass.txt | ConvertTo-SecureString -asPlainText -Force
rm pass.txt
$username = "$domain\_admin" 
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
Add-Computer -DomainName $domain -Credential $credential -restart
# ssh user1@example.com@host1.example.com
