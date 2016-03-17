md %2\LIB\winrt
md %2\LIB\winrt\Debug
md %2\LIB\winrt\Release

// WinRT Win32 LIB

copy %1\binWinRT\Debug\zlib\zlib.lib									%2\LIB\winrt\Debug /y
copy %1\binWinRT\Debug\opencv_calib3d\opencv_calib3d.lib				%2\LIB\winrt\Debug /y
copy %1\binWinRT\Debug\opencv_contrib\opencv_contrib.lib				%2\LIB\winrt\Debug /y
copy %1\binWinRT\Debug\opencv_core\opencv_core.lib						%2\LIB\winrt\Debug /y
copy %1\binWinRT\Debug\opencv_features2d\opencv_features2d.lib			%2\LIB\winrt\Debug /y
copy %1\binWinRT\Debug\opencv_flann\opencv_flann.lib					%2\LIB\winrt\Debug /y
copy %1\binWinRT\Debug\opencv_imgproc\opencv_imgproc.lib				%2\LIB\winrt\Debug /y
copy %1\binWinRT\Debug\opencv_legacy\opencv_legacy.lib					%2\LIB\winrt\Debug /y
copy %1\binWinRT\Debug\opencv_ml\opencv_ml.lib							%2\LIB\winrt\Debug /y
copy %1\binWinRT\Debug\opencv_nonfree\opencv_nonfree.lib				%2\LIB\winrt\Debug /y
copy %1\binWinRT\Debug\opencv_objdetect\opencv_objdetect.lib			%2\LIB\winrt\Debug /y
copy %1\binWinRT\Debug\opencv_photo\opencv_photo.lib					%2\LIB\winrt\Debug /y
copy %1\binWinRT\Debug\opencv_shape\opencv_shape.lib					%2\LIB\winrt\Debug /y
copy %1\binWinRT\Debug\opencv_stitching\opencv_stitching.lib			%2\LIB\winrt\Debug /y
copy %1\binWinRT\Debug\opencv_video\opencv_video.lib					%2\LIB\winrt\Debug /y
copy %1\binWinRT\Debug\opencv_videostab\opencv_videostab.lib			%2\LIB\winrt\Debug /y

copy %1\binWinRT\Release\zlib\zlib.lib									%2\LIB\winrt\Release /y
copy %1\binWinRT\Release\opencv_calib3d\opencv_calib3d.lib				%2\LIB\winrt\Release /y
copy %1\binWinRT\Release\opencv_contrib\opencv_contrib.lib				%2\LIB\winrt\Release /y
copy %1\binWinRT\Release\opencv_core\opencv_core.lib					%2\LIB\winrt\Release /y
copy %1\binWinRT\Release\opencv_features2d\opencv_features2d.lib		%2\LIB\winrt\Release /y
copy %1\binWinRT\Release\opencv_flann\opencv_flann.lib					%2\LIB\winrt\Release /y
copy %1\binWinRT\Release\opencv_imgproc\opencv_imgproc.lib				%2\LIB\winrt\Release /y
copy %1\binWinRT\Release\opencv_legacy\opencv_legacy.lib				%2\LIB\winrt\Release /y
copy %1\binWinRT\Release\opencv_ml\opencv_ml.lib						%2\LIB\winrt\Release /y
copy %1\binWinRT\Release\opencv_nonfree\opencv_nonfree.lib				%2\LIB\winrt\Release /y
copy %1\binWinRT\Release\opencv_objdetect\opencv_objdetect.lib			%2\LIB\winrt\Release /y
copy %1\binWinRT\Release\opencv_photo\opencv_photo.lib					%2\LIB\winrt\Release /y
copy %1\binWinRT\Release\opencv_shape\opencv_shape.lib					%2\LIB\winrt\Release /y
copy %1\binWinRT\Release\opencv_stitching\opencv_stitching.lib			%2\LIB\winrt\Release /y
copy %1\binWinRT\Release\opencv_video\opencv_video.lib					%2\LIB\winrt\Release /y
copy %1\binWinRT\Release\opencv_videostab\opencv_videostab.lib			%2\LIB\winrt\Release /y


// WinRT ARM LIB

copy %1\binWinRT\ARM\Debug\zlib\zlib.lib								%2\LIB\winrt\ARM\Debug /y
copy %1\binWinRT\ARM\Debug\opencv_calib3d\opencv_calib3d.lib			%2\LIB\winrt\ARM\Debug /y
copy %1\binWinRT\ARM\Debug\opencv_contrib\opencv_contrib.lib			%2\LIB\winrt\ARM\Debug /y
copy %1\binWinRT\ARM\Debug\opencv_core\opencv_core.lib					%2\LIB\winrt\ARM\Debug /y
copy %1\binWinRT\ARM\Debug\opencv_features2d\opencv_features2d.lib		%2\LIB\winrt\ARM\Debug /y
copy %1\binWinRT\ARM\Debug\opencv_flann\opencv_flann.lib				%2\LIB\winrt\ARM\Debug /y
copy %1\binWinRT\ARM\Debug\opencv_imgproc\opencv_imgproc.lib			%2\LIB\winrt\ARM\Debug /y
copy %1\binWinRT\ARM\Debug\opencv_legacy\opencv_legacy.lib				%2\LIB\winrt\ARM\Debug /y
copy %1\binWinRT\ARM\Debug\opencv_ml\opencv_ml.lib						%2\LIB\winrt\ARM\Debug /y
copy %1\binWinRT\ARM\Debug\opencv_nonfree\opencv_nonfree.lib			%2\LIB\winrt\ARM\Debug /y
copy %1\binWinRT\ARM\Debug\opencv_objdetect\opencv_objdetect.lib		%2\LIB\winrt\ARM\Debug /y
copy %1\binWinRT\ARM\Debug\opencv_photo\opencv_photo.lib				%2\LIB\winrt\ARM\Debug /y
copy %1\binWinRT\ARM\Debug\opencv_shape\opencv_shape.lib				%2\LIB\winrt\ARM\Debug /y
copy %1\binWinRT\ARM\Debug\opencv_stitching\opencv_stitching.lib		%2\LIB\winrt\ARM\Debug /y
copy %1\binWinRT\ARM\Debug\opencv_video\opencv_video.lib				%2\LIB\winrt\ARM\Debug /y
copy %1\binWinRT\ARM\Debug\opencv_videostab\opencv_videostab.lib		%2\LIB\winrt\ARM\Debug /y

copy %1\binWinRT\ARM\Release\zlib\zlib.lib								%2\LIB\winrt\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_calib3d\opencv_calib3d.lib			%2\LIB\winrt\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_contrib\opencv_contrib.lib			%2\LIB\winrt\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_core\opencv_core.lib				%2\LIB\winrt\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_features2d\opencv_features2d.lib	%2\LIB\winrt\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_flann\opencv_flann.lib				%2\LIB\winrt\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_imgproc\opencv_imgproc.lib			%2\LIB\winrt\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_legacy\opencv_legacy.lib			%2\LIB\winrt\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_ml\opencv_ml.lib					%2\LIB\winrt\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_nonfree\opencv_nonfree.lib			%2\LIB\winrt\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_objdetect\opencv_objdetect.lib		%2\LIB\winrt\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_photo\opencv_photo.lib				%2\LIB\winrt\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_shape\opencv_shape.lib				%2\LIB\winrt\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_stitching\opencv_stitching.lib		%2\LIB\winrt\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_video\opencv_video.lib				%2\LIB\winrt\ARM\Release /y
copy %1\binWinRT\ARM\Release\opencv_videostab\opencv_videostab.lib		%2\LIB\winrt\ARM\Release /y


// WP8

md %2\LIB\wp8
md %2\LIB\wp8\Debug
md %2\LIB\wp8\Release

// WP8 Win32 LIB															   

copy %1\binWP8\Debug\zlib\zlib.lib										%2\LIB\binWP8\Debug /y
copy %1\binWP8\Debug\opencv_calib3d\opencv_calib3d.lib					%2\LIB\binWP8\Debug /y
copy %1\binWP8\Debug\opencv_contrib\opencv_contrib.lib					%2\LIB\binWP8\Debug /y
copy %1\binWP8\Debug\opencv_core\opencv_core.lib						%2\LIB\binWP8\Debug /y
copy %1\binWP8\Debug\opencv_features2d\opencv_features2d.lib			%2\LIB\binWP8\Debug /y
copy %1\binWP8\Debug\opencv_flann\opencv_flann.lib						%2\LIB\binWP8\Debug /y
copy %1\binWP8\Debug\opencv_imgproc\opencv_imgproc.lib					%2\LIB\binWP8\Debug /y
copy %1\binWP8\Debug\opencv_legacy\opencv_legacy.lib					%2\LIB\binWP8\Debug /y
copy %1\binWP8\Debug\opencv_ml\opencv_ml.lib							%2\LIB\binWP8\Debug /y
copy %1\binWP8\Debug\opencv_nonfree\opencv_nonfree.lib					%2\LIB\binWP8\Debug /y
copy %1\binWP8\Debug\opencv_objdetect\opencv_objdetect.lib				%2\LIB\binWP8\Debug /y
copy %1\binWP8\Debug\opencv_photo\opencv_photo.lib						%2\LIB\binWP8\Debug /y
copy %1\binWP8\Debug\opencv_shape\opencv_shape.lib						%2\LIB\binWP8\Debug /y
copy %1\binWP8\Debug\opencv_stitching\opencv_stitching.lib				%2\LIB\binWP8\Debug /y
copy %1\binWP8\Debug\opencv_video\opencv_video.lib						%2\LIB\binWP8\Debug /y
copy %1\binWP8\Debug\opencv_videostab\opencv_videostab.lib				%2\LIB\binWP8\Debug /y

