. ".\Cleaner.ps1"
$ComputerList = ("starnt14")
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