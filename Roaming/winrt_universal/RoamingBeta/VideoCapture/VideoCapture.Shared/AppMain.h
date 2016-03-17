#pragma once

#include <opencv2\highgui\cap_winrt\WinRTVideoCapture.h>

// Renders Direct2D and 3D content on the screen.
namespace VideoCapture
{
	class AppMain
	{
	public:
        AppMain(Windows::UI::Xaml::Controls::Image^ image);
        ~AppMain();
        void start();
        void start(int width, int height);
        void stop();

	private:
        Windows::UI::Xaml::Media::Imaging::WriteableBitmap^ m_bitmap;
        HWinRTVideoCapture m_capture;
        unsigned int m_width;
        unsigned int m_height;

        Windows::UI::Xaml::Controls::Image^ m_image;
	};
}