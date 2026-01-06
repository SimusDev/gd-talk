extends Resource
class_name R_ClientData

@export var storage: Dictionary = {}

var filepath: String

static func register(folder: String, file: String) -> R_ClientData:
	return PKG_Storage.register_data_client(folder, file)

func save() -> R_ClientData:
	if filepath:
		ResourceSaver.save(self, filepath)
	else:
		SD_Console.i().write_error("failed to save R_ClientData (%s), filepath is empty." % self)
	return self
