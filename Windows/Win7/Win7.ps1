#Created by Zamanry, 06/2018

#Import Windows Firewall
Write-Host "Installing firewall."
Netsh advfirewall import "Win7.wfw"

#Disable & stop services
Write-Host "Disabling & stopping services."
$Services =
'SensrSvc',
'AeLookupSvc',
'ALG',
'AppMgmt',
'aspnet_state',
'BDESVC',
'wbengine',
'bthserv',
'PeerDistSvc',
'CertPropSvc',
'Browser',
'Dhcp',
'DPS',
'WdiServiceHost',
'WdiSystemHost',
'DiagTrack',
'defragsvc',
'TrkWks',
'MSDTC',
'EFS',
'EapHost',
'Fax',
'FDResPub',
'fdPHost',
'hkmsvc',
'HomeGroupListener',
'HomeGroupProvider',
'hidserv',
'SharedAccess',
'IEEtwCollectorService',
'iphlpsvc',
'PolicyAgent',
'lltdsvc',
'Mcx2Svc',
'clr_optimization_v2.0.50727_32',
'clr_optimization_v4.0.30319_32',
'MSiSCSI',
'swprv',
'MMCSS',
'NetMsmqActivator',
'NetPipeActivator',
'NetTcpActivator',
'NetTcpPortSharing',
'Netlogon',
'napagent',
'CscService',
'WPCSvc',
'PNRPsvc',
'p2psvc',
'p2pimsvc',
'pla',
'IPBusEnum',
'PNRPAutoReg',
'WPDBusEnum',
'Spooler',
'wercplsupport',
'PcaSvc',
'QWAVE',
'RasAuto',
'RasMan',
'SessionEnv',
'TermService',
'UmRdpService',
'RpcLocator',
'RemoteRegistry',
'RemoteAccess',
'seclogon',
'SstpSvc',
'LanmanServer',
'ShellHWDetection',
'SCardSvr',
'SCPolicySvc',
'SNMPTRAP',
'sppsvc',
'sppuinotify',
'SSDPSRV',
'StorSvc',
'TabletInputService',
'lmhosts',
'tapiSrv',
'upnphost',
'VSS',
'WebClient',
'WatAdminSvc',
'AudioSrv',
'AudioEndpointBuilder',
'SDRSVC',
'WbioSrvc',
'idsvc',
'WcsPlugInService',
'wcncsvc',
'WinDefend',
'WerSvc',
'Wecsvc',
'FontCache',
'stisvc',
'ehRecvr',
'ehSched',
'WMPNetworkSvc',
'FontCache3.0.0.0',
'WinRM',
'WinHttpAutoProxySvc',
'Wlansvc',
'wmiApSrv',
'LanmanWorkstation',
'WwanSvc',
'PerfHost'

$Index = 0
$CrntService = $Services[$Index]
do {
	if (Get-Service $CrntService -ErrorAction SilentlyContinue) {
		Set-Service $CrntService -StartupType "Disabled"
		Stop-Service $CrntService -Force
	}
	else {
		Write-Host "$CrntService not found."
	}
	$Index++
	$CrntService = $Services[$Index]
} while ($CrntService -ne $NULL)

#Sets Windows Update service and dependencies to automatic
Write-Host "Enabling Windows Update."
Set-Service "wuauserv" -StartupType "Automatic"
Set-Service "BITS" -StartupType "Automatic"
Set-Service "TrustedInstaller" -StartupType "Automatic"

#Disable unneccessary network connections:
Write-Warning "Uncheck all items except IPv4."
Ncpa.cpl
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services" -Name "DisabledComponents" -Type "REG_DWORD" -Value "0xFF" #Disable IPv6 completely
$NIC = Get-WmiObject Win32_NetworkAdapterConfiguration -filter "ipenabled = 'true'" #Disable 'Register this connection's addresses in DNS'
$NIC.SetDynamicDNSRegistration($false)
$NIC.SetTcpipNetbios(2) #Disable NetBIOS over TCP/IP
$NIC = [wmiclass]'Win32_NetworkAdapterConfiguration' #Disable LMHosts lookup
$NIC.enablewins($false,$false)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "IGMPLevel" -Type "REG_DWORD" -Value "0" #Disable IGMP
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" –Value 1 #Disable Remote Desktop
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type "REG_DWORD" –Value 0 #Disable Remote Assistance
$NIC = $NULL

#Flush caches (DNS, ARP, NetBIOS, routes, hosts):
Ipconfig /flushdns
Netsh interface ipv4 delete arpcache
Netsh interface ipv4 delete desinationcache
Netsh interface ipv4 delete neighbors
Netsh interface ipv4 delete winsservers
Write-Host "Resetting Hosts file."
$Path = Get-Location
Set-Location "..\..\..\.."
$DriveLetter = Get-Location
Move-Item -path "$Path\hosts" -destination "$DriveLetter\Windows\system32\drivers\etc\hosts" -force
Set-Location $Path
$DriveLetter = $NULL

Get-WmiObject -Class Win32_OSRecoveryConfiguration -EnableAllPrivileges | >> Set-WmiInstance -Arguments @{DebugInfoType = 0} #Disable memory dumps

