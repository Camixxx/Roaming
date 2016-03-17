REM usage: run from github directory 

call CopyOcvIncHHPP NuGetPackageWP8\include ..
call CopyOcvLibWP8 . NuGetPackageWP8\bin
call CopyOcvDllWP8 . NuGetPackageWP8\bin



