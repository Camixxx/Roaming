//
// MainPage.xaml.cpp
// Implementation of the MainPage class.
//

#include "pch.h"
#include "MainPage.xaml.h"
#include "LanguageChoose.xaml.h"
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
using namespace Windows::UI::Xaml::Navigation;
using namespace Windows::Graphics::Display;
using namespace Windows::UI::Xaml::Navigation;
// The Blank Page item template is documented at http://go.microsoft.com/fwlink/?LinkId=234238

MainPage::MainPage()
{
	InitializeComponent();
    Windows::UI::ViewManagement::StatusBar::GetForCurrentView()->HideAsync();
    Application::Current->DebugSettings->EnableFrameRateCounter = false;
    DisplayInformation::AutoRotationPreferences = DisplayOrientations::Landscape;
}

/// <summary>
/// Invoked when this page is about to be displayed in a Frame.
/// </summary>
/// <param name="e">表述页面的事件数据，参数用于设置页面.</param>
void MainPage::OnNavigatedTo(NavigationEventArgs^ e)
{
	(void) e;	// 未使用参数


    m_main = std::unique_ptr<AppMain>(new AppMain(Preview));
    m_main->start();
}


void VideoCapture::MainPage::BUTTON_LANGUANGE_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
{ 
	printf("LanguageSetting");
	//this->Frame->Navigate(LanguageChoose::typeid, NULL);
}



void VideoCapture::MainPage::BUTTON_ORDER_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
{
	printf("RecordOrders");
	
}
