extends PKG
class_name PKG_Users

signal on_user_connected(user: C_User)
signal on_user_disconnected(user: C_User)

var _connected: Dictionary[int, C_User] = {}

static var _instance: PKG_Users

static func get_connected_count() -> int:
	return _instance._connected.size()

static func get_connected() -> Dictionary[int, C_User]:
	return _instance._connected.duplicate()

static func get_connected_as_list() -> Array[C_User]:
	return _instance._connected.values().duplicate()

func _initialized() -> void:
	_instance = self
	
	SimusNetRPCGodot.register_any_peer_reliable([_server_send], GDTalk.CHANNELS.USERS)
	SimusNetRPCGodot.register_authority_reliable([_recieve_from_server], GDTalk.CHANNELS.USERS)
	
	SimusNetRPCGodot.register_authority_reliable([_receive_user], GDTalk.CHANNELS.USERS)
	
	GDTalk.pkg_auth.on_server_login.connect(_on_server_login)
	SimusNetEvents.event_peer_disconnected.listen(_on_peer_disconnected, true)

func _on_peer_disconnected(event: SimusNetEvent) -> void:
	var founded: C_User = _connected.get(event.get_arguments())
	if is_instance_valid(founded):
		_disconnect_user(founded)

func _on_server_login(peer: int, login: String, password: String) -> void:
	if SimusNetConnection.is_server():
		var server_user: C_User = C_User.server_create(peer, login, password)
		
		if peer == SimusNetConnection.SERVER_ID:
			server_user._add_right_rpc("admin")
		
		_connect_user(server_user)
		SimusNetRPCGodot.invoke(_receive_user, server_user.serialize())

func _receive_user(serialized: Variant) -> void:
	var user: C_User = C_User.deserialize(serialized)
	_connect_user(user)

func _server_send() -> void:
	var users: Array = []
	for user: C_User in _connected.values():
		users.append(user.serialize())
	
	SimusNetRPCGodot.invoke_on(multiplayer.get_remote_sender_id(), 
	_recieve_from_server, 
	SimusNetCompressor.parse_gzip(users)
	)

func _recieve_from_server(users_bytes: PackedByteArray) -> void:
	var users: Array = SimusNetDecompressor.parse_gzip(users_bytes)
	for serialized_user in users:
		var user: C_User = C_User.deserialize(serialized_user)
		_connect_user(user)
	
	GDTalk.synchronize_remove_step("users")

func _connect_user(user: C_User) -> void:
	_connected[user.get_peer_id()] = user
	add_child(user)
	on_user_connected.emit(user)
	user.on_connected.emit()
	SD_Console.i().write_info("[is_server: %s] %s connected." % [SimusNetConnection.is_server(), user.login])

func _disconnect_user(user: C_User) -> void:
	on_user_disconnected.emit(user)
	_connected.erase(user.get_peer_id())
	user.on_disconnected.emit()
	user.queue_free()
	SD_Console.i().write_info("[is_server: %s] %s disconnected." % [SimusNetConnection.is_server(), user.login])

func _on_gdtalk_connected() -> void:
	GDTalk.synchronize_add_step("users")
	
	if !SimusNetConnection.is_server():
		SimusNetRPCGodot.invoke_on_server(_server_send)

func _on_gdtalk_disconnected() -> void:
	GDTalk.synchronize_remove_step("users")
