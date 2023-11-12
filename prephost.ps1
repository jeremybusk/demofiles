# Usage
# invoke-webrequest -uri https://raw.githubusercontent.com/jeremybusk/demofiles/main/prephost.ps1 -outfile prephost.ps1
# ./prephost.ps1

$ErrorActionPreference = "Stop"
$authorizedKey="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICCJYiHQpVLyxZwqNk6BEW+q2ZPEPP2hzHQ91KgrhF9j demolt"

(New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
start-service sshd
stop-service sshd
New-Item -Force -ItemType Directory -Path $env:USERPROFILE\.ssh; Add-Content -Force -Path C:\ProgramData\ssh\administrators_authorized_keys -Value "$authorizedKey"
get-acl C:\ProgramData\ssh\ssh_host_dsa_key | set-acl C:\ProgramData\ssh\administrators_authorized_keys

New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
Set-Service -Name sshd -StartupType Automatic
start-service sshd

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install -y vim

# remove by doing:
# rm -fo -r C:\ProgramData\chocolatey
