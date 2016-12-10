//
// NavigationHelper.cpp
// NavigationHelper 和关联类的实现
//

#include "pch.h"
#include "NavigationHelper.h"
#include "RelayCommand.h"
#include "SuspensionManager.h"

using namespace VideoCapture::Common;

using namespace Platform;
using namespace Platform::Collections;
using namespace Windows::Foundation;
using namespace Windows::Foundation::Collections;
using namespace Windows::System;
using namespace Windows::UI::Core;
using namespace Windows::UI::ViewManagement;
using namespace Windows::UI::Xaml;
using namespace Windows::UI::Xaml::Controls;
using namespace Windows::UI::Xaml::Input;
using namespace Windows::UI::Xaml::Interop;
using namespace Windows::UI::Xaml::Navigation;

#if WINAPI_FAMILY==WINAPI_FAMILY_PHONE_APP
using namespace Windows::Phone::UI::Input;
#endif

/// <summary>
/// 初始化 <see cref="LoadStateEventArgs"/> 类的新实例。
/// </summary>
/// <param name="navigationParameter">
/// 最初请求此页时传递给 <see cref="Frame->Navigate(Type, Object)"/> 
/// 的参数值。
/// </param>
/// <param name="pageState">
/// 此页在以前会话期间保留的状态
/// 的字典。 首次访问某页时，此项将为 null。
/// </param>
LoadStateEventArgs::LoadStateEventArgs(Object^ navigationParameter, IMap<String^, Object^>^ pageState)
{
	_navigationParameter = navigationParameter;
	_pageState = pageState;
}

/// <summary>
/// 获取 <see cref"LoadStateEventArgs"/> 类的 <see cref="NavigationParameter"/> 属性。
/// </summary>
Object^ LoadStateEventArgs::NavigationParameter::get()
{
	return _navigationParameter;
}

/// <summary>
/// 获取 <see cref"LoadStateEventArgs"/> 类的 <see cref="PageState"/> 属性。
/// </summary>
IMap<String^, Object^>^ LoadStateEventArgs::PageState::get()
{
	return _pageState;
}

/// <summary>
/// 初始化 <see cref="SaveStateEventArgs"/> 类的新实例。
/// </summary>
/// <param name="pageState">要使用可序列化状态填充的空字典。</param>
SaveStateEventArgs::SaveStateEventArgs(IMap<String^, Object^>^ pageState)
{
	_pageState = pageState;
}

/// <summary>
/// 获取 <see cref"SaveStateEventArgs"/> 类的 <see cref="PageState"/> 属性。
/// </summary>
IMap<String^, Object^>^ SaveStateEventArgs::PageState::get()
{
	return _pageState;
}

/// <summary>
/// 初始化 <see cref="NavigationHelper"/> 类的新实例。
/// </summary>
/// <param name="page">对当前页面的引用，用于导航。 
/// 此引用可操纵帧，并确保
/// 仅在页面占用整个窗口时产生导航请求。</param>
NavigationHelper::NavigationHelper(Page^ page, RelayCommand^ goBack, RelayCommand^ goForward) :
_page(page),
_goBackCommand(goBack),
_goForwardCommand(goForward)
{
	// 当此页是可视化树的一部分时，进行两个更改: 
	// 1) 将应用程序视图状态映射到页的可视状态
	// 2) 处理用于在 Windows 中向前和向后移动的
	_loadedEventToken = page->Loaded += ref new RoutedEventHandler(this, &NavigationHelper::OnLoaded);

	//// 当该页不再可见时，撤消相同更改
	_unloadedEventToken = page->Unloaded += ref new RoutedEventHandler(this, &NavigationHelper::OnUnloaded);
}

NavigationHelper::~NavigationHelper()
{
	delete _goBackCommand;
	delete _goForwardCommand;

	_page = nullptr;
}

