//
// SuspensionManager.cpp
// SuspensionManager 类的实现
//

#include "pch.h"
#include "SuspensionManager.h"

#include <algorithm>

using namespace VideoCapture::Common;

using namespace concurrency;
using namespace Platform;
using namespace Platform::Collections;
using namespace Windows::Foundation;
using namespace Windows::Foundation::Collections;
using namespace Windows::Storage;
using namespace Windows::Storage::FileProperties;
using namespace Windows::Storage::Streams;
using namespace Windows::UI::Xaml;
using namespace Windows::UI::Xaml::Controls;
using namespace Windows::UI::Xaml::Interop;

Map<String^, Object^>^ SuspensionManager::_sessionState = ref new Map<String^, Object^>();

const wchar_t* SuspensionManager::sessionStateFilename = L"_sessionState.dat";

std::vector<WeakReference> SuspensionManager::_registeredFrames;

DependencyProperty^ SuspensionManager::FrameSessionStateKeyProperty = nullptr;
DependencyProperty^ SuspensionManager::FrameSessionBaseKeyProperty = nullptr;
DependencyProperty^ SuspensionManager::FrameSessionStateProperty = nullptr;

void SuspensionManager::RegisterDependencyProperties()
{
	if (FrameSessionStateProperty == nullptr)
	{
		FrameSessionStateProperty = DependencyProperty::RegisterAttached("_FrameSessionStateProperty",
			TypeName(IMap<String^, Object^>::typeid), TypeName(SuspensionManager::typeid), nullptr);
	}

	if (FrameSessionBaseKeyProperty == nullptr)
	{
		FrameSessionBaseKeyProperty = DependencyProperty::RegisterAttached("_FrameSessionBaseKeyProperty",
			TypeName(String::typeid), TypeName(SuspensionManager::typeid), nullptr);
	}

	if (FrameSessionStateKeyProperty == nullptr)
	{
		FrameSessionStateKeyProperty = DependencyProperty::RegisterAttached("_FrameSessionStateKeyProperty",
			TypeName(String::typeid), TypeName(SuspensionManager::typeid), nullptr);
	}
}

class ObjectSerializeHelper
{
public:
	// 用于识别序列化类型的代码
	enum StreamTypes {
		NullPtrType = 0,

		// 支持的 IPropertyValue 类型
		UInt8Type, UInt16Type, UInt32Type, UInt64Type, Int16Type, Int32Type, Int64Type,
		SingleType, DoubleType, BooleanType, Char16Type, GuidType, StringType,

		// 其他受支持类型
		StringToObjectMapType,

		// 用于确保数据流完整性的标记值
		MapEndMarker
	};
	static String^ ReadString(DataReader^ reader);
	static IMap<String^, Object^>^ ReadStringToObjectMap(DataReader^ reader);
	static Object^ ReadObject(DataReader^ reader);
	static void WriteString(DataWriter^ writer, String^ string);
	static void WriteProperty(DataWriter^ writer, IPropertyValue^ propertyValue);
	static void WriteStringToObjectMap(DataWriter^ writer, IMap<String^, Object^>^ map);
	static void WriteObject(DataWriter^ writer, Object^ object);
};

/// <summary>
/// 提供对当前会话的全局会话状态的访问。此状态由
/// <see cref="SaveAsync"/> 序列化并由 <see cref="RestoreAsync"/> 还原，这需要值为
/// 以下项之一:  包含整数的装箱值、浮点单精度值和双精度值、
/// 宽字符、布尔值、字符串和 GUID，或者映射值受相同约束制约的 Map<String^, Object^>。
/// 会话状态应尽可能紧凑。
/// </summary>
IMap<String^, Object^>^ SuspensionManager::SessionState()
{
	return _sessionState;
}

/// <summary>
/// 注册 <see cref="Frame"/> 实例以允许将其导航历史记录保存到
/// <see cref="SessionState"/> 并从中还原。  如果框架将参与会话状态管理，
/// 则应在创建框架后立即注册。  在
/// 注册时，如果已还原指定键的状态，
/// 则将立即还原导航历史记录。
/// <see cref="RestoreAsync(String)"/> 的后续调用也将还原导航历史记录。
/// </summary>
/// <param name="frame">其导航历史记录应由
/// <see cref="SuspensionManager"/></param>
/// <param name="sessionStateKey"><see cref="SessionState"/> 的唯一键，用于
/// 存储与导航相关的信息。</param>
/// <param name="sessionBaseKey">标识会话类型的可选密钥。
/// 这可用于区分多个应用程序启动方案。</param>
void SuspensionManager::RegisterFrame(Frame^ frame, String^ sessionStateKey, String^ sessionBaseKey)
{
	if (frame->GetValue(FrameSessionStateKeyProperty) != nullptr)
	{
		throw ref new FailureException("Frames can only be registered to one session state key");
	}

	if (frame->GetValue(FrameSessionStateProperty) != nullptr)
	{
		throw ref new FailureException("Frames must be either be registered before accessing frame session state, or not registered at all");
	}

	if (sessionBaseKey != nullptr)
	{
		frame->SetValue(FrameSessionBaseKeyProperty, sessionBaseKey);
		sessionStateKey = sessionBaseKey + "_" + sessionStateKey;
	}

	// 使用依赖项属性可会话键与框架相关联，并记录其
	// 导航状态应托管的框架
	frame->SetValue(FrameSessionStateKeyProperty, sessionStateKey);
	_registeredFrames.insert(_registeredFrames.begin(), WeakReference(frame));

	// 查看导航状态是否可还原
	RestoreFrameNavigationState(frame);
}

