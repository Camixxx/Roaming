#include "pch.h"
#include "AppMain.h"
#include "MainPage.g.h"

using namespace VideoCapture;

using namespace Platform;
using namespace Windows::Foundation;
using namespace Windows::Foundation::Collections;
using namespace Windows::UI::Xaml;
using namespace Windows::UI::Xaml::Controls;
using namespace Windows::UI::Xaml::Controls::Primitives;
using namespace Windows::UI::Xaml::Data;
using namespace Windows::UI::Xaml::Input;
using namespace Windows::UI::Xaml::Media;
using namespace Microsoft::WRL;
using namespace Windows::Media::MediaProperties;
using namespace Windows::UI::Xaml::Media::Imaging;
using namespace Windows::Storage::Streams;

#include <opencv2\highgui\cap_winrt\WinRTVideoCapture.h>
#include <opencv2\imgproc\types_c.h>
#include <opencv2\core\core.hpp>
#include <opencv2\imgproc\imgproc.hpp>

static const int sWidth = 640;
static const int sHeight = 360;

AppMain::AppMain(Image^ image)
    : m_image(image)
    , m_width(sWidth)
    , m_height(sHeight)
{
    image->Width = sWidth;
    image->Height = sHeight;
}

AppMain::~AppMain()
{

}

inline void ThrowIfFailed(HRESULT hr)
{
    if (FAILED(hr))
    {
        throw Exception::CreateException(hr);
    }
}

// Helper function to get pointer to WriteableBitmap pixel buffer
byte* GetPointerToPixelData(IBuffer^ buffer)
{
    // Cast to Object^, then to its underlying IInspectable interface.
    Object^ obj = buffer;
    ComPtr<IInspectable> insp(reinterpret_cast<IInspectable*>(obj));

    // Query the IBufferByteAccess interface.
    ComPtr<IBufferByteAccess> bufferByteAccess;
    ThrowIfFailed(insp.As(&bufferByteAccess));

    // Retrieve the buffer data.
    byte* pixels = nullptr;
    ThrowIfFailed(bufferByteAccess->Buffer(&pixels));
    return pixels;
}

void AppMain::start(int width, int height)
{
    m_width = width;
    m_height = height;
    start();
}

void AppMain::start()
{
    // create a WriteableBitmap
    m_bitmap = ref new WriteableBitmap(m_width, m_height);

    // create the Video Capture device
    m_capture = WinRTVideoCapture::create(m_width, m_height);

    // start capturing video. Callback will happen on the UI thread
    m_capture->start([this](const cv::Mat& mat) {
        // convert to grayscale
        cv::Mat intermediateMat;
        cv::cvtColor(mat, intermediateMat, CV_RGB2GRAY);

        // convert to BGRA
        cv::Mat output;
        cv::cvtColor(intermediateMat, output, CV_GRAY2BGRA);

		//convert to CannyImg
		int threshold = 70;
		cv::Mat cannyImg;
		cv::Canny(output, cannyImg, threshold, threshold * 2, 3);
		cv::cvtColor(cannyImg, output, CV_GRAY2BGRA);

		// convert to Contours
		//cv::Mat contoursLine;
		//cv::findContours(cannyImg, output ,CV_CONTOURS_MATCH_I1);

        // copy processed image into the WriteableBitmap
        memcpy(GetPointerToPixelData(m_bitmap->PixelBuffer), output.data, m_width * m_height * 4);

        // display the image
        m_image->Source = m_bitmap;
        m_bitmap->Invalidate();
    });
}

void AppMain::stop()
{

}
