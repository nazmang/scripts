<#
.Synopsis
   Cleans something on the given remote computer(s) name(s)
.DESCRIPTION
   Cleaner.ps1 cmdlet ...
.EXAMPLE
   ./Cleaner.ps1 -ComputerName "abc.contoso.com"
  
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
param (
    [String[]] $ComputerList = "$env:COMPUTERNAME",
    [switch] $CleanRecyclebin = $true,
    [switch] $RunCleanMGR = $false,
    [switch] $RunDISM = $false,
    [switch] $CleanSymantec = $false,
    [switch] $CleanIIS = $false, 
    [switch] $CleanDownloads = $false,
    [String] $Report = "$env:TEMP\cleaner.log"
)

If(![string]::IsNullOrEmpty($Report)){
    $ErrorActionPreference="SilentlyContinue"
    Stop-Transcript | out-null
    $ErrorActionPreference = "Continue"
    Start-Transcript -path $Report -append
}


$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
     Import-Module activedirectory
     Import-Module "\\imagine-nt.com\SYSVOL\imagine-nt.com\scripts\cleaner\Cleaner.psm1" 
    }
catch {
    Write-Host "Error while loading supporting PowerShell modules" 
}


Foreach ($item in $ComputerList){

$ComputerOBJ = New-object PSObject -Property @{
            ComputerName = $item
            Remote = $True
        }

If($ComputerOBJ.Remote -eq $true){
    $ComputerOBJ = Test-PSRemoting -ComputerOBJ $ComputerOBJ
    If($ComputerOBJ.PSRemoting -eq $False){
        Read-Host
        exit;
    }
}

$ComputerOBJ = Get-OrigFreeSpace -ComputerOBJ $ComputerOBJ


Write-Host "Cleaning host " $ComputerOBJ.ComputerName -ForegroundColor Green

If($ComputerOBJ.OrigFreeSpace -eq $False){
  #  Read-host
  #  exit;
  continue;
}

Clear-Path -Path 'C:\windows\Temp' -ComputerOBJ $ComputerOBJ
Clear-Path -Path 'C:\windows\cmmcache' -ComputerOBJ $ComputerOBJ
Clear-Path -Path 'C:\ProgramData\Dell\KACE' -ComputerOBJ $ComputerOBJ
Clear-Path -Path 'C:\Windows\Logs\CBS' -ComputerOBJ $ComputerOBJ
Clear-Path -Path 'C:\ProgramData\Microsoft\Windows\WER\ReportArchive' -ComputerOBJ $ComputerOBJ
Clear-Path -Path 'C:\ProgramData\Microsoft\Windows\WER\ReportQueue' -ComputerOBJ $ComputerOBJ
Clear-Path -Path 'C:\ServiceProfiles\LocalService\AppData\Local\Temp' -ComputerOBJ $ComputerOBJ

Write-Host "All Temp Paths have been cleaned" -ForegroundColor Green

Write-Host "Beginning User Profile Cleanup" -ForegroundColor Yellow
Get-AllUserProfiles -ComputerOBJ $ComputerOBJ
Write-Host "All user profiles have been processed" -ForegroundColor Green

If($CleanSymantec -eq $true) {Test-SymantecPath -ComputerOBJ $ComputerOBJ}
If($RunCleanMGR -eq $true) {Start-CleanMGR -ComputerOBJ $ComputerOBJ}
If($RunDISM -eq $true) {Start-DISM -ComputerOBJ $ComputerOBJ}
If($CleanIIS -eq $true) {Find-IISLogs -ComputerOBJ $ComputerOBJ}
Set-WindowsUpdateService -ComputerOBJ $ComputerOBJ
If($CleanRecyclebin -eq $true) {Get-Recyclebin -ComputerOBJ $ComputerOBJ}

$ComputerOBJ = Get-FinalFreeSpace -ComputerOBJ $ComputerOBJ
$SpaceRecovered = $($Computerobj.finalfreespace) - $($ComputerOBJ.OrigFreeSpace)

If($SpaceRecovered -lt 0){
    Write-Host "Less than a gig of Free Space was recovered." -ForegroundColor Yellow
}
ElseIf($SpaceRecovered -eq 0){
    Write-host "No Space Was saved :("
}
Else{
    Write-host "Space Recovered : $SpaceRecovered GB" -ForegroundColor Green
}
}

If(![string]::IsNullOrEmpty($Report)){ 
    Stop-Transcript 
}