$ErrorActionPreference = "Stop"
# Usage
# invoke-webrequest -uri https://raw.githubusercontent.com/jeremybusk/demofiles/main/newHost.ps1 -outfile prepNewHost.ps1
# ./prepNewHost.ps1

hostname
$upHours=((get-date) - (gcim Win32_OperatingSystem).LastBootUpTime).TotalHours
Write-Output "Host Up Hours = ${upHours}"


$AD_DOMAIN = Read-Host "Enter AD Domain"
$AD_USER = Read-Host "Enter AD User"
$AD_PASS = Read-Host "Enter AD Password" -AsSecureString
$SUMO_CLOBBER = Read-Host "Enter Sumo Clobber True/False"
$SUMO_TOKEN = Read-Host "Enter Sumo Logic registration token" -MaskInput
$SSHD_AUTHORIZED_KEY = Read-Host "Enter SSHD Admin Authorized key" -MaskInput


function add_sumo {
  $hostname=((hostname).tolower())
  # [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls,Tls11,Tls12'
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls12'
  if ( !(Test-Path $env:TEMP\SumoCollector.exe) ) {
    Invoke-WebRequest 'https://collectors.us2.sumologic.com/rest/download/win64' -outfile "$env:TEMP\SumoCollector.exe"
  }
  
  Invoke-WebRequest 'https://raw.githubusercontent.com/jeremybusk/sumologic/master/windows_default_sources.json' -outfile "$env:TEMP\sources.json"
  & $env:TEMP\SumoCollector.exe -console -q "-Vclobber=${SUMO_CLOBBER}" "-Vsumo.token_and_url=${SUMO_TOKEN}" "-Vcollector.name=${hostname}_events" "-Vsources=$env:TEMP\"
}


function add_sshd {
  (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

  # Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
  Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
  start-service sshd
  stop-service sshd
  New-Item -Force -ItemType Directory -Path $env:USERPROFILE\.ssh; Add-Content -Force -Path C:\ProgramData\ssh\administrators_authorized_keys -Value "${SSHD_AUTHORIZED_KEY}"
  get-acl C:\ProgramData\ssh\ssh_host_dsa_key | set-acl C:\ProgramData\ssh\administrators_authorized_keys

  New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
  Set-Service -Name sshd -StartupType Automatic
  start-service sshd

  New-NetFirewallRule -DisplayName "ALLOW WinRM HTTPS/TCP/5986" -Direction inbound -Profile Any -Action Allow -LocalPort 5986 -Protocol TCP
  New-NetFirewallRule -DisplayName "ALLOW SSH/TCP/22" -Direction inbound -Profile Any -Action Allow -LocalPort 22 -Protocol TCP
}

function add_choco {
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

  choco install -y vim
}


function join_ad {
  # $domain = "example.com"
  # $password = "ChangeMe" | ConvertTo-SecureString -asPlainText -Force
  # $password = Get-Content pass.txt | ConvertTo-SecureString -asPlainText -Force
  # rm pass.txt
  $ad_username = "${AD_DOMAIN}\${AD_USER}" 
  $credential = New-Object System.Management.Automation.PSCredential(${ad_username},${AD_PASS})
  Add-Computer -DomainName ${AD_DOMAIN} -Credential $credential -restart
}

add_sumo
add_sshd
add_choco
Write-Output "Success: Installations completed."
join_ad






# Notes #####
  # $install_dir="C:\tmp\sumo"
  # mkdir -p ${install_dir}
  # New-Item -ItemType Directory -Force -Path ${install_dir}
## ssh user1@example.com@host1.example.com
## remove by doing:
## rm -fo -r C:\ProgramData\chocolatey