/// <summary>
/// 解除之前由 <see cref="RegisterFrame"/> 注册的 <see cref="Frame"/>
/// 与 <see cref="SessionState"/> 的关联。  之前捕获的任何导航状态都将
/// 移除。
/// </summary>
/// <param name="frame">其导航历史记录不应再
/// 托管的实例。</param>
void SuspensionManager::UnregisterFrame(Frame^ frame)
{
	// 移除会话状态并移除框架列表中其导航
	// 状态将被保存的框架(以及无法再访问的任何弱引用)
	auto key = safe_cast<String^>(frame->GetValue(FrameSessionStateKeyProperty));
	if (SessionState()->HasKey(key))
	{
		SessionState()->Remove(key);
	}
	_registeredFrames.erase(
		std::remove_if(_registeredFrames.begin(), _registeredFrames.end(), [=](WeakReference& e)
	{
		auto testFrame = e.Resolve<Frame>();
		return testFrame == nullptr || testFrame == frame;
	}),
		_registeredFrames.end()
		);
}

/// <summary>
/// 为与指定的 <see cref="Frame"/> 相关联的会话状态提供存储。
/// 之前已向 <see cref="RegisterFrame"/> 注册的框架已自动
/// 保存其会话状态且还原为全局
/// <see cref="SessionState"/> 的一部分。未注册的框架具有
/// 在还原已从导航缓存中丢弃的页面时仍然有用的
/// 导航缓存。
/// </summary>
/// <remarks>应用程序可能决定依靠 <see cref="NavigationHelper"/> 管理
/// 特定于页面的状态，而非直接使用框架会话状态。</remarks>
/// <param name="frame">需要会话状态的实例。</param>
/// <returns>状态集合受限于与
/// <see cref="SessionState"/> 相同的序列化机制。</returns>
IMap<String^, Object^>^ SuspensionManager::SessionStateForFrame(Frame^ frame)
{
	auto frameState = safe_cast<IMap<String^, Object^>^>(frame->GetValue(FrameSessionStateProperty));

	if (frameState == nullptr)
	{
		auto frameSessionKey = safe_cast<String^>(frame->GetValue(FrameSessionStateKeyProperty));
		if (frameSessionKey != nullptr)
		{
			// 已注册框架反映相应的会话状态
			if (!_sessionState->HasKey(frameSessionKey))
			{
				_sessionState->Insert(frameSessionKey, ref new Map<String^, Object^>());
			}
			frameState = safe_cast<IMap<String^, Object^>^>(_sessionState->Lookup(frameSessionKey));
		}
		else
		{
			// 未注册框架具有瞬时状态
			frameState = ref new Map<String^, Object^>();
		}
		frame->SetValue(FrameSessionStateProperty, frameState);
	}
	return frameState;
}

void SuspensionManager::RestoreFrameNavigationState(Frame^ frame)
{
	auto frameState = SessionStateForFrame(frame);
	if (frameState->HasKey("Navigation"))
	{
		frame->SetNavigationState(safe_cast<String^>(frameState->Lookup("Navigation")));
	}
}

void SuspensionManager::SaveFrameNavigationState(Frame^ frame)
{
	auto frameState = SessionStateForFrame(frame);
	frameState->Insert("Navigation", frame->GetNavigationState());
}

