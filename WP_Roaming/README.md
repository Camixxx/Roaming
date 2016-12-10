### OpenCV: Open Source Computer Vision Library
     This Project need OpenCV for winRT and WP8.1
     The environment can be find on github(https://github.com/MSOpenTech/opencv.git)
     Please choose the right  branch[for WinRT]
     这个项目是基于OpenCV for WinRT的环境的，对应的支持可以在github(https://github.com/MSOpenTech/opencv.git)上面找到，请选择正确的分支进行下载。


###如果要运行工程

#####1. OpenCV BuildPath
          环境变量配置
* Where is the source code: path to opencv
* Where to build the binaries: path to opencv/bin


#####2.  Select ONLY the following Options
          从OpencvForWinRT上下载winRT分支的代码，然后把
          */3rdparty
          */include
          */modules
          */binWinRT
          */binWP8_1
          这几个文件放到文件夹下

#####3.Open Roaming
         打开Roaming文件夹，运行工程


######Note: Make sure the ```ENABLE_WINRT_MODE```	option is off. This step builds for Win32.

* BUILD_JASPER
* BUILD_JPEG
* BUILD_PNG
* BUILD_SHARED_LIBS
* BUILD_TIFF
* BUILD_WITH_DEBUG_INFO
* BUILD_WITH_STATIC_CRT
* BUILD_ZLIB
* BUILD_opencv_calib3d
* BUILD_opencv_contrib
* BUILD_opencv_core
* BUILD_opencv_features2d
* BUILD_opencv_flann
* BUILD_opencv_imgproc
* BUILD_opencv_legacy
* BUILD_opencv_ml
* BUILD_opencv_objdetect
* BUILD_opencv_photo
* BUILD_opencv_shape
* BUILD_opencv_stitching
* BUILD_opencv_video
* BUILD_opencv_videostab
* ENABLE_PRECOMPILED_HEADERS
* ENABLE_SOLUTION_FOLDERS
* ENABLE_SSE
* ENABLE_SSE2
* WITH_JASPER
* WITH_JPEG
* WITH_PNG
* WITH_TIFF
* WITH_VFW
