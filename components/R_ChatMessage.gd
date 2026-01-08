extends Resource
class_name R_ChatMessage

var type: int = TYPE.STRING

enum TYPE {
	STRING,
	IMAGE,
}

const _INTERFACES: Dictionary[int, PackedScene] = {
	TYPE.STRING : null,
	TYPE.IMAGE : null,
}

var sender: String = ""
var data: Variant
var time: String = "00:00"

var _interface: PackedScene

func get_interface() -> PackedScene:
	return _interface

static func create(from: Variant, user: C_User = null) -> R_ChatMessage:
	var message := R_ChatMessage.new()
	if user:
		message.sender = user.login
	
	var m_type: int = TYPE.STRING
	
	if from is Image:
		m_type = TYPE.IMAGE
		message.data = SimusNetSerializer.parse_image(from)
	else:
		message.data = str(from)
	
	message._interface = _INTERFACES.get(m_type)
	message.time = "%s:%s" % [
		Time.get_datetime_dict_from_system()["hour"],
		Time.get_datetime_dict_from_system()["minute"]
		]
	
	return message

func serialize() -> PackedByteArray:
	var result: Array = []
	result.append_array([
		type,
		data,
		sender,
	])
	
	return SimusNetCompressor.parse(result)

static func deserialize(bytes: PackedByteArray) -> R_ChatMessage:
	var _data: Array = SimusNetDecompressor.parse(bytes)
	var message := R_ChatMessage.new()
	message.type = _data[0]
	message._interface = _INTERFACES.get(message.type)
	message.data = _data[1]
	message.sender = _data[2]
	return message

static func serialize_array(array: Array[R_ChatMessage]) -> PackedByteArray:
	var result: Array = []
	for i in array:
		result.append(i.serialize())
	return SimusNetCompressor.parse_gzip(result)

static func deserialize_array(array: PackedByteArray) -> Array[R_ChatMessage]:
	var serialized: Array = SimusNetDecompressor.parse_gzip(array)
	var result: Array[R_ChatMessage] = []
	for i in serialized:
		result.append(deserialize(i))
	return result