/// <summary>
/// 保存当前 <see cref="SessionState"/>。  任何 <see cref="Frame"/> 实例
/// (已向 <see cref="RegisterFrame"/> 注册)都还将保留其当前的
/// 导航堆栈，从而使其活动 <see cref="Page"/> 可以
/// 保存其状态。
/// </summary>
/// <returns>反映会话状态保存时间的异步任务。</returns>
task<void> SuspensionManager::SaveAsync(void)
{
	// 保存所有已注册框架的导航状态
	for (auto && weakFrame : _registeredFrames)
	{
		auto frame = weakFrame.Resolve<Frame>();
		if (frame != nullptr) SaveFrameNavigationState(frame);
	}

	// 以同步方式序列化会话状态以避免对共享
	// 状态的异步访问
	auto sessionData = ref new InMemoryRandomAccessStream();
	auto sessionDataWriter = ref new DataWriter(sessionData->GetOutputStreamAt(0));
	ObjectSerializeHelper::WriteObject(sessionDataWriter, _sessionState);

	// 以同步方式捕获会话状态之后，开始
	// 将结果写入磁盘的异步处理
	return task<unsigned int>(sessionDataWriter->StoreAsync()).then([=](unsigned int)
	{
		return ApplicationData::Current->LocalFolder->CreateFileAsync(StringReference(sessionStateFilename),
			CreationCollisionOption::ReplaceExisting);
	})
		.then([=](StorageFile^ createdFile)
	{
		return createdFile->OpenAsync(FileAccessMode::ReadWrite);
	})
		.then([=](IRandomAccessStream^ newStream)
	{
		return RandomAccessStream::CopyAsync(
			sessionData->GetInputStreamAt(0), newStream->GetOutputStreamAt(0));
	})
		.then([=](UINT64 copiedBytes)
	{
		(void) copiedBytes; // 未使用的参数
		return;
	});
}

/// <summary>
/// 还原之前保存的 <see cref="SessionState"/>。  任何 <see cref="Frame"/> 实例
/// (已向 <see cref="RegisterFrame"/> 注册)都还将还原其先前的导航
/// 状态，从而使其活动 <see cref="Page"/> 可以还原其
/// 状态。
/// </summary>
/// <param name="sessionBaseKey">标识会话类型的可选密钥。
/// 这可用于区分多个应用程序启动方案。</param>
/// <returns>反映何时读取会话状态的异步任务。
/// 在此任务完成之前，不应依赖 <see cref="SessionState"/>
/// 的内容。</returns>
task<void> SuspensionManager::RestoreAsync(String^ sessionBaseKey)
{
	_sessionState->Clear();

	task<StorageFile^> getFileTask(ApplicationData::Current->LocalFolder->GetFileAsync(StringReference(sessionStateFilename)));
	return getFileTask.then([=](StorageFile^ stateFile)
	{
		task<BasicProperties^> getBasicPropertiesTask(stateFile->GetBasicPropertiesAsync());
		return getBasicPropertiesTask.then([=](BasicProperties^ stateFileProperties)
		{
			auto size = unsigned int(stateFileProperties->Size);
			if (size != stateFileProperties->Size) throw ref new FailureException("Session state larger than 4GB");
			task<IRandomAccessStreamWithContentType^> openReadTask(stateFile->OpenReadAsync());
			return openReadTask.then([=](IRandomAccessStreamWithContentType^ stateFileStream)
			{
				auto stateReader = ref new DataReader(stateFileStream);
				return task<unsigned int>(stateReader->LoadAsync(size)).then([=](unsigned int bytesRead)
				{
					(void) bytesRead; // 未使用的参数
					// 反序列化会话状态
					Object^ content = ObjectSerializeHelper::ReadObject(stateReader);
					_sessionState = (Map<String^, Object^>^)content;

					// 将任何已注册框架还原为其已保存状态
					for (auto && weakFrame : _registeredFrames)
					{
						auto frame = weakFrame.Resolve<Frame>();
						if (frame != nullptr && safe_cast<String^>(frame->GetValue(FrameSessionBaseKeyProperty)) == sessionBaseKey)
						{
							frame->ClearValue(FrameSessionStateProperty);
							RestoreFrameNavigationState(frame);
						}
					}
				}, task_continuation_context::use_current());
			});
		});
	});
}

#pragma region Object serialization for a known set of types

void ObjectSerializeHelper::WriteString(DataWriter^ writer, String^ string)
{
	writer->WriteByte(StringType);
	writer->WriteUInt32(writer->MeasureString(string));
	writer->WriteString(string);
}

