<#
Copyright © Microsoft Open Technologies, Inc.
All Rights Reserved        
Licensed under the Apache License, Version 2.0 (the "License"); 
you may not use this file except in compliance with the License. 

You may obtain a copy of the License at 
http://www.apache.org/licenses/LICENSE-2.0 
 
THIS CODE IS PROVIDED ON AN *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED WARRANTIES OR CONDITIONS OF TITLE, 
FITNESS FOR A PARTICULAR PURPOSE, MERCHANTABLITY OR NON-INFRINGEMENT. 
 
See the Apache 2 License for the specific language governing permissions and limitations under the License.
#>

. ".\scripts\createsln.ps1"
. ".\scripts\converterutils.ps1"
. ".\scripts\winrtconverter.ps1"

#$WorkingDir = (Get-Location).Path
$WorkingDir = $PSScriptRoot
$InputDir = join-path $WorkingDir "..\bin" -Resolve
$WinRTOutputDir = $WorkingDir
$WP8OutputDir = join-path $WorkingDir "..\binWP8"
$WP8_1OutputDir = join-path $WorkingDir "..\binWP8_1"

Function Convert($OutputDir, $platform)
{
    Write-Host "Converting " $platform " projects..."

    $includehack = GetDirectoryName($OutputDir)


    $zlib = "3rdparty\zlib\zlib.vcxproj"
    $jpeg = "3rdparty\libjpeg\libjpeg.vcxproj"
    $jasper = "3rdparty\libjasper\libjasper.vcxproj"
    $tiff = "3rdparty\libtiff\libtiff.vcxproj"
    $png = "3rdparty\libpng\libpng.vcxproj"
    $core = "modules\core\opencv_core.vcxproj"
    $imgproc = "modules\imgproc\opencv_imgproc.vcxproj"
    $flann = "modules\flann\opencv_flann.vcxproj"
    $photo = "modules\photo\opencv_photo.vcxproj"
    $calib3d = "modules\calib3d\opencv_calib3d.vcxproj"
    $ml = "modules\ml\opencv_ml.vcxproj"
    $objdetect = "modules\objdetect\opencv_objdetect.vcxproj"
    $video = "modules\video\opencv_video.vcxproj"
    $videostab = "modules\videostab\opencv_videostab.vcxproj"
    $features2d = "modules\features2d\opencv_features2d.vcxproj"
    $stitching = "modules\stitching\opencv_stitching.vcxproj"
    $shape = "modules\shape\opencv_shape.vcxproj"


    $projects = ($zlib, $jpeg, $tiff, $jasper, $png, $core, $imgproc, $flann, $photo, $calib3d, $ml, $objdetect, $video, $videostab, $features2d, $stitching, $shape)

    foreach($project in $projects)
    {

        $in = join-path $InputDir $project
        $out = join-path $OutputDir $project
        try
        {
            Write-Host ("Converting: " + $project)
            WinrtConverter $in $out $platform $includehack >> $null
        }
        catch
        {
            Write-Error ("Did not convert " + $project)
            Write-Error ("Error: " + $_)
        }
    }

    try
    {
        $allProjects = @()
        Copy-Item (join-path $InputDir "cvconfig.h") (join-path $OutputDir "cvconfig.h")

        $dir = join-path $OutputDir "opencv2"
        New-Item -ItemType Directory -Force -Path $dir >> $null
        Copy-Item (join-path $InputDir "opencv2\opencv_modules.hpp") (join-path $OutputDir "opencv2\opencv_modules.hpp")

        $allProjects += $zlibProject = join-path $OutputDir -childpath $zlib
        Copy-Item (join-path $InputDir "3rdparty\zlib\zconf.h") (join-path $OutputDir "3rdparty\zlib\zconf.h")

        $allProjects += $jpegProject = join-path $OutputDir -childpath  $jpeg
        $allProjects += $jasperProject = join-path $OutputDir -childpath $jasper
        $openexrProject = join-path $OutputDir -childpath "3rdparty\openexr\IlmImf.vcxproj"

        $allProjects += $tiffProject = join-path $OutputDir -childpath $tiff
        ReplaceText $tiffProject "tif_win32.c" "tif_unix.c"
        ReplaceText ($tiffProject + ".filters") "tif_win32.c" "tif_unix.c"
        Copy-Item (join-path $InputDir "3rdparty\libtiff\tif_config.h") (join-path $OutputDir "3rdparty\libtiff\tif_config.h")

        $allProjects += $pngProject = join-path $OutputDir -childpath $png
        $xml = LoadXmlFile($pngProject)
        AddPreprocessorDefine $xml "HAVE_WINRT"
        $xml.Save($pngProject)

        #opencv_core.vcxproj

        $allProjects += $coreProject = join-path $OutputDir -childpath $core
        $inputProject = join-path $InputDir -childpath $core
        $inDir = Split-Path -parent $inputProject
        $outDir = Split-Path -parent $coreProject
        $xml = LoadXmlFile($coreProject)
        Copy-Item (join-path $inDir "opencv_core_pch.cpp") (join-path $outDir "opencv_core_pch.cpp") 
        Copy-Item (join-path $InputDir "modules\core\opencl_kernels.cpp") (join-path $OutputDir "modules\core\opencl_kernels.cpp") 
        Copy-Item (join-path $InputDir "modules\core\opencl_kernels.hpp") (join-path $OutputDir "modules\core\opencl_kernels.hpp")
        Copy-Item (join-path $InputDir "modules\core\version_string.inc") (join-path $OutputDir "modules\core\version_string.inc")
 
        #opencv_flann.vcxproj
        $allProjects += $flannProject = join-path $OutputDir -childpath $flann
        Copy-Item (join-path $InputDir "modules\flann\opencv_flann_pch.cpp") (join-path $OutputDir "modules\flann\opencv_flann_pch.cpp")
 
        #opencv_imgproc.vcxproj
        $allProjects += $imgprocProject = join-path $OutputDir -childpath $imgproc
        Copy-Item (join-path $InputDir "modules\imgproc\opencv_imgproc_pch.cpp") (join-path $OutputDir "modules\imgproc\opencv_imgproc_pch.cpp")
        Copy-Item (join-path $InputDir "modules\imgproc\opencl_kernels.cpp") (join-path $OutputDir "modules\imgproc\opencl_kernels.cpp") 
        Copy-Item (join-path $InputDir "modules\imgproc\opencl_kernels.hpp") (join-path $OutputDir "modules\imgproc\opencl_kernels.hpp")

        $allProjects += $photoProject = join-path $OutputDir -childpath $photo
        Copy-Item (join-path $InputDir "modules\photo\opencv_photo_pch.cpp") (join-path $OutputDir "modules\photo\opencv_photo_pch.cpp") 
        Copy-Item (join-path $InputDir "modules\photo\opencl_kernels.cpp") (join-path $OutputDir "modules\photo\opencl_kernels.cpp") 
        Copy-Item (join-path $InputDir "modules\photo\opencl_kernels.hpp") (join-path $OutputDir "modules\photo\opencl_kernels.hpp")

        $allProjects += $calib3dProject = join-path $OutputDir -childpath $calib3d
        Copy-Item (join-path $InputDir "modules\calib3d\opencv_calib3d_pch.cpp") (join-path $OutputDir "modules\calib3d\opencv_calib3d_pch.cpp") 
        Copy-Item (join-path $InputDir "modules\calib3d\opencl_kernels.cpp") (join-path $OutputDir "modules\calib3d\opencl_kernels.cpp") 
        Copy-Item (join-path $InputDir "modules\calib3d\opencl_kernels.hpp") (join-path $OutputDir "modules\calib3d\opencl_kernels.hpp")

        $allProjects += $mlProject = join-path $OutputDir -childpath $ml
        Copy-Item (join-path $InputDir "modules\ml\opencv_ml_pch.cpp") (join-path $OutputDir "modules\ml\opencv_ml_pch.cpp")

        #opencv_objdetect.vcxproj
        $allProjects += $objdetectProject = join-path $OutputDir -childpath $objdetect
        Copy-Item (join-path $InputDir "modules\objdetect\opencv_objdetect_pch.cpp") (join-path $OutputDir "modules\objdetect\opencv_objdetect_pch.cpp")
        Copy-Item (join-path $InputDir "modules\objdetect\opencl_kernels.cpp") (join-path $OutputDir "modules\objdetect\opencl_kernels.cpp") 
        Copy-Item (join-path $InputDir "modules\objdetect\opencl_kernels.hpp") (join-path $OutputDir "modules\objdetect\opencl_kernels.hpp")

        #opencv_video.vcxproj
        $allProjects += $videoProject = join-path $OutputDir -childpath $video
        Copy-Item (join-path $InputDir "modules\video\opencv_video_pch.cpp") (join-path $OutputDir "modules\video\opencv_video_pch.cpp")
        Copy-Item (join-path $InputDir "modules\video\opencl_kernels.cpp") (join-path $OutputDir "modules\video\opencl_kernels.cpp") 
        Copy-Item (join-path $InputDir "modules\video\opencl_kernels.hpp") (join-path $OutputDir "modules\video\opencl_kernels.hpp")

        #opencv_videostab.vcxproj
        $allProjects += $videostabProject = join-path $OutputDir -childpath $videostab
        Copy-Item (join-path $InputDir "modules\videostab\opencv_videostab_pch.cpp") (join-path $OutputDir "modules\videostab\opencv_videostab_pch.cpp")
 
        #opencv_features2d.vcxproj
        $allProjects += $features2dProject = join-path $OutputDir -childpath $features2d
        Copy-Item (join-path $InputDir "modules\features2d\opencv_features2d_pch.cpp") (join-path $OutputDir "modules\features2d\opencv_features2d_pch.cpp") 
        Copy-Item (join-path $InputDir "modules\features2d\opencl_kernels.cpp") (join-path $OutputDir "modules\features2d\opencl_kernels.cpp") 
        Copy-Item (join-path $InputDir "modules\features2d\opencl_kernels.hpp") (join-path $OutputDir "modules\features2d\opencl_kernels.hpp")

        #opencv_stitching.vcxproj
        $allProjects += $stitchingProject = join-path $OutputDir -childpath $stitching
        Copy-Item (join-path $InputDir "modules\stitching\opencv_stitching_pch.cpp") (join-path $OutputDir "modules\stitching\opencv_stitching_pch.cpp") 
        Copy-Item (join-path $InputDir "modules\stitching\opencl_kernels.cpp") (join-path $OutputDir "modules\stitching\opencl_kernels.cpp") 
        Copy-Item (join-path $InputDir "modules\stitching\opencl_kernels.hpp") (join-path $OutputDir "modules\stitching\opencl_kernels.hpp")
       
        #opencv_shape.vcxproj
        $allProjects += $shapeProject = join-path $OutputDir -childpath $shape
        Copy-Item (join-path $InputDir "modules\shape\opencv_shape_pch.cpp") (join-path $OutputDir "modules\shape\opencv_shape_pch.cpp") 

        #create libpng sln and project references
        $pngDir = Split-Path -parent $pngProject
        AddProjectReference $pngProject $zlibProject >> $null
        $output = join-path $pngDir "libpng.sln"
        CreateSolutionFile $output $platform ($pngProject, $zlibProject)

        #create libtiff sln and project references
        $tiffDir = Split-Path -parent $tiffProject
        AddProjectReference $tiffProject $zlibProject >> $null
        $output = join-path $tiffDir "libtiff.sln"
        CreateSolutionFile $output $platform ($tiffProject, $zlibProject)

        #create opencv_core sln and project references
        $coreDir = Split-Path -parent $coreProject
        AddProjectReference $coreProject $zlibProject >> $null
        $output = join-path $coreDir "opencv_core.sln"
        CreateSolutionFile $output $platform ($coreProject, $zlibProject)

        #create opencv_flann sln and project references
        $flannDir = Split-Path -parent $flannProject
        AddProjectReference $flannProject $coreProject >> $null
        $output = join-path $flannDir "opencv_flann.sln"
        CreateSolutionFile $output $platform ($flannProject, $coreProject, $zlibProject)

        #create opencv_imgproc sln and project references
        $imgprocDir = Split-Path -parent $imgprocProject
        AddProjectReference $imgprocProject $coreProject >> $null
        $output = join-path $imgprocDir "opencv_imgproc.sln"
        CreateSolutionFile $output $platform ($imgprocProject, $coreProject, $zlibProject)

        #create opencv_photo sln and project references
        $photoDir = Split-Path -parent $photoProject
        AddProjectReference $photoProject ($coreProject, $imgprocProject) >> $null
        $output = join-path $photoDir "opencv_photo.sln"
        CreateSolutionFile $output $platform ($photoProject, $imgprocProject, $coreProject, $zlibProject)

        #create opencv_features2d sln and project references
        $features2dDir = Split-Path -parent $features2dProject
        AddProjectReference $features2dProject ($coreProject,  $imgprocProject, $flannProject) >> $null
        $output = join-path $features2dDir "features2d.sln"
        CreateSolutionFile $output $platform ($features2dProject, $coreProject, $imgprocProject, $flannProject, $zlibProject, $pngProject, $tiffProject, $jpegProject)

        #create opencv_calib3d sln and project references
        $calib3dDir = Split-Path -parent $calib3dProject
        AddProjectReference $calib3dProject ($coreProject, $imgprocProject, $flannProject, $features2dProject) >> $null
        $output = join-path $calib3dDir "opencv_calib3d.sln"
        CreateSolutionFile $output $platform ($features2dProject, $coreProject, $imgprocProject, $flannProject, $zlibProject, $pngProject, $tiffProject, $jpegProject)

        #create opencv_ml sln and project references
        $mlDir = Split-Path -parent $mlProject
        AddProjectReference $mlProject $coreProject >> $null
        $output = join-path $mlDir "opencv_ml.sln"
        CreateSolutionFile $output $platform ($mlProject, $coreProject, $zlibProject)

        #create opencv_shape sln and project references
        $shapeDir = Split-Path -parent $shapeProject
        AddProjectReference $shapeProject ($coreProject, $imgprocProject, $videoProject) >> $null
        $output = join-path $shapeDir "opencv_shape.sln"
        CreateSolutionFile $output $platform ($shapeProject, $coreProject, $imgprocProject, $videoProject, $zlibProject)

        #create opencv_objdetect sln and project references
        $objdetectDir = Split-Path -parent $objdetectProject
        AddProjectReference $objdetectProject  ($coreProject, $imgprocProject, $mlProject) >> $null
        $output = join-path $objdetectDir "opencv_objdetect.sln"
        CreateSolutionFile $output $platform ($objdetectProject, $coreProject, $imgprocProject, $mlProject, $zlibProject)

        #create opencv_video sln and project references
        $videoDir = Split-Path -parent $videoProject
        AddProjectReference $videoProject  ($coreProject, $imgprocProject) >> $null
        $output = join-path $videoDir "opencv_video.sln"
        CreateSolutionFile $output $platform ($videoProject, $coreProject, $imgprocProject, $zlibProject)

        #create opencv_videostab sln and project references
        $videostabDir = Split-Path -parent $videostabProject
        AddProjectReference $videostabProject  ($coreProject, $calib3dProject,$features2dProject, $flannProject, $imgprocProject, $photoProject, $videoProject) >> $null
        $output = join-path $videostabDir "opencv_videostab.sln"
        CreateSolutionFile $output $platform ($videostabProject, $coreProject, $calib3dProject,$features2dProject, $flannProject, $imgprocProject, $photoProject, $videoProject, $zlibProject)

        #create opencv_stitching sln and project references
        $stitchingDir = Split-Path -parent $stitchingProject
        AddProjectReference $stitchingProject ($coreProject, $calib3dProject, $imgprocProject, $flannProject, $features2dProject, $mlProject, $objdetectProject) >> $null
        $output = join-path $stitchingDir "opencv_stitching.sln"
        CreateSolutionFile $output $platform ($stitchingProject, $coreProject, $calib3dProject, $imgprocProject, $flannProject, $features2dProject, $mlProject, $objdetectProject, $zlibProject)

        #create opencv sln 
        $output = join-path $OutputDir "opencv.sln"
        CreateSolutionFile $output $platform ($allProjects)
 
        Write-Host "Conversion complete."
    }
    catch
    {
        Write-Error ("Error: " + $_)
    }
}

#convert Win32 OpenCV projects to WinRT, WP8 and WP8_1
Convert $WinRTOutputDir "winrt"
Convert $WP8OutputDir "wp8"
Convert $WP8_1OutputDir "wp8_1"
.\copyincludes.bat
