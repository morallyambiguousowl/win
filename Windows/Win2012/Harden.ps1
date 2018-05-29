﻿#Created by Zamanry, 05/2018

#Import firewall
Netsh advfirewall import "5.22.18.wfw"

#Flush DNS
Ipconfig /flushdns

#Disable & stop services
$Services = 
'Browser',
'TrkWks',
'fdPHost',
'FDResPub',
'SharedAccess',
'iphlpsvc',
'lltdsvc',
'NetTcpPortSharing',
'napagent',
'PerfHost',
'pla',
'RasAuto',
'RasMan',
'SessionEnv',
'TermService',
'umRdpService',
'RemoteRegistry',
'RemoteAccess',
'seclogon',
'SstpSvc',
'LanmanServer',
'SNMPTRAP',
'SSDPSRV',
'lmhosts',
'TapiSrv',
'upnphost',
'Wecsvc',
'FontCache',
'WinRM',
'WinHttpAutoProxySvc',
'wmiApSrv',
'LanmanWorkstation',
'defragsvc',
'MSiSCSI',
'AeLookupSvc',
'ShellHWDetection',
'SCardSvr',
'SCPolicySvc',
'CertPropSvc',
'wercplsupport',
'Spooler',
'WcsPlugInService',
'WPDBusEnum',
'DeviceAssociationService',
'DeviceInstall',
'DsmSvc',
'NcaSvc',
'PrintNotify',
'sacsvr',
'Audiosrv',
'AudioEndpointBuilder',
#'Dhcp', #Unless DHCP is required
'gpsvc',
'DPS',
'WLMS'

$Index = 0
$CrntService = $Services[$Index]

do
{
    if (Get-Service $CrntService -ErrorAction SilentlyContinue)
    {        
        Set-Service $CrntService -StartupType Disabled
        Stop-Service $CrntService -Force
    }
    else
    {
        Write-Host "$CrntService not found"
    }

    $Index++
    $CrntService = $Services[$Index]

}
while ($CrntService -ne $NULL)

#Disable unnecessary network components
Disable-NetAdapterBinding -Name "*" -ComponentID 'ms_tcpip6'
Disable-NetAdapterBinding -Name "*" -ComponentID 'ms_rspndr'
Disable-NetAdapterBinding -Name "*" -ComponentID 'ms_lltdio'
Disable-NetAdapterBinding -Name "*" -ComponentID 'ms_implat'
Disable-NetAdapterBinding -Name "*" -ComponentID 'ms_msclient'
Disable-NetAdapterBinding -Name "*" -ComponentID 'ms_pacer'
Disable-NetAdapterBinding -Name "*" -ComponentID 'ms_server'

#Disable IPv6 completely
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services" -Name "DisabledComponents" -PropertyType DWORD -Value "0xFF" -Force 

#Disable 'Register this connection's addresses in DNS'
$NIC = Get-WmiObject Win32_NetworkAdapterConfiguration -filter "ipenabled = 'true'"
$NIC.SetDynamicDNSRegistration($false)

#Disable NetBIOS over TCP/IP
$NIC.SetTcpipNetbios(2)

#Disable LMHosts lookup
$NIC = [wmiclass]'Win32_NetworkAdapterConfiguration'
$NIC.enablewins($false,$false)

#Prevent Server Manager from opening at startup
Set-ItemProperty -Path "HKLM:\Software\Microsoft\ServerManager" -Name "DoNotOpenServerManagerAtLogon" -PropertyType DWORD -Value "0x1" –Force

#Disables IGMP
Netsh interface ipv4 set global mldlevel = none

#Disable memory dumps
Wmic recoveros set DebugInfoType = 0

#Disable Remote Assistance
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" –Value 1

#Show File Explorer hidden files
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1

#Show File Explorer file extensions
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFilExt" -Value 0

#Disable File Explorer Sharing Wizard
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "SharingWizardOn" -Value 0

#Disables Jump List items in Taskbar Properties
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_JumpListItems" -Value 0

#Disables tracking of recent documents in Taskbar Properties
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Value 0

#Removes Windows Features
Remove-WindowsFeature -Name PowerShell-ISE

#Enables custom local security policies
secedit /configure /db %temp%\temp.sdb /cfg 5.21.18.inf

#Set UAC level to high
Import-Module . \SwitchUACLevel.psm1
Get-Command -Module SwitchUACLevel
Set-UACLevel 3

#Restricts PowerShell scripts
#Set-ExecutionPolicy restricted