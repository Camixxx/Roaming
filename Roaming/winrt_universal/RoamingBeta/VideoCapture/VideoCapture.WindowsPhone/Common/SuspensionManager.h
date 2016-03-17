//
// SuspensionManager.h
// SuspensionManager 类的声明
//

#pragma once

namespace VideoCapture
{
	namespace Common
	{
		/// <summary>
		/// SuspensionManager 捕获全局会话状态以简化应用程序的
		/// 进程生命期管理。请注意会话状态在许多条件下将自动清除，
		/// 因此应该只用于存储方便
		/// 在会话之间传递但在应用程序崩溃或
		/// 已升级。
		/// </summary>
		class SuspensionManager sealed
		{
		public:
			static void RegisterDependencyProperties();
			static void RegisterFrame(Windows::UI::Xaml::Controls::Frame^ frame, Platform::String^ sessionStateKey, Platform::String^ sessionBaseKey = nullptr);
			static void UnregisterFrame(Windows::UI::Xaml::Controls::Frame^ frame);
			static concurrency::task<void> SaveAsync();
			static concurrency::task<void> RestoreAsync(Platform::String^ sessionBaseKey = nullptr);
			static Windows::Foundation::Collections::IMap<Platform::String^, Platform::Object^>^ SessionState();
			static Windows::Foundation::Collections::IMap<Platform::String^, Platform::Object^>^ SessionStateForFrame(
				Windows::UI::Xaml::Controls::Frame^ frame);

		private:
			static void RestoreFrameNavigationState(Windows::UI::Xaml::Controls::Frame^ frame);
			static void SaveFrameNavigationState(Windows::UI::Xaml::Controls::Frame^ frame);

			static Platform::Collections::Map<Platform::String^, Platform::Object^>^ _sessionState;
			static const wchar_t* sessionStateFilename;

			static std::vector<Platform::WeakReference> _registeredFrames;
			static Windows::UI::Xaml::DependencyProperty^ FrameSessionStateKeyProperty;
			static Windows::UI::Xaml::DependencyProperty^ FrameSessionBaseKeyProperty;
			static Windows::UI::Xaml::DependencyProperty^ FrameSessionStateProperty;
		};
	}
}
