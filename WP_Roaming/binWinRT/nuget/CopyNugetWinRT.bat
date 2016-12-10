REM usage: run from github directory 

call CopyOcvIncHHPP NuGetPackageWinRT\include ..
call CopyOcvLibWinRT . NuGetPackageWinRT\bin
call CopyOcvDllWinRT . NuGetPackageWinRT\bin


