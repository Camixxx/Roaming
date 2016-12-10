
REM WP8

md %2\LIB\WP8
md %2\LIB\WP8\Release

REM WP8 Win32 LIB															   

copy %1\binWP8\Release\opencv_calib3D\opencv_calib3D.lib				%2\LIB\WP8\Release /y
copy %1\binWP8\Release\opencv_contrib\opencv_contrib.lib				%2\LIB\WP8\Release /y
copy %1\binWP8\Release\opencv_core\opencv_core.lib						%2\LIB\WP8\Release /y
copy %1\binWP8\Release\opencv_features2d\opencv_features2d.lib			%2\LIB\WP8\Release /y
copy %1\binWP8\Release\opencv_flann\opencv_flann.lib					%2\LIB\WP8\Release /y
copy %1\binWP8\Release\opencv_imgproc\opencv_imgproc.lib				%2\LIB\WP8\Release /y
copy %1\binWP8\Release\opencv_legacy\opencv_legacy.lib					%2\LIB\WP8\Release /y
copy %1\binWP8\Release\opencv_ml\opencv_ml.lib							%2\LIB\WP8\Release /y
copy %1\binWP8\Release\opencv_objdetect\opencv_objdetect.lib			%2\LIB\WP8\Release /y
copy %1\binWP8\Release\opencv_photo\opencv_photo.lib					%2\LIB\WP8\Release /y
copy %1\binWP8\Release\opencv_shape\opencv_shape.lib					%2\LIB\WP8\Release /y
copy %1\binWP8\Release\opencv_stitching\opencv_stitching.lib			%2\LIB\WP8\Release /y
copy %1\binWP8\Release\opencv_video\opencv_video.lib					%2\LIB\WP8\Release /y
copy %1\binWP8\Release\opencv_videostab\opencv_videostab.lib			%2\LIB\WP8\Release /y

REM WP8 ARM LIB

md %2\LIB\WP8\ARM
md %2\LIB\WP8\ARM\Release

copy %1\binWP8\ARM\Release\opencv_calib3D\opencv_calib3D.lib			%2\LIB\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_contrib\opencv_contrib.lib			%2\LIB\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_core\opencv_core.lib					%2\LIB\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_features2d\opencv_features2d.lib		%2\LIB\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_flann\opencv_flann.lib				%2\LIB\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_imgproc\opencv_imgproc.lib			%2\LIB\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_legacy\opencv_legacy.lib				%2\LIB\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_ml\opencv_ml.lib						%2\LIB\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_objdetect\opencv_objdetect.lib		%2\LIB\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_photo\opencv_photo.lib				%2\LIB\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_shape\opencv_shape.lib				%2\LIB\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_stitching\opencv_stitching.lib		%2\LIB\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_video\opencv_video.lib				%2\LIB\WP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_videostab\opencv_videostab.lib		%2\LIB\WP8\ARM\Release /y



