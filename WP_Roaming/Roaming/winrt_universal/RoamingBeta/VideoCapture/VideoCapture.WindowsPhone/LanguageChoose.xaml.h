//
// LanguageChoose.xaml.h
// LanguageChoose 类的声明
//

#pragma once

#include "LanguageChoose.g.h"
#include "AppMain.h"
#include "Common\NavigationHelper.h"

namespace VideoCapture
{
	/// <summary>
	/// 基本页，提供大多数应用程序通用的特性。
	/// </summary>
	[Windows::Foundation::Metadata::WebHostHidden]
	public ref class LanguageChoose sealed
	{
	public:
		LanguageChoose();

		/// <summary>
		/// 获取此 <see cref="Page"/> 的视图模型。
		/// 可将其更改为强类型视图模型。
		/// </summary>
		property Windows::Foundation::Collections::IObservableMap<Platform::String^, Platform::Object^>^ DefaultViewModel
		{
			Windows::Foundation::Collections::IObservableMap<Platform::String^, Platform::Object^>^  get();
		}

		/// <summary>
		/// 获取与此 <see cref="Page"/> 关联的 <see cref="NavigationHelper"/>。
		/// </summary>
		property Common::NavigationHelper^ NavigationHelper
		{
			Common::NavigationHelper^ get();
		}

	protected:
		virtual void OnNavigatedTo(Windows::UI::Xaml::Navigation::NavigationEventArgs^ e) override;
		virtual void OnNavigatedFrom(Windows::UI::Xaml::Navigation::NavigationEventArgs^ e) override;

	private:
		void LoadState(Platform::Object^ sender, Common::LoadStateEventArgs^ e);
		void SaveState(Platform::Object^ sender, Common::SaveStateEventArgs^ e);

		static Windows::UI::Xaml::DependencyProperty^ _defaultViewModelProperty;
		static Windows::UI::Xaml::DependencyProperty^ _navigationHelperProperty;
		/// <summary>
		/// 选择中文语言，进入主界面
		/// </summary>
		void LAN_CHINESE_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
		{
			//this->Frame->Navigate(MainPage::typeid, NULL);
		}
	};

}