/// <summary>
/// 在页面属于可视化树的一部分时调用
/// </summary>
/// <param name="sender">触发事件的实例。</param>
/// <param name="e">描述导致事件的条件的事件数据。</param>
void NavigationHelper::OnLoaded(Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
{
#if WINAPI_FAMILY==WINAPI_FAMILY_PHONE_APP
	_backPressedEventToken = HardwareButtons::BackPressed +=
		ref new EventHandler<BackPressedEventArgs^>(this,
		&NavigationHelper::HardwareButton_BackPressed);
#else
	Page ^page = _page.Resolve<Page>();

	// 仅当占用整个窗口时，键盘和鼠标导航才适用
	if (page != nullptr &&
		page->ActualHeight == Window::Current->Bounds.Height &&
		page->ActualWidth == Window::Current->Bounds.Width)
	{
		// 直接侦听窗口，因此无需焦点
		_acceleratorKeyEventToken = Window::Current->CoreWindow->Dispatcher->AcceleratorKeyActivated +=
			ref new TypedEventHandler<CoreDispatcher^, AcceleratorKeyEventArgs^>(this,
			&NavigationHelper::CoreDispatcher_AcceleratorKeyActivated);

		_pointerPressedEventToken = Window::Current->CoreWindow->PointerPressed +=
			ref new TypedEventHandler<CoreWindow^, PointerEventArgs^>(this,
			&NavigationHelper::CoreWindow_PointerPressed);

		_navigationShortcutsRegistered = true;
	}
#endif
}

/// <summary>
/// 在页面从可视化树中删除时调用
/// </summary>
/// <param name="sender">触发事件的实例。</param>
/// <param name="e">描述导致事件的条件的事件数据。</param>
void NavigationHelper::OnUnloaded(Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
{
#if WINAPI_FAMILY==WINAPI_FAMILY_PHONE_APP
	HardwareButtons::BackPressed -= _backPressedEventToken;
#else
	if (_navigationShortcutsRegistered)
	{
		Window::Current->CoreWindow->Dispatcher->AcceleratorKeyActivated -= _acceleratorKeyEventToken;
		Window::Current->CoreWindow->PointerPressed -= _pointerPressedEventToken;
		_navigationShortcutsRegistered = false;
	}
#endif

	// 移除处理程序并发布对该页的引用
	Page ^page = _page.Resolve<Page>();
	if (page != nullptr)
	{
		page->Loaded -= _loadedEventToken;
		page->Unloaded -= _unloadedEventToken;
		delete _goBackCommand;
		delete _goForwardCommand;
		_goForwardCommand = nullptr;
		_goBackCommand = nullptr;
	}
}

#pragma region Navigation support

/// <summary>
/// <see cref="GoBackCommand"/> 属性使用的方法，用于
/// 确定 <see cref="Frame"/> 能否后退。
/// </summary>
/// <returns>
/// 如果 <see cref="Frame"/> 至少在
/// 后退导航历史记录中有一个条目，则为 true。
/// </returns>
bool NavigationHelper::CanGoBack()
{
	Page ^page = _page.Resolve<Page>();
	if (page != nullptr)
	{
		auto frame = page->Frame;
		return (frame != nullptr && frame->CanGoBack);
	}

	return false;
}

/// <summary>
/// <see cref="GoBackCommand"/> 属性使用的方法，用于
/// 调用 <see cref="Windows::UI::Xaml::Controls::Frame::GoBack"/> 方法。
/// </summary>
void NavigationHelper::GoBack()
{
	Page ^page = _page.Resolve<Page>();
	if (page != nullptr)
	{
		auto frame = page->Frame;
		if (frame != nullptr && frame->CanGoBack)
		{
			frame->GoBack();
		}
	}
}

/// <summary>
/// <see cref="GoForwardCommand"/> 属性使用的方法，用于
/// 确定 <see cref="Frame"/> 能否前进。
/// </summary>
/// <returns>
/// 如果 <see cref="Frame"/> 至少在
/// 前进导航历史记录中有一个条目，则为 true。
/// </returns>
bool NavigationHelper::CanGoForward()
{
	Page ^page = _page.Resolve<Page>();
	if (page != nullptr)
	{
		auto frame = page->Frame;
		return (frame != nullptr && frame->CanGoForward);
	}

	return false;
}

/// <summary>
/// <see cref="GoForwardCommand"/> 属性使用的方法，用于
/// 调用 <see cref="Windows::UI::Xaml::Controls::Frame::GoBack"/> 方法。
/// </summary>
void NavigationHelper::GoForward()
{
	Page ^page = _page.Resolve<Page>();
	if (page != nullptr)
	{
		auto frame = page->Frame;
		if (frame != nullptr && frame->CanGoForward)
		{
			frame->GoForward();
		}
	}
}

/// <summary>
/// 获取 <see cref"NavigationHelper"/> 类的 <see cref="GoBackCommand"/> 属性。
/// </summary>
RelayCommand^ NavigationHelper::GoBackCommand::get()
{
	if (_goBackCommand == nullptr)
	{
		_goBackCommand = ref new RelayCommand(
			[this](Object^) -> bool
		{
			return CanGoBack();
		},
			[this](Object^) -> void
		{
			GoBack();
		}
		);
	}
	return _goBackCommand;
}

/// <summary>
/// 获取 <see cref"NavigationHelper"/> 类的 <see cref="GoForwardCommand"/> 属性。
/// </summary>
RelayCommand^ NavigationHelper::GoForwardCommand::get()
{
	if (_goForwardCommand == nullptr)
	{
		_goForwardCommand = ref new RelayCommand(
			[this](Object^) -> bool
		{
			return CanGoForward();
		},
			[this](Object^) -> void
		{
			GoForward();
		}
		);
	}
	return _goForwardCommand;
}

#if WINAPI_FAMILY==WINAPI_FAMILY_PHONE_APP
/// <summary>
/// 处理后退按钮按下事件并在根框架的历史记录中导航。
/// </summary>
void NavigationHelper::HardwareButton_BackPressed(Object^ sender, BackPressedEventArgs^ e)
{
	if (this->GoBackCommand->CanExecute(nullptr))
	{
		e->Handled = true;
		this->GoBackCommand->Execute(nullptr);
	}
}
#else
/// <summary>
/// 当此页处于活动状态并占用整个窗口时，在每次
/// 击键(包括系统键，如 Alt 组合键)时调用。    用于检测页之间的键盘
/// 导航(即使在页本身没有焦点时)。
/// </summary>
/// <param name="sender">触发事件的实例。</param>
/// <param name="e">描述导致事件的条件的事件数据。</param>
void NavigationHelper::CoreDispatcher_AcceleratorKeyActivated(CoreDispatcher^ sender,
	AcceleratorKeyEventArgs^ e)
{
	sender; // 未使用的参数
	auto virtualKey = e->VirtualKey;

	// 仅当按向左、向右或专用上一页或下一页键时才进一步
	// 调查
	if ((e->EventType == CoreAcceleratorKeyEventType::SystemKeyDown ||
		e->EventType == CoreAcceleratorKeyEventType::KeyDown) &&
		(virtualKey == VirtualKey::Left || virtualKey == VirtualKey::Right ||
		virtualKey == VirtualKey::GoBack || virtualKey == VirtualKey::GoForward))
	{
		auto coreWindow = Window::Current->CoreWindow;
		auto downState = Windows::UI::Core::CoreVirtualKeyStates::Down;
		bool menuKey = (coreWindow->GetKeyState(VirtualKey::Menu) & downState) == downState;
		bool controlKey = (coreWindow->GetKeyState(VirtualKey::Control) & downState) == downState;
		bool shiftKey = (coreWindow->GetKeyState(VirtualKey::Shift) & downState) == downState;
		bool noModifiers = !menuKey && !controlKey && !shiftKey;
		bool onlyAlt = menuKey && !controlKey && !shiftKey;

		if ((virtualKey == VirtualKey::GoBack && noModifiers) ||
			(virtualKey == VirtualKey::Left && onlyAlt))
		{
			// 在按上一页键或 Alt+向左键时向后导航
			e->Handled = true;
			GoBackCommand->Execute(this);
		}
		else if ((virtualKey == VirtualKey::GoForward && noModifiers) ||
			(virtualKey == VirtualKey::Right && onlyAlt))
		{
			// 在按下一页键或 Alt+向右键时向前导航
			e->Handled = true;
			GoForwardCommand->Execute(this);
		}
	}
}

/// <summary>
/// 当此页处于活动状态并占用整个窗口时，在每次鼠标单击、触摸屏点击
/// 或执行等效交互时调用。  用于检测浏览器样式下一页和
/// 上一步鼠标按钮单击以在页之间导航。
/// </summary>
/// <param name="sender">触发事件的实例。</param>
/// <param name="e">描述导致事件的条件的事件数据。</param>
void NavigationHelper::CoreWindow_PointerPressed(CoreWindow^ sender, PointerEventArgs^ e)
{
	auto properties = e->CurrentPoint->Properties;

	// 忽略与鼠标左键、右键和中键的键关联
	if (properties->IsLeftButtonPressed ||
		properties->IsRightButtonPressed ||
		properties->IsMiddleButtonPressed)
	{
		return;
	}

	// 如果按下后退或前进(但不是同时)，则进行相应导航
	bool backPressed = properties->IsXButton1Pressed;
	bool forwardPressed = properties->IsXButton2Pressed;
	if (backPressed ^ forwardPressed)
	{
		e->Handled = true;
		if (backPressed)
		{
			if (GoBackCommand->CanExecute(this))
			{
				GoBackCommand->Execute(this);
			}
		}
		else
		{
			if (GoForwardCommand->CanExecute(this))
			{
				GoForwardCommand->Execute(this);
			}
		}
	}
}
#endif

#pragma endregion

#pragma region Process lifetime management

/// <summary>
/// 在此页将要在 Frame 中显示时进行调用。
/// </summary>
/// <param name="e">描述如何访问此页的事件数据。Parameter
/// 属性提供要显示的组。</param>
void NavigationHelper::OnNavigatedTo(NavigationEventArgs^ e)
{
	Page ^page = _page.Resolve<Page>();
	if (page != nullptr)
	{
		auto frameState = SuspensionManager::SessionStateForFrame(page->Frame);
		_pageKey = "Page-" + page->Frame->BackStackDepth;

		if (e->NavigationMode == NavigationMode::New)
		{
			// 在向导航堆栈添加新页时清除向前导航的
			// 现有状态
			auto nextPageKey = _pageKey;
			int nextPageIndex = page->Frame->BackStackDepth;
			while (frameState->HasKey(nextPageKey))
			{
				frameState->Remove(nextPageKey);
				nextPageIndex++;
				nextPageKey = "Page-" + nextPageIndex;
			}

			// 将导航参数传递给新页
			LoadState(this, ref new LoadStateEventArgs(e->Parameter, nullptr));
		}
		else
		{
			// 通过将相同策略用于加载挂起状态并从缓存重新创建
			// 放弃的页，将导航参数和保留页状态传递
			// 给页
			LoadState(this, ref new LoadStateEventArgs(e->Parameter, safe_cast<IMap<String^, Object^>^>(frameState->Lookup(_pageKey))));
		}
	}
}

/// <summary>
/// 当此页不再在 Frame 中显示时调用。
/// </summary>
/// <param name="e">描述如何访问此页的事件数据。Parameter
/// 属性提供要显示的组。</param>
void NavigationHelper::OnNavigatedFrom(NavigationEventArgs^ e)
{
	Page ^page = _page.Resolve<Page>();
	if (page != nullptr)
	{
		auto frameState = SuspensionManager::SessionStateForFrame(page->Frame);
		auto pageState = ref new Map<String^, Object^>();
		SaveState(this, ref new SaveStateEventArgs(pageState));
		frameState->Insert(_pageKey, pageState);
	}
}
#pragma endregion