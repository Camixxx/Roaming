//
// MainPage.xaml.cpp
// Implementation of the MainPage class.
//

#include "pch.h"
#include "MainPage.xaml.h"



using namespace VideoCapture;

using namespace Platform;
using namespace Windows::Foundation;
using namespace Windows::Foundation::Collections;
using namespace Windows::UI::Xaml;
using namespace Windows::UI::Xaml::Controls;
using namespace Windows::UI::Xaml::Controls::Primitives;
using namespace Windows::UI::Xaml::Data;
using namespace Windows::UI::Xaml::Input;
using namespace Windows::UI::Xaml::Navigation;



MainPage::MainPage()
{
    InitializeComponent();
}

/// <summary>
/// 生成应用空页面.
/// </summary>
/// <param name="e">事件数据与描述用的参数.</param>
void MainPage::OnNavigatedTo(NavigationEventArgs^ e)
{
    (void) e;	// 未使用参数
    m_main = std::unique_ptr<AppMain>(new AppMain(Preview));
    m_main->start();
}
