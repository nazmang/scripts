# Cleaner

Simple script for deep Windows system cleaning. Can clean:

  - All user profile directories (temp files, browsers cache etc).
  - Windows temporary files and directories.
  - Windows Update downloaded files and shrink updates database using DISM. 
  - IIS logs.
  - Symantec paths (under test).

### Usage
 - Copy or clone script to some directory
 ```shell
git clone https://bitbucket.imagine-sw.com:7990/scm/~eugenena/scripts.git
 ```
 - Run PowerShell as user with administrative privilegies
 - Run commands like in example


#### Example

```powershell
cd projects/scripts/Windows/Cleaner
.\Cleaner.ps1 -computer1,computer2,computerN -CleanRecyclebin -RunCleanMGR -RunDISM -CleanSymantec-CleanIIS -CleanDownloads 
```
**Note:** if you got* "... file is not digitally signed..."* error, please run code below
```powershell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted
```
#### Parameters
 - ***CleanRecyclebin*** - will clean **Recycle Bin**. Default *true*.
 - ***RunCleanMGR*** - will run **Windows Clean Manager**. Default *false*.
 - ***RunDISM*** - run **dism** command to shrink Windows Update database. Default *false*.
 - ***CleanSymantec*** - cleans Symantec AV logs.  Default *false*.
 - ***CleanIIS*** - cleans **IIS** logs. Requires **IIS** role being installed. Default *false*.
 - ***CleanDownloads*** - cleans content of **Downloads** folder for each user profile in the system. Default *false*.
------------

##### 07/03/2018
 - Added commandline support
 - Minor code fixes

##### 05/21/2018
 - Added SCCM cache cleaning
 - Added Mozilla Firefox cache cleaning
 - Fixed Google Chrome chache cleaning (wasn't working)
 
##### TODO
 - Show help if no params



