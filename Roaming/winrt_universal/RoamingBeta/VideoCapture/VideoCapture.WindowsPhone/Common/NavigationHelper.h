//
// NavigationHelper.h
// NavigationHelper 和关联类的声明
//

#pragma once

#include "RelayCommand.h"

namespace VideoCapture
{
	namespace Common
	{
		/// <summary>
		/// 一个类，用于存放在某页尝试加载状态时所需的事件数据。
		/// </summary>
		public ref class LoadStateEventArgs sealed
		{
		public:

			/// <summary>
			/// 最初请求此页时传递给 <see cref="Frame->Navigate(Type, Object)"/> 
			/// 的参数值。
			/// </summary>
			property Platform::Object^ NavigationParameter
			{
				Platform::Object^ get();
			}

			/// <summary>
			/// 此页在以前会话期间保留的状态
			/// 的字典。 首次访问某页时，此项将为 null。
			/// </summary>
			property Windows::Foundation::Collections::IMap<Platform::String^, Platform::Object^>^ PageState
			{
				Windows::Foundation::Collections::IMap<Platform::String^, Platform::Object^>^ get();
			}

		internal:
			LoadStateEventArgs(Platform::Object^ navigationParameter, Windows::Foundation::Collections::IMap<Platform::String^, Platform::Object^>^ pageState);

		private:
			Platform::Object^ _navigationParameter;
			Windows::Foundation::Collections::IMap<Platform::String^, Platform::Object^>^ _pageState;
		};

		/// <summary>
		/// 代表将处理 <see cref="NavigationHelper->LoadState"/> 事件的方法
		/// </summary>
		public delegate void LoadStateEventHandler(Platform::Object^ sender, LoadStateEventArgs^ e);

		/// <summary>
		/// 一个类，用于存放在某页尝试保存状态时所需的事件数据。
		/// </summary>
		public ref class SaveStateEventArgs sealed
		{
		public:

			/// <summary>
			/// 要填入可序列化状态的空字典。
			/// </summary>
			property Windows::Foundation::Collections::IMap<Platform::String^, Platform::Object^>^ PageState
			{
				Windows::Foundation::Collections::IMap<Platform::String^, Platform::Object^>^ get();
			}

		internal:
			SaveStateEventArgs(Windows::Foundation::Collections::IMap<Platform::String^, Platform::Object^>^ pageState);

		private:
			Windows::Foundation::Collections::IMap<Platform::String^, Platform::Object^>^ _pageState;
		};

		/// <summary>
		/// 代表将处理 <see cref="NavigationHelper->SaveState"/> 事件的方法
		/// </summary>
		public delegate void SaveStateEventHandler(Platform::Object^ sender, SaveStateEventArgs^ e);

