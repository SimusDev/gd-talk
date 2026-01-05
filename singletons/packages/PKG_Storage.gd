extends Node
class_name PKG_Storage

const AUTOSAVE_TIME: float = 60

var _autosave_timer: float = 0.0

static var _instance: PKG_Storage

const DATA_PATH: String = "user://server_data"

static var _datas: Dictionary[String, R_ServerData]

static func register_data(folder: String, file: String) -> R_ServerData:
	if !SimusNetConnection.is_server():
		SD_Console.i().write_error("client cant register R_ServerData! %s:%s" % [folder, file])
		return
	
	var folder_path: String = DATA_PATH.path_join(folder)
	SD_FileSystem.make_directory(folder_path)
	
	var filepath: String = SD_FileSystem.normalize_path(folder_path.path_join(file))
	filepath += ".tres"
	
	if _datas.has(filepath):
		return _datas.get(filepath)
	
	var loaded: Resource = ResourceLoader.load(filepath)
	if loaded:
		loaded.filepath = filepath
		_datas[filepath] = loaded
		return loaded
	
	var data := R_ServerData.new()
	data.filepath = filepath
	if SimusNetConnection.is_server():
		ResourceSaver.save(data, filepath)
	_datas[filepath] = data
	return data
	

func _ready() -> void:
	_instance = self
	SimusNetEvents.event_connected.published.connect(_connected)
	SimusNetEvents.event_disconnected.published.connect(_disconnected)
	set_process(false)

func _connected() -> void:
	set_process(SimusNetConnection.is_server())

func _disconnected() -> void:
	set_process(false)

func _process(delta: float) -> void:
	_autosave_timer = move_toward(_autosave_timer, AUTOSAVE_TIME, delta)
	if _autosave_timer >= AUTOSAVE_TIME:
		save_data()

func save_data() -> void:
	pass

func load_data() -> void:
	pass
