extends Node
class_name C_User

var _peer: int = -1

var login: String = ""

var _data: R_ServerData = null

var _rights: PackedStringArray = []
var _avatar: Texture

const AVATAR_MAX_SIZE = Vector2i(512, 512)

signal on_rights_updated()
signal on_avatar_changed()
signal on_avatar_error(error: String)

signal on_connected()
signal on_disconnected()

func get_login_richtext() -> String:
	if !get_rights().is_empty():
		return "%s %s" % [get_rights(), login]
	return login

static var _local: C_User

static func get_package() -> PKG_Users:
	return GDTalk.pkg_users

static func get_connected_as_list() -> Array[C_User]:
	return get_package().get_connected_as_list()

static func find_by_peer_id(id: int) -> C_User:
	return get_package().get_connected().get(id)

static func find_by_login(_login: String) -> C_User:
	for i in get_package().get_connected_as_list():
		if i.login == _login:
			return i
	return null

static func get_local() -> C_User:
	return _local

func is_local() -> bool:
	return _local == self

func _ready() -> void:
	set_multiplayer_authority(_peer)
	
	if _peer == SimusNetConnection.get_unique_id():
		_local = self
	
	SimusNetRPCGodot.register_authority_reliable([
		_add_right_rpc,
		_remove_right_rpc,
		_add_right_server,
		_remove_right_server,
	],
	GDTalk.CHANNELS.USERS
	)
	
	SimusNetRPCGodot.register_any_peer_reliable([
		_set_avatar_rpc,
	],
	GDTalk.CHANNELS.USERS
	)
	
	if not SimusNetConnection.is_server():
		if _avatar:
			register_avatar_data_client(login).storage.avatar = SD_Variables.compress_gzip(SimusNetSerializer.parse_image(_avatar.get_image()))

func get_avatar() -> Texture:
	return _avatar

func set_avatar(new: Image) -> void:
	if !is_local():
		return
	
	if new.get_size() > AVATAR_MAX_SIZE:
		_avatar_error("error.image_size_too_big")
		SD_Console.i().write_error("error.image_size_too_big")
		return
	
	SimusNetRPCGodot.invoke_all(_set_avatar_rpc, SimusNetSerializer.parse_image(new))

func _set_avatar_rpc(image: Variant) -> void:
	var avatar_image: Image = SimusNetDeserializer.parse_image(image)
	
	_avatar = ImageTexture.create_from_image(avatar_image)
	on_avatar_changed.emit()
	
	if SimusNetConnection.is_server():
		if _avatar:
			register_avatar_data(login).storage.avatar = SimusNetSerializer.parse_image(_avatar.get_image())
		
		register_avatar_data(login).save()
	else:
		if _avatar:
			register_avatar_data_client(login).storage.avatar = SD_Variables.compress_gzip(SimusNetSerializer.parse_image(_avatar.get_image()))
		
		register_avatar_data_client(login).save()

func _avatar_error(error: String) -> void:
	on_avatar_error.emit(error)

func is_admin() -> bool:
	return _rights.has("admin")

func get_rights() -> PackedStringArray:
	return _rights.duplicate()

func has_right(id: String) -> bool:
	return _rights.has(id)

func add_right(id: String) -> void:
	SimusNetRPCGodot.invoke_on_server(_add_right_rpc, id)

func _add_right_server(id: String) -> void:
	if SimusNetConnection.is_server() or is_admin():
		if _rights.has(id):
			return
		
		SimusNetRPCGodot.invoke_all(_add_right_rpc, id)

func _add_right_rpc(id: String) -> void:
	if _rights.has(id):
		return
	
	_rights.append(id)
	on_rights_updated.emit()

func remove_right(id: String) -> void:
	SimusNetRPCGodot.invoke_on_server(_remove_right_server, id)

func _remove_right_server(id: String) -> void:
	if SimusNetConnection.is_server() or is_admin():
		if !_rights.has(id):
			return
		
		SimusNetRPCGodot.invoke_all(_remove_right_rpc, id)

func _remove_right_rpc(id: String) -> void:
	_rights.erase(id)
	on_rights_updated.emit()

func get_data() -> R_ServerData:
	return _data

func get_storage() -> Dictionary:
	if _data:
		return _data.storage
	return {}

func get_peer_id() -> int:
	return _peer

func get_password() -> String:
	return _data.storage.password

func serialize() -> Dictionary:
	var result: Dictionary = {}
	result.peer = _peer
	result.login = login
	result.rights = _rights
	if _avatar:
		result.avatar = SimusNetSerializer.parse_image(_avatar.get_image())
	return result

static func deserialize(data: Dictionary) -> C_User:
	var user := C_User.new()
	user.name = str(data.peer)
	user._peer = data.peer
	user.login = data.login
	user._rights = data.rights
	if data.has("avatar"):
		user._set_avatar_rpc(data.avatar)
	return user

static func server_create(peer: int, _login: String, password: String) -> C_User:
	var data := register_server_data(_login)
	var user := C_User.new()
	user._data = data
	user.name = str(peer)
	user._peer = peer
	user.login = _login
	data.storage.password = password
	user._rights = data.storage.get_or_add("rights", PackedStringArray())
	
	var avatar: R_ServerData = register_avatar_data(_login)
	
	if avatar.storage.has("avatar"):
		user._set_avatar_rpc(avatar.storage.avatar)
	
	data.save()
	return user

static func register_server_data(_login: String) -> R_ServerData:
	return R_ServerData.register("users", _login)

static func register_avatar_data(_login: String) -> R_ServerData:
	return R_ServerData.register("avatars", _login)

static func register_avatar_data_client(_login: String) -> R_ClientData:
	return R_ClientData.register("avatars", _login)

static func get_user_avatar(_login: String) -> ImageTexture:
	var user: C_User = C_User.find_by_login(_login)
	if user:
		return user.get_avatar()
	
	var founded: Variant = register_avatar_data_client(_login).storage.get("avatar", null)
	if founded != null:
		founded = SD_Variables.decompress_gzip(founded)
		founded = SimusNetDeserializer.parse_image(founded)
		founded = ImageTexture.create_from_image(founded)
	return founded
