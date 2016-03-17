//
// RelayCommand.cpp
// RelayCommand 和关联类的实现
//

#include "pch.h"
#include "RelayCommand.h"
#include "NavigationHelper.h"

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
using namespace Windows::UI::Xaml::Navigation;

/// <summary>
/// 确定此 <see cref="RelayCommand"/> 是否可在其当前状态下执行。
/// </summary>
/// <param name="parameter">
/// 命令使用的数据。如果不需要向命令传递数据，则可将此对象设置为 null。
/// </param>
/// <returns>如果可执行此命令，则返回 true；否则返回 false。</returns>
bool RelayCommand::CanExecute(Object^ parameter)
{
	return (_canExecuteCallback) (parameter);
}

/// <summary>
/// 对当前命令目标执行 <see cref="RelayCommand"/>。
/// </summary>
/// <param name="parameter">
/// 命令使用的数据。如果不需要向命令传递数据，则可将此对象设置为 null。
/// </param>
void RelayCommand::Execute(Object^ parameter)
{
	(_executeCallback) (parameter);
}

/// <summary>
/// 用于引发 <see cref="CanExecuteChanged"/> 事件的方法
/// 执行 <see cref="CanExecute"/> 的返回值
/// 方法已更改。
/// </summary>
void RelayCommand::RaiseCanExecuteChanged()
{
	CanExecuteChanged(this, nullptr);
}

/// <summary>
/// RelayCommand 类析构函数。
/// </summary>
RelayCommand::~RelayCommand()
{
	_canExecuteCallback = nullptr;
	_executeCallback = nullptr;
};

/// <summary>
/// 创建可始终执行的新命令。
/// </summary>
/// <param name="canExecuteCallback">执行状态逻辑。</param>
/// <param name="executeCallback">执行逻辑。</param>
RelayCommand::RelayCommand(std::function<bool(Platform::Object^)> canExecuteCallback,
	std::function<void(Platform::Object^)> executeCallback) :
	_canExecuteCallback(canExecuteCallback),
	_executeCallback(executeCallback)
	{
	}