copy %1\binWP8\Release\zlib\zlib.lib									%2\LIB\binWP8\Release /y
copy %1\binWP8\Release\opencv_calib3d\opencv_calib3d.lib				%2\LIB\binWP8\Release /y
copy %1\binWP8\Release\opencv_contrib\opencv_contrib.lib				%2\LIB\binWP8\Release /y
copy %1\binWP8\Release\opencv_core\opencv_core.lib						%2\LIB\binWP8\Release /y
copy %1\binWP8\Release\opencv_features2d\opencv_features2d.lib			%2\LIB\binWP8\Release /y
copy %1\binWP8\Release\opencv_flann\opencv_flann.lib					%2\LIB\binWP8\Release /y
copy %1\binWP8\Release\opencv_imgproc\opencv_imgproc.lib				%2\LIB\binWP8\Release /y
copy %1\binWP8\Release\opencv_legacy\opencv_legacy.lib					%2\LIB\binWP8\Release /y
copy %1\binWP8\Release\opencv_ml\opencv_ml.lib							%2\LIB\binWP8\Release /y
copy %1\binWP8\Release\opencv_nonfree\opencv_nonfree.lib				%2\LIB\binWP8\Release /y
copy %1\binWP8\Release\opencv_objdetect\opencv_objdetect.lib			%2\LIB\binWP8\Release /y
copy %1\binWP8\Release\opencv_photo\opencv_photo.lib					%2\LIB\binWP8\Release /y
copy %1\binWP8\Release\opencv_shape\opencv_shape.lib					%2\LIB\binWP8\Release /y
copy %1\binWP8\Release\opencv_stitching\opencv_stitching.lib			%2\LIB\binWP8\Release /y
copy %1\binWP8\Release\opencv_video\opencv_video.lib					%2\LIB\binWP8\Release /y
copy %1\binWP8\Release\opencv_videostab\opencv_videostab.lib			%2\LIB\binWP8\Release /y

// WP8 ARM LIB

copy %1\binWP8\ARM\Debug\zlib\zlib.lib									%2\LIB\binWP8\ARM\Debug /y
copy %1\binWP8\ARM\Debug\opencv_calib3d\opencv_calib3d.lib				%2\LIB\binWP8\ARM\Debug /y
copy %1\binWP8\ARM\Debug\opencv_contrib\opencv_contrib.lib				%2\LIB\binWP8\ARM\Debug /y
copy %1\binWP8\ARM\Debug\opencv_core\opencv_core.lib					%2\LIB\binWP8\ARM\Debug /y
copy %1\binWP8\ARM\Debug\opencv_features2d\opencv_features2d.lib		%2\LIB\binWP8\ARM\Debug /y
copy %1\binWP8\ARM\Debug\opencv_flann\opencv_flann.lib					%2\LIB\binWP8\ARM\Debug /y
copy %1\binWP8\ARM\Debug\opencv_imgproc\opencv_imgproc.lib				%2\LIB\binWP8\ARM\Debug /y
copy %1\binWP8\ARM\Debug\opencv_legacy\opencv_legacy.lib				%2\LIB\binWP8\ARM\Debug /y
copy %1\binWP8\ARM\Debug\opencv_ml\opencv_ml.lib						%2\LIB\binWP8\ARM\Debug /y
copy %1\binWP8\ARM\Debug\opencv_nonfree\opencv_nonfree.lib				%2\LIB\binWP8\ARM\Debug /y
copy %1\binWP8\ARM\Debug\opencv_objdetect\opencv_objdetect.lib			%2\LIB\binWP8\ARM\Debug /y
copy %1\binWP8\ARM\Debug\opencv_photo\opencv_photo.lib					%2\LIB\binWP8\ARM\Debug /y
copy %1\binWP8\ARM\Debug\opencv_shape\opencv_shape.lib					%2\LIB\binWP8\ARM\Debug /y
copy %1\binWP8\ARM\Debug\opencv_stitching\opencv_stitching.lib			%2\LIB\binWP8\ARM\Debug /y
copy %1\binWP8\ARM\Debug\opencv_video\opencv_video.lib					%2\LIB\binWP8\ARM\Debug /y
copy %1\binWP8\ARM\Debug\opencv_videostab\opencv_videostab.lib			%2\LIB\binWP8\ARM\Debug /y

copy %1\binWP8\ARM\Release\zlib\zlib.lib								%2\LIB\binWP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_calib3d\opencv_calib3d.lib			%2\LIB\binWP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_contrib\opencv_contrib.lib			%2\LIB\binWP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_core\opencv_core.lib					%2\LIB\binWP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_features2d\opencv_features2d.lib		%2\LIB\binWP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_flann\opencv_flann.lib				%2\LIB\binWP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_imgproc\opencv_imgproc.lib			%2\LIB\binWP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_legacy\opencv_legacy.lib				%2\LIB\binWP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_ml\opencv_ml.lib						%2\LIB\binWP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_nonfree\opencv_nonfree.lib			%2\LIB\binWP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_objdetect\opencv_objdetect.lib		%2\LIB\binWP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_photo\opencv_photo.lib				%2\LIB\binWP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_shape\opencv_shape.lib				%2\LIB\binWP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_stitching\opencv_stitching.lib		%2\LIB\binWP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_video\opencv_video.lib				%2\LIB\binWP8\ARM\Release /y
copy %1\binWP8\ARM\Release\opencv_videostab\opencv_videostab.lib		%2\LIB\binWP8\ARM\Release /y



