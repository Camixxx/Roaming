//
// LanguageChoose.xaml.cpp
// LanguageChoose 类的实现
//

#include "pch.h"
#include "LanguageChoose.xaml.h"

using namespace VideoCapture;

using namespace Platform;
using namespace Platform::Collections;
using namespace Windows::Foundation;
using namespace Windows::Foundation::Collections;
using namespace Windows::Graphics::Display;
using namespace Windows::UI::Xaml;
using namespace Windows::UI::Xaml::Controls;
using namespace Windows::UI::Xaml::Controls::Primitives;
using namespace Windows::UI::Xaml::Data;
using namespace Windows::UI::Xaml::Input;
using namespace Windows::UI::Xaml::Interop;
using namespace Windows::UI::Xaml::Media;
using namespace Windows::UI::Xaml::Navigation;

// “基本页”项模板在 http://go.microsoft.com/fwlink/?LinkID=390556 上有介绍

LanguageChoose::LanguageChoose()
{
	InitializeComponent();
	SetValue(_defaultViewModelProperty, ref new Platform::Collections::Map<String^, Object^>(std::less<String^>()));
	auto navigationHelper = ref new Common::NavigationHelper(this);
	SetValue(_navigationHelperProperty, navigationHelper);
	navigationHelper->LoadState += ref new Common::LoadStateEventHandler(this, &LanguageChoose::LoadState);
	navigationHelper->SaveState += ref new Common::SaveStateEventHandler(this, &LanguageChoose::SaveState);
}

DependencyProperty^ LanguageChoose::_defaultViewModelProperty =
DependencyProperty::Register("DefaultViewModel",
TypeName(IObservableMap<String^, Object^>::typeid), TypeName(LanguageChoose::typeid), nullptr);

/// <summary>
/// 用作普通视图模型。
/// </summary>
IObservableMap<String^, Object^>^ LanguageChoose::DefaultViewModel::get()
{
	return safe_cast<IObservableMap<String^, Object^>^>(GetValue(_defaultViewModelProperty));
}

DependencyProperty^ LanguageChoose::_navigationHelperProperty =
DependencyProperty::Register("NavigationHelper",
TypeName(Common::NavigationHelper::typeid), TypeName(LanguageChoose::typeid), nullptr);

/// <summary>
/// 获取 <see cref="NavigationHelper"/> 的实现，该实现旨在
/// 用作普通视图模型。
/// </summary>
Common::NavigationHelper^ LanguageChoose::NavigationHelper::get()
{
	return safe_cast<Common::NavigationHelper^>(GetValue(_navigationHelperProperty));
}

#pragma region Navigation support

/// 此部分中提供的方法只是用于使
/// NavigationHelper 可响应页面的导航方法。
/// 
/// 应将页面特有的逻辑放入用于
/// <see cref="NavigationHelper::LoadState"/>
/// 和 <see cref="NavigationHelper::SaveState"/> 的事件处理程序中。
/// 除了在会话期间保留的页面状态之外
/// LoadState 方法中还提供导航参数。

void LanguageChoose::OnNavigatedTo(NavigationEventArgs^ e)
{
	NavigationHelper->OnNavigatedTo(e);
}

void LanguageChoose::OnNavigatedFrom(NavigationEventArgs^ e)
{
	NavigationHelper->OnNavigatedFrom(e);
}

#pragma endregion

/// <summary>
///使用在导航过程中传递的内容填充页。 在从以前的会话
/// 重新创建页时，也会提供任何已保存状态。
/// </summary>
/// <param name="sender">
/// 事件的来源；通常为 <see cref="NavigationHelper"/>
/// </param>
/// <param name="e">事件数据，其中既提供在最初请求此页时传递给
/// <see cref="Frame::Navigate(Type, Object)"/> 的导航参数，又提供
/// 此页在以前会话期间保留的状态的
/// 的字典。首次访问页面时，该状态将为 null。</param>
void LanguageChoose::LoadState(Object^ sender, Common::LoadStateEventArgs^ e)
{
	(void) sender;	// 未使用的参数
	(void) e;	// 未使用的参数
}

/// <summary>
/// 保留与此页关联的状态，以防挂起应用程序或
/// 从导航缓存中放弃此页。值必须符合
/// <see cref="SuspensionManager::SessionState"/> 的序列化要求。
/// </summary>
/// <param name="sender">事件的来源；通常为 <see cref="NavigationHelper"/></param>
/// <param name="e">提供要使用可序列化状态填充的空字典
/// 的事件数据。</param>
void LanguageChoose::SaveState(Object^ sender, Common::SaveStateEventArgs^ e){
	(void) sender;	// 未使用的参数
	(void) e; // 未使用的参数
}

