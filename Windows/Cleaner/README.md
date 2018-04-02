# Cleaner

Simple script for deep Windows system cleaning. Can clean 

  - All user profile directories (temp files, browsers cache etc)
  - Windows Update downloaded files and shrink updates database
  - DISM 
  - IIS logs
  - Symantec paths (need to test)

### Usage
 - Copy or clone script to some dir
 - Run PowerShell as user with administrative privilegies
 - Run commands like below

```powershell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
.\Cleaner.ps1
```
Script ready to use

#### Example
How to clean several computers? Just add computer names to array.
```powershell

$ComputerList = ("starnt4","starnt5","starnt6","starnt9","starra2", "starra3","nypc804")
```
And run lines below. This will clean all necessary directories and files. 
```powershell
Clear-Host
Foreach ($item in $ComputerList){

$ComputerOBJ = New-object PSObject -Property @{
            ComputerName = $item
            Remote = $True
        }

Write-Host "Cleaning host " $ComputerOBJ.ComputerName -ForegroundColor Green 

If($ComputerOBJ.Remote -eq $true){
    $ComputerOBJ = Test-PSRemoting -ComputerOBJ $ComputerOBJ
    If($ComputerOBJ.PSRemoting -eq $False){
        Read-Host
        exit;
    }
}

$ComputerOBJ = Get-OrigFreeSpace -ComputerOBJ $ComputerOBJ

If($ComputerOBJ.OrigFreeSpace -eq $False){
    Read-host
    exit;
}

Clean-path -Path 'C:\windows\Temp' -ComputerOBJ $ComputerOBJ
Clean-path -Path 'C:\Temp' -ComputerOBJ $ComputerOBJ
Clean-path -Path 'C:\ProgramData\Microsoft\Windows\WER\ReportArchive' -ComputerOBJ $ComputerOBJ
Clean-path -Path 'C:\ProgramData\Microsoft\Windows\WER\ReportQueue' -ComputerOBJ $ComputerOBJ
Clean-path -Path 'C:\ServiceProfiles\LocalService\AppData\Local\Temp' -ComputerOBJ $ComputerOBJ

Write-Host "All Temp Paths have been cleaned" -ForegroundColor Green

Write-Host "Beginning User Profile Cleanup" -ForegroundColor Yellow
Get-AllUserProfiles -ComputerOBJ $ComputerOBJ
Write-Host "All user profiles have been processed" -ForegroundColor Green

#TestFor-SymantecPath -ComputerOBJ $ComputerOBJ
Run-CleanMGR -ComputerOBJ $ComputerOBJ
Run-DISM -ComputerOBJ $ComputerOBJ
Process-IISLogs -ComputerOBJ $ComputerOBJ
Set-WindowsUpdateService -ComputerOBJ $ComputerOBJ
Get-Recyclebin -ComputerOBJ $ComputerOBJ

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
```

##### To be continued...