		/// <summary>
		/// NavigationHelper 协助在页面间进行导航。它提供一些命令，用于
		/// 前后导航以及注册用于前进和后退的标准鼠标和键盘
		/// 导航请求快捷方式和 Windows Phone 中的
		/// 硬件“后退”按钮。此外，它集成了 SuspensionManger 以在页面之间导航时处理
		/// 进程生存期管理和状态管理。
		/// </summary>
		/// <example>
		/// 若要利用 NavigationHelper，请执行下面两步或
		/// 以 BasicPage 或除 BlankPage 以外的任何页项开始。
		/// 
		/// 1) 在某处创建一个 NavigationHelper 实例(如
		///		页面的构造函数中)，并注册 LoadState 和 
		///		SaveState 事件的回调。
		/// <code>
		///		MyPage::MyPage()
		///		{
		///			InitializeComponent();
		///			auto navigationHelper = ref new Common::NavigationHelper(this);
		///			navigationHelper->LoadState += ref new Common::LoadStateEventHandler(this, &MyPage::LoadState);
		///			navigationHelper->SaveState += ref new Common::SaveStateEventHandler(this, &MyPage::SaveState);
		///		}
		///		
		///		void MyPage::LoadState(Object^ sender, Common::LoadStateEventArgs^ e)
		///		{ }
		///		void MyPage::SaveState(Object^ sender, Common::SaveStateEventArgs^ e)
		///		{ }
		/// </code>
		/// 
		/// 2) 在以下情况下注册页面以调入 NavigationHelper: 该页面
		///		通过重写 <see cref="Windows::UI::Xaml::Controls::Page::OnNavigatedTo"/>
		///		和 <see cref="Windows::UI::Xaml::Controls::Page::OnNavigatedFrom"/> 事件参与导航。
		/// <code>
		///		void MyPage::OnNavigatedTo(NavigationEventArgs^ e)
		///		{
		///			NavigationHelper->OnNavigatedTo(e);
		///		}
		///
		///		void MyPage::OnNavigatedFrom(NavigationEventArgs^ e)
		///		{
		///			NavigationHelper->OnNavigatedFrom(e);
		///		}
		/// </code>
		/// </example>
		[Windows::Foundation::Metadata::WebHostHidden]
		[Windows::UI::Xaml::Data::Bindable]
		public ref class NavigationHelper sealed
		{
		public:
			/// <summary>
			/// 如果 Frame 管理其导航历史记录，则 <see cref="RelayCommand"/> 用于绑定到后退按钮的 Command 属性
			/// 以导航到后退导航历史记录中的最新项
			///。
			/// 
			/// <see cref="RelayCommand"/> 被设置为使用虚拟方法 <see cref="GoBack"/>
			/// 作为执行操作，并将 <see cref="CanGoBack"/> 用于 CanExecute。
			/// </summary>
			property RelayCommand^ GoBackCommand
			{
				RelayCommand^ get();
			}

			/// <summary>
			/// 如果 Frame 管理其导航历史记录，则 <see cref="RelayCommand"/> 用于导航到
			/// 前进历史记录中的最新项。
			/// 
			/// <see cref="RelayCommand"/> 被设置为使用虚拟方法 <see cref="GoForward"/>
			/// 作为执行操作，并将 <see cref="CanGoForward"/> 用于 CanExecute。
			/// </summary>
			property RelayCommand^ GoForwardCommand
			{
				RelayCommand^ get();
			}

		internal:
			NavigationHelper(Windows::UI::Xaml::Controls::Page^ page,
				RelayCommand^ goBack = nullptr,
				RelayCommand^ goForward = nullptr);

			bool CanGoBack();
			void GoBack();
			bool CanGoForward();
			void GoForward();

			void OnNavigatedTo(Windows::UI::Xaml::Navigation::NavigationEventArgs^ e);
			void OnNavigatedFrom(Windows::UI::Xaml::Navigation::NavigationEventArgs^ e);

			event LoadStateEventHandler^ LoadState;
			event SaveStateEventHandler^ SaveState;

		private:
			Platform::WeakReference _page;

			RelayCommand^ _goBackCommand;
			RelayCommand^ _goForwardCommand;

#if WINAPI_FAMILY==WINAPI_FAMILY_PHONE_APP
			Windows::Foundation::EventRegistrationToken _backPressedEventToken;

			void HardwareButton_BackPressed(Platform::Object^ sender,
				Windows::Phone::UI::Input::BackPressedEventArgs^ e);
#else
			bool _navigationShortcutsRegistered;
			Windows::Foundation::EventRegistrationToken _acceleratorKeyEventToken;
			Windows::Foundation::EventRegistrationToken _pointerPressedEventToken;

			void CoreDispatcher_AcceleratorKeyActivated(Windows::UI::Core::CoreDispatcher^ sender,
				Windows::UI::Core::AcceleratorKeyEventArgs^ e);
			void CoreWindow_PointerPressed(Windows::UI::Core::CoreWindow^ sender,
				Windows::UI::Core::PointerEventArgs^ e);
#endif

			Platform::String^ _pageKey;
			Windows::Foundation::EventRegistrationToken _loadedEventToken;
			Windows::Foundation::EventRegistrationToken _unloadedEventToken;
			void OnLoaded(Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
			void OnUnloaded(Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);

			~NavigationHelper();
		};
	}
}
