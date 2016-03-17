
REM WP8

md %2\DLL\WP8
md %2\DLL\WP8\Debug
md %2\DLL\WP8\Release

REM WP8 Win32 DLL															   

copy %1\binWP8\Release\opencv_calib3D\opencv_calib3D.dll				%2\DLL\WP8\Release /y
copy %1\binWP8\Release\opencv_contrib\opencv_contrib.dll				%2\DLL\WP8\Release /y
copy %1\binWP8\Release\opencv_core\opencv_core.dll						%2\DLL\WP8\Release /y
copy %1\binWP8\Release\opencv_features2d\opencv_features2d.dll			%2\DLL\WP8\Release /y
copy %1\binWP8\Release\opencv_flann\opencv_flann.dll					%2\DLL\WP8\Release /y
copy %1\binWP8\Release\opencv_imgproc\opencv_imgproc.dll				%2\DLL\WP8\Release /y
copy %1\binWP8\Release\opencv_legacy\opencv_legacy.dll					%2\DLL\WP8\Release /y
copy %1\binWP8\Release\opencv_ml\opencv_ml.dll							%2\DLL\WP8\Release /y
copy %1\binWP8\Release\opencv_objdetect\opencv_objdetect.dll			%2\DLL\WP8\Release /y
copy %1\binWP8\Release\opencv_photo\opencv_photo.dll					%2\DLL\WP8\Release /y
copy %1\binWP8\Release\opencv_shape\opencv_shape.dll					%2\DLL\WP8\Release /y
copy %1\binWP8\Release\opencv_stitching\opencv_stitching.dll			%2\DLL\WP8\Release /y
copy %1\binWP8\Release\opencv_video\opencv_video.dll					%2\DLL\WP8\Release /y
copy %1\binWP8\Release\opencv_videostab\opencv_videostab.dll			%2\DLL\WP8\Release /y

REM WP8 ARM DLL

md %2\DLL\WP8\ARM
md %2\DLL\WP8\ARM\Release

copy %1\binWP8\ARM\Release\opencv_calib3D\opencv_calib3D.dll			%2\DLL\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_contrib\opencv_contrib.dll			%2\DLL\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_core\opencv_core.dll					%2\DLL\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_features2d\opencv_features2d.dll		%2\DLL\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_flann\opencv_flann.dll				%2\DLL\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_imgproc\opencv_imgproc.dll			%2\DLL\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_legacy\opencv_legacy.dll				%2\DLL\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_ml\opencv_ml.dll						%2\DLL\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_objdetect\opencv_objdetect.dll		%2\DLL\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_photo\opencv_photo.dll				%2\DLL\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_shape\opencv_shape.dll				%2\DLL\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_stitching\opencv_stitching.dll		%2\DLL\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_video\opencv_video.dll				%2\DLL\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_videostab\opencv_videostab.dll		%2\DLL\WP8\ARM\Release /y