#Enable/Disable File Explorer Folder Options:
Set-ItemProperty -Path "HKEY_CURRENT_USER\Software\Microsoft\CurrentVersion\Advanced" -Type "REG_DWORD" -Name "Hidden" -Value 1 #Enable hidden files
Set-ItemProperty -Path "HKEY_CURRENT_USER\Software\Microsoft\CurrentVersion\Advanced" -Type "REG_DWORD" -Name "HideFileExt" -Value 0 #Enable file extensions
Set-ItemProperty -Path "HKEY_CURRENT_USER\Software\Microsoft\CurrentVersion\Advanced" -Type "REG_DWORD" -Name "SharingWizardOn" -Value 0 #Disable Sharing Wizard

#Enable/Disable Internet Options:
Write-Host "Enabling/Disabling Internet Options."
#General tab
$Path1 = "HKEY_CURRENT_USER\Software\Microsoft\CurrentVersion\Internet Settings"
$Path2 = "HKEY_CURRENT_USER\Software\Microsoft\Internet Explorer"
Set-ItemProperty -Path "$Path2\Main" -Type "REG_SZ" -Name "Start Page" -Value "https://start.duckduckgo.com/"
Set-ItemProperty -Path "$Path2\Privacy" -Type "REG_DWORD" -Name "ClearBrowsingHistoryOnExit" -Value 1
Set-ItemProperty -Path "$Path1" -Type "REG_DWORD" -Name "SyncMode5" -Value 3
Set-ItemProperty -Path "$Path1\Url History" -Type "REG_DWORD" -Name "DaysToKeep" -Value 0
Set-ItemProperty -Path "$Path2\BrowserStorage\IndexedDB" -Type "REG_DWORD" -Name "AllowWebsiteDatabases" -Value 0
Set-ItemProperty -Path "$Path2\BrowserStorage\AppCache" -Type "REG_DWORD" -Name "AllowWebsiteCaches" -Value 0
Set-ItemProperty -Path "$Path2\TabbedBrowsing" -Type "REG_DWORD" -Name "WarnOnClose" -Value 0
Set-ItemProperty -Path "$Path2\TabbedBrowsing" -Type "REG_DWORD" -Name "NetTabPageShow" -Value 1
#Privacy Tab
Set-ItemProperty -Path "$Path2\New Windows" -Type "REG_DWORD" -Name "PopupMgr" -Value 1
#Programs Tab
Set-ItemProperty -Path "$Path1\Activities\Email\live.com" -Type "REG_DWORD" -Name "Enabled" -Value 0
Set-ItemProperty -Path "$Path1\Activities\Map\bing.com" -Type "REG_DWORD" -Name "Enabled" -Value 0
Set-ItemProperty -Path "$Path1\Activities\Translate\microsofttranslator.com" -Type "REG_DWORD" -Name "Enabled" -Value 0
#Advanced tab
Set-ItemProperty -Path "$Path2\Main" -Type "REG_SZ" -Name "DisableScriptDebuggerIE" -Value "yes"
Set-ItemProperty -Path "$Path2\Main" -Type "REG_SZ" -Name "Disable Script Debugger" -Value "yes"
Set-ItemProperty -Path "$Path2\Recovery" -Type "REG_DWORD" -Name "AutoRecover" -Value 2
Set-ItemProperty -Path "HKEY_CURRENT_USER\Software\Microsoft\FTP" -Type "REG_SZ" -Name "Use Web Based FTP" -Value "yes"
Set-ItemProperty -Path "$Path2\Main" -Type "REG_DWORD" -Name "Enable Browser Extensions" -Value 0
Set-ItemProperty -Path "HKEY_CURRENT_USER\Software\Microsoft\FTP" -Type "REG_SZ" -Name "Use PASV" -Value "no"
Set-ItemProperty -Path "$Path1" -Type "REG_DWORD" -Name "EnableHttp1_1" -Value 1
Set-ItemProperty -Path "$Path2\Main\FeatureControl\FEATURE_LOCALMACHINE_LOCKDOWN" -Type "REG_DWORD" -Name "iexplore.exe" -Value 1
Set-ItemProperty -Path "$Path2\Download" -Type "REG_DWORD" -Name "RunInvalid" -Value 0
Set-ItemProperty -Path "$Path1" -Type "REG_DWORD" -Name "CertificateRevocation" -Value 1
Set-ItemProperty -Path "$Path2\Download" -Type "REG_SZ" -Name "CheckExeSignatures" -Value "yes"
Set-ItemProperty -Path "$Path1\CACHE" -Type "REG_DWORD" -Name "Persistent" -Value 0
Set-ItemProperty -Path "$Path2\Main" -Type "REG_DWORD" -Name "DOMStorage" -Value 0
Set-ItemProperty -Path "$Path2\PhishingFilter" -Type "REG_DWORD" -Name "Enable" -Value 1
Set-ItemProperty -Path "$Path1" -Type "REG_DWORD" -Name "EnforceP3PValidity" -Value 1
Set-ItemProperty -Path "$Path2\Main" -Type "REG_DWORD" -Name "DoNotTrack" -Value 1
Set-ItemProperty -Path "$Path1" -Type "REG_DWORD" -Name "WarnonBadCertRecving" -Value 1
Set-ItemProperty -Path "$Path1" -Type "REG_DWORD" -Name "WarnonZoneCrossing" -Value 1
Set-ItemProperty -Path "$Path1" -Type "REG_DWORD" -Name "WarnOnPostRedirect" -Value 1
$Path1, $Path2 = $NULL