void ObjectSerializeHelper::WriteProperty(DataWriter^ writer, IPropertyValue^ propertyValue)
{
	switch (propertyValue->Type)
	{
	case PropertyType::UInt8:
		writer->WriteByte(StreamTypes::UInt8Type);
		writer->WriteByte(propertyValue->GetUInt8());
		return;
	case PropertyType::UInt16:
		writer->WriteByte(StreamTypes::UInt16Type);
		writer->WriteUInt16(propertyValue->GetUInt16());
		return;
	case PropertyType::UInt32:
		writer->WriteByte(StreamTypes::UInt32Type);
		writer->WriteUInt32(propertyValue->GetUInt32());
		return;
	case PropertyType::UInt64:
		writer->WriteByte(StreamTypes::UInt64Type);
		writer->WriteUInt64(propertyValue->GetUInt64());
		return;
	case PropertyType::Int16:
		writer->WriteByte(StreamTypes::Int16Type);
		writer->WriteUInt16(propertyValue->GetInt16());
		return;
	case PropertyType::Int32:
		writer->WriteByte(StreamTypes::Int32Type);
		writer->WriteUInt32(propertyValue->GetInt32());
		return;
	case PropertyType::Int64:
		writer->WriteByte(StreamTypes::Int64Type);
		writer->WriteUInt64(propertyValue->GetInt64());
		return;
	case PropertyType::Single:
		writer->WriteByte(StreamTypes::SingleType);
		writer->WriteSingle(propertyValue->GetSingle());
		return;
	case PropertyType::Double:
		writer->WriteByte(StreamTypes::DoubleType);
		writer->WriteDouble(propertyValue->GetDouble());
		return;
	case PropertyType::Boolean:
		writer->WriteByte(StreamTypes::BooleanType);
		writer->WriteBoolean(propertyValue->GetBoolean());
		return;
	case PropertyType::Char16:
		writer->WriteByte(StreamTypes::Char16Type);
		writer->WriteUInt16(propertyValue->GetChar16());
		return;
	case PropertyType::Guid:
		writer->WriteByte(StreamTypes::GuidType);
		writer->WriteGuid(propertyValue->GetGuid());
		return;
	case PropertyType::String:
		WriteString(writer, propertyValue->GetString());
		return;
	default:
		throw ref new InvalidArgumentException("Unsupported property type");
	}
}

void ObjectSerializeHelper::WriteStringToObjectMap(DataWriter^ writer, IMap<String^, Object^>^ map)
{
	writer->WriteByte(StringToObjectMapType);
	writer->WriteUInt32(map->Size);
	for (auto && pair : map)
	{
		WriteObject(writer, pair->Key);
		WriteObject(writer, pair->Value);
	}
	writer->WriteByte(MapEndMarker);
}

void ObjectSerializeHelper::WriteObject(DataWriter^ writer, Object^ object)
{
	if (object == nullptr)
	{
		writer->WriteByte(NullPtrType);
		return;
	}

	auto propertyObject = dynamic_cast<IPropertyValue^>(object);
	if (propertyObject != nullptr)
	{
		WriteProperty(writer, propertyObject);
		return;
	}

	auto mapObject = dynamic_cast<IMap<String^, Object^>^>(object);
	if (mapObject != nullptr)
	{
		WriteStringToObjectMap(writer, mapObject);
		return;
	}

	throw ref new InvalidArgumentException("Unsupported data type");
}

String^ ObjectSerializeHelper::ReadString(DataReader^ reader)
{
	int length = reader->ReadUInt32();
	String^ string = reader->ReadString(length);
	return string;
}

IMap<String^, Object^>^ ObjectSerializeHelper::ReadStringToObjectMap(DataReader^ reader)
{
	auto map = ref new Map<String^, Object^>();
	auto size = reader->ReadUInt32();
	for (unsigned int index = 0; index < size; index++)
	{
		auto key = safe_cast<String^>(ReadObject(reader));
		auto value = ReadObject(reader);
		map->Insert(key, value);
	}
	if (reader->ReadByte() != StreamTypes::MapEndMarker)
	{
		throw ref new InvalidArgumentException("Invalid stream");
	}
	return map;
}

Object^ ObjectSerializeHelper::ReadObject(DataReader^ reader)
{
	auto type = reader->ReadByte();
	switch (type)
	{
	case StreamTypes::NullPtrType:
		return nullptr;
	case StreamTypes::UInt8Type:
		return reader->ReadByte();
	case StreamTypes::UInt16Type:
		return reader->ReadUInt16();
	case StreamTypes::UInt32Type:
		return reader->ReadUInt32();
	case StreamTypes::UInt64Type:
		return reader->ReadUInt64();
	case StreamTypes::Int16Type:
		return reader->ReadInt16();
	case StreamTypes::Int32Type:
		return reader->ReadInt32();
	case StreamTypes::Int64Type:
		return reader->ReadInt64();
	case StreamTypes::SingleType:
		return reader->ReadSingle();
	case StreamTypes::DoubleType:
		return reader->ReadDouble();
	case StreamTypes::BooleanType:
		return reader->ReadBoolean();
	case StreamTypes::Char16Type:
		return (char16_t) reader->ReadUInt16();
	case StreamTypes::GuidType:
		return reader->ReadGuid();
	case StreamTypes::StringType:
		return ReadString(reader);
	case StreamTypes::StringToObjectMapType:
		return ReadStringToObjectMap(reader);
	default:
		throw ref new InvalidArgumentException("Unsupported property type");
	}
}

#pragma endregion
