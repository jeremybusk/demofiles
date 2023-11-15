$token="<your token>"
$clobber="False"
$install_dir="C:\tmp\sumo"
$hostname=((hostname).tolower())
mkdir -p $install_dir

# [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls12'
Invoke-WebRequest 'https://collectors.us2.sumologic.com/rest/download/win64' -outfile 'C:\Windows\Temp\SumoCollector.exe'
Invoke-WebRequest 'https://raw.githubusercontent.com/jeremybusk/sumologic/master/windows_default_sources.json' -outfile "$install_dir\sources.json"
C:\Windows\Temp\SumoCollector.exe -console -q "-Vclobber=$clobber" "-Vsumo.token_and_url=$token" "-Vcollector.name=${hostname}_events" "-Vsources=$install_dir\"
