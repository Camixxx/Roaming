//
// RelayCommand.h
// RelayCommand 和关联类的声明
//

#pragma once

// <summary>
// 专门用于中继自身功能的命令
// 通过调用委托分配给其他对象。
//CanExecute 方法的默认返回值为“true”。
// 在下列情况中，始终需要调用 <see cref="RaiseCanExecuteChanged"/>
// <see cref="CanExecute"/> 应返回其他的值。
// </summary>


namespace VideoCapture
{
	namespace Common
	{
		[Windows::Foundation::Metadata::WebHostHidden]
		public ref class RelayCommand sealed :[Windows::Foundation::Metadata::Default] Windows::UI::Xaml::Input::ICommand
		{
		public:
			virtual event Windows::Foundation::EventHandler<Object^>^ CanExecuteChanged;
			virtual bool CanExecute(Object^ parameter);
			virtual void Execute(Object^ parameter);
			virtual ~RelayCommand();

		internal:
			RelayCommand(std::function<bool(Platform::Object^)> canExecuteCallback,
				std::function<void(Platform::Object^)> executeCallback);
			void RaiseCanExecuteChanged();

		private:
			std::function<bool(Platform::Object^)> _canExecuteCallback;
			std::function<void(Platform::Object^)> _executeCallback;
		};
	}
}