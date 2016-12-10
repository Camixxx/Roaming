//
// MainPage.xaml.h
// Declaration of the MainPage class.
//

#pragma once

#include "MainPage.g.h"
#include "AppMain.h"
#include "LanguageChoose.g.h"


#include <opencv2\highgui\cap_winrt\WinRTVideoCapture.h>
#include <memory>

namespace VideoCapture
{
	/// <summary>
	/// 空页面框架
	/// </summary>
	public ref class MainPage sealed
	{
	public:
		MainPage();

	protected:
		virtual void OnNavigatedTo(Windows::UI::Xaml::Navigation::NavigationEventArgs^ e) override;

    private:
        std::unique_ptr<AppMain> m_main;
		void BUTTON_LANGUANGE_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
		void BUTTON_ORDER_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
	};
}
