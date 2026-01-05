extends Resource
class_name R_ServerData

@export var storage: Dictionary = {}

var filepath: String

static func register(folder: String, file: String) -> R_ServerData:
	return PKG_Storage.register_data(folder, file)

func save() -> R_ServerData:
	if filepath:
		ResourceSaver.save(self, filepath)
	else:
		SD_Console.i().write_error("failed to save R_ServerData (%s), filepath is empty." % self)
	return self
