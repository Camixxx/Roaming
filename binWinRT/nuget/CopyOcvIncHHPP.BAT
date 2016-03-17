md %1 %2
md %1\opencv
copy %2\opencv\include\opencv\*.h %1\opencv /y
copy %2\opencv\include\opencv\*.hpp %1\opencv /y
md %1\opencv2
md %1\opencv2\calib3d
copy %2\opencv\modules\calib3d\include\opencv2\calib3d\*.h %1\opencv2\calib3d /y
copy %2\opencv\modules\calib3d\include\opencv2\calib3d\*.hpp %1\opencv2\calib3d /y
md %1\opencv2\contrib
copy %2\opencv\modules\contrib\include\opencv2\contrib\*.h %1\opencv2\contrib /y
copy %2\opencv\modules\contrib\include\opencv2\contrib\*.hpp %1\opencv2\contrib /y
md %1\opencv2\core
copy %2\opencv\modules\core\include\opencv2\core.hpp %1\opencv2 /y
copy %2\opencv\modules\core\include\opencv2\core\*.h %1\opencv2\core /y
copy %2\opencv\modules\core\include\opencv2\core\*.hpp %1\opencv2\core /y
md %1\opencv2\features2d
copy %2\opencv\modules\features2d\include\opencv2\features2d.hpp %1\opencv2 /y
copy %2\opencv\modules\features2d\include\opencv2\features2d\*.h %1\opencv2\features2d /y
copy %2\opencv\modules\features2d\include\opencv2\features2d\*.hpp %1\opencv2\features2d /y
md %1\opencv2\flann
copy %2\opencv\modules\flann\include\opencv2\flann\*.h %1\opencv2\flann /y
copy %2\opencv\modules\flann\include\opencv2\flann\*.hpp %1\opencv2\flann /y
md %1\opencv2\imgproc
copy %2\opencv\modules\imgproc\include\opencv2\imgproc\*.h %1\opencv2\imgproc /y
copy %2\opencv\modules\imgproc\include\opencv2\imgproc.hpp %1\opencv2 /y
copy %2\opencv\modules\imgproc\include\opencv2\imgproc\*.hpp %1\opencv2\imgproc /y
md %1\opencv2\legacy
copy %2\opencv\modules\legacy\include\opencv2\legacy.hpp %1\opencv2 /y
copy %2\opencv\modules\legacy\include\opencv2\legacy\*.h %1\opencv2\legacy /y
copy %2\opencv\modules\legacy\include\opencv2\legacy\*.hpp %1\opencv2\legacy /y
md %1\opencv2\ml
copy %2\opencv\modules\ml\include\opencv2\ml.hpp %1\opencv2 /y
copy %2\opencv\modules\ml\include\opencv2\ml\*.h %1\opencv2\ml /y
copy %2\opencv\modules\ml\include\opencv2\ml\*.hpp %1\opencv2\ml /y
md %1\opencv2\objdetect
copy %2\opencv\modules\objdetect\include\opencv2\objdetect\*.h %1\opencv2\objdetect /y
copy %2\opencv\modules\objdetect\include\opencv2\objdetect\*.hpp %1\opencv2\objdetect /y
md %1\opencv2\photo
copy %2\opencv\modules\photo\include\opencv2\photo\*.h %1\opencv2\photo /y
copy %2\opencv\modules\photo\include\opencv2\photo\*.hpp %1\opencv2\photo /y
md %1\opencv2\shape
copy %2\opencv\modules\shape\include\opencv2\shape\*.h %1\opencv2\shape /y
copy %2\opencv\modules\shape\include\opencv2\shape\*.hpp %1\opencv2\shape /y
md %1\opencv2\stitching
copy %2\opencv\modules\stitching\include\opencv2\stitching\*.h %1\opencv2\stitching /y
copy %2\opencv\modules\stitching\include\opencv2\stitching\*.hpp %1\opencv2\stitching /y
md %1\opencv2\video
copy %2\opencv\modules\video\include\opencv2\video\*.h %1\opencv2\video /y
copy %2\opencv\modules\video\include\opencv2\video\*.hpp %1\opencv2\video /y
md %1\opencv2\videostab
copy %2\opencv\modules\videostab\include\opencv2\videostab\*.h %1\opencv2\videostab /y
copy %2\opencv\modules\videostab\include\opencv2\videostab\*.hpp %1\opencv2\videostab /y