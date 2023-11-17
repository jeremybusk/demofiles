$HN="host1.example.com";
$TP=(Get-ChildItem -Path Cert:LocalMachine\MY | where Subject -like "CN=${HN}*").Thumbprint
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=`"${HN}`"; CertificateThumbprint=`"$TP`"}"


# Trash
$TP=$H=(hostname); (Get-ChildItem -Path Cert:LocalMachine\MY | where Subject -Like "CN=${H}*" | Select-Object -Property Thumbprint).Thumbprint
$TP=(Get-ChildItem -Path Cert:LocalMachine\MY | where Subject -Like "CN=host1.example.com*" | Select-Object -Property Thumbprint); winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname="p-na26-ica1.extendhealth.com"; CertificateThumbprint="$TP"}'
$TP=($H=(hostname); Get-ChildItem -Path Cert:LocalMachine\MY | where Subject -Like "CN=${H}*" | Select-Object -Property Thumbprint); winrm create winrm/config/Listener?Address=*+Transport=HTTPS '@{Hostname="${H}"; CertificateThumbprint="$TP"}'
winrm quickconfig -transport:https
netstat -an | findstr LISTEN | findstr 598
winrm delete winrm/config/Listener?Address=*+Transport=HTTP
winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
winrm quickconfig -transport:http -Forc
