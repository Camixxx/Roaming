
REM WinRT

md %2\LIB\WinRT
md %2\LIB\WinRT\Release

REM WinRT Win32 LIB															   

copy %1\binWinRT\Release\opencv_calib3D\opencv_calib3D.lib			%2\LIB\WinRT\Release /y
copy %1\binWinRT\Release\opencv_contrib\opencv_contrib.lib			%2\LIB\WinRT\Release /y
copy %1\binWinRT\Release\opencv_core\opencv_core.lib				%2\LIB\WinRT\Release /y
copy %1\binWinRT\Release\opencv_features2d\opencv_features2d.lib		%2\LIB\WinRT\Release /y
copy %1\binWinRT\Release\opencv_flann\opencv_flann.lib				%2\LIB\WinRT\Release /y
copy %1\binWinRT\Release\opencv_imgproc\opencv_imgproc.lib			%2\LIB\WinRT\Release /y
copy %1\binWinRT\Release\opencv_legacy\opencv_legacy.lib			%2\LIB\WinRT\Release /y
copy %1\binWinRT\Release\opencv_ml\opencv_ml.lib				%2\LIB\WinRT\Release /y
copy %1\binWinRT\Release\opencv_objdetect\opencv_objdetect.lib			%2\LIB\WinRT\Release /y
copy %1\binWinRT\Release\opencv_photo\opencv_photo.lib				%2\LIB\WinRT\Release /y
copy %1\binWinRT\Release\opencv_shape\opencv_shape.lib				%2\LIB\WinRT\Release /y
copy %1\binWinRT\Release\opencv_stitching\opencv_stitching.lib			%2\LIB\WinRT\Release /y
copy %1\binWinRT\Release\opencv_video\opencv_video.lib				%2\LIB\WinRT\Release /y
copy %1\binWinRT\Release\opencv_videostab\opencv_videostab.lib			%2\LIB\WinRT\Release /y

REM WinRT ARM LIB

md %2\LIB\WinRT\ARM
md %2\LIB\WinRT\ARM\Release

copy %1\binWinRT\ARM\Release\opencv_calib3D\opencv_calib3D.lib			%2\LIB\WinRT\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_contrib\opencv_contrib.lib			%2\LIB\WinRT\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_core\opencv_core.lib			%2\LIB\WinRT\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_features2d\opencv_features2d.lib		%2\LIB\WinRT\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_flann\opencv_flann.lib			%2\LIB\WinRT\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_imgproc\opencv_imgproc.lib			%2\LIB\WinRT\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_legacy\opencv_legacy.lib			%2\LIB\WinRT\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_ml\opencv_ml.lib				%2\LIB\WinRT\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_objdetect\opencv_objdetect.lib		%2\LIB\WinRT\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_photo\opencv_photo.lib			%2\LIB\WinRT\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_shape\opencv_shape.lib			%2\LIB\WinRT\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_stitching\opencv_stitching.lib		%2\LIB\WinRT\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_video\opencv_video.lib			%2\LIB\WinRT\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_videostab\opencv_videostab.lib		%2\LIB\WinRT\ARM\Release /y

REM WinRT x64 LIB

md %2\LIB\WinRT\x64
md %2\LIB\WinRT\x64\Release

copy %1\binWinRT\x64\Release\opencv_calib3D\opencv_calib3D.lib		%2\LIB\WinRT\x64\Release /y
copy %1\binWinRT\x64\Release\opencv_contrib\opencv_contrib.lib		%2\LIB\WinRT\x64\Release /y
copy %1\binWinRT\x64\Release\opencv_core\opencv_core.lib		%2\LIB\WinRT\x64\Release /y
copy %1\binWinRT\x64\Release\opencv_features2d\opencv_features2d.lib	%2\LIB\WinRT\x64\Release /y
copy %1\binWinRT\x64\Release\opencv_flann\opencv_flann.lib		%2\LIB\WinRT\x64\Release /y
copy %1\binWinRT\x64\Release\opencv_imgproc\opencv_imgproc.lib		%2\LIB\WinRT\x64\Release /y
copy %1\binWinRT\x64\Release\opencv_legacy\opencv_legacy.lib		%2\LIB\WinRT\x64\Release /y
copy %1\binWinRT\x64\Release\opencv_ml\opencv_ml.lib			%2\LIB\WinRT\x64\Release /y
copy %1\binWinRT\x64\Release\opencv_objdetect\opencv_objdetect.lib	%2\LIB\WinRT\x64\Release /y
copy %1\binWinRT\x64\Release\opencv_photo\opencv_photo.lib		%2\LIB\WinRT\x64\Release /y
copy %1\binWinRT\x64\Release\opencv_shape\opencv_shape.lib		%2\LIB\WinRT\x64\Release /y
copy %1\binWinRT\x64\Release\opencv_stitching\opencv_stitching.lib	%2\LIB\WinRT\x64\Release /y
copy %1\binWinRT\x64\Release\opencv_video\opencv_video.lib		%2\LIB\WinRT\x64\Release /y
copy %1\binWinRT\x64\Release\opencv_videostab\opencv_videostab.lib	%2\LIB\WinRT\x64\Release /y