#Disable outdated protocols:
Write-Host "Disabling PCT/SSL/TLS outdated protocols."
$Path = "HKLM:\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"
function DisableProtocol {
	New-Item -Path "$Path" -name "$Protocol" -Type Directory
	$Path = "$Path\$Protocol"
	New-Item -Path "$Path" -name "Client" -Type "Directory"
	New-Item -Path "$Path" -name "Server" -Type "Directory"
	Set-ItemProperty -Path "$Path\Client" -Type "REG_DWORD" -Name "DisabledByDefault" -Value 1
	Set-ItemProperty -Path "$Path\Client" -Type "REG_DWORD" -Name "Enabled" -Value 0
	Set-ItemProperty -Path "$Path\Server" -Type "REG_DWORD" -Name "DisabledByDefault" -Value 1
	Set-ItemProperty -Path "$Path\Server" -Type "REG_DWORD" -Name "Enabled" -Value 0
}

$Protocols = 'PCT 1.0', 'SSL 2.0', 'SSL 3.0', 'TLS 1.0', 'TLS 1.1'
$Index = 0
$Protocol = $Protocols[$Index]
do {
	DisableProtocol
	$Index++
	$Protocol = $Protocols[$Index]
} while ($Protocol -ne $NULL)

#Enable TLS 1.2
$Protocol = "TLS 1.2"
New-Item -Path "$Path" -name "$Protocol" -Type "Directory"
New-Item -Path "$Path" -name "Client" -Type "Directory"
New-Item -Path "$Path" -name "Server" -Type "Directory"
Set-ItemProperty -Path "$Path\Client" -Type "REG_DWORD" -Name "DisabledByDefault" -Value 0
Set-ItemProperty -Path "$Path\Client" -Type "REG_DWORD" -Name "Enabled" -Value 1
Set-ItemProperty -Path "$Path\Server" -Type "REG_DWORD" -Name "DisabledByDefault" -Value 0
Set-ItemProperty -Path "$Path\Server" -Type "REG_DWORD" -Name "Enabled" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp" -Type "REG_DWORD" -Name "DefaultSecureProtocols" -Value "0x800"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp" -Type "REG_DWORD" -Name "DefaultSecureProtocols" -Value "0x800"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Type "REG_DWORD" -Name "SecureProtocols" -Value "0x800"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Type "REG_DWORD" -Name "chUseStrongCrypto" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Type "REG_DWORD" -Name "chUseStrongCrypto" -Value 1
$Path = $NULL

#Disable SMBv1, v2, and v3 (Unnecessary without domain)
Write-Host "Disabling all SMB versions."
Set-SmbServerConfiguration -EnableSMB1Protocol $false
sc.exe config lanmanworkstation depend = bowser/mrxsmb20/nsi
sc.exe config mrxsmb10 start = disabled
Set-SmbServerConfiguration -EnableSMB2Protocol $false
sc.exe config lanmanworkstation depend = bowser/mrxsmb10/nsi
sc.exe config mrxsmb20 start = disabled

#Set UAC level to High
Write-Host "Setting UAC level to High."
Import-Module ".\SwitchUACLevel.psm1"
Get-Command -Module "SwitchUACLevel"
Set-UACLevel 3

#Enable acustom local security policy
Write-Host "Setting custom local security policy."
Secedit /configure /db %temp%\temp.sdb /cfg Win7.inf

#Install .MSI Mozilla Firefox, Wireshark, MalwareBytes, CCleaner (WIP)

#Disable .MSI service
Set-Service "msiserver" -StartupType "Disabled"
Stop-Service "msiserver" -Force

#Cleaning up files
Write-Host "Cleaning up files."
Remove-Item -path ".\Win7.INF"
Remove-Item -path ".\Win7.WFW"
Remove-Item -path "..\Win7.zip"
Remove-Item -path ".\SwitchUACLevel.psm1"

#Disable features
Write-Warning "Please uncheck all items except .NET, and Windows Search."
Write-Warning "Yes, everything..."
OptionalFeatures

#Create a standard user
Write-Warning "Creating a standard user. Enter a username that is not Admin, Guest, Root, etc."
$Userverb = Read-Host
Write-Warning "Enter a secure password for the account below. Don't worry, it's encrypted."
$Passverb = Read-Host -AsSecureString
Net User $Userverb $Passverb /Add /Y
$Userverb, $Passverb = $NULL

#Clear PowerShell command history
Clear-History

Write-Warning "Please restart once all optional features have been removed."

#Restricts PowerShell scripts
Set-ExecutionPolicy restricted
