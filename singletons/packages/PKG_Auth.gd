extends PKG
class_name PKG_Auth

signal on_success()
signal on_error(error: String)

signal on_server_login(peer: int, login: String, password: String)

@onready var _cmd_login: SD_ConsoleCommand = SD_ConsoleCommand.get_or_create("gdtalk.login", "user")
@onready var _cmd_password: SD_ConsoleCommand = SD_ConsoleCommand.get_or_create("gdtalk.password", "")

func get_last_login() -> String:
	return _cmd_login.get_value_as_string()

func get_last_password() -> String:
	return _cmd_password.get_value_as_string()

func _initialized() -> void:
	SimusNetRPCGodot.register([
		_request_rpc,
	],
	MultiplayerAPI.RPC_MODE_ANY_PEER, 
	MultiplayerPeer.TRANSFER_MODE_RELIABLE,
	GDTalk.CHANNELS.AUTH
	)
	
	SimusNetRPCGodot.register([
		_send_error,
		_send_success,
	],
	MultiplayerAPI.RPC_MODE_AUTHORITY, 
	MultiplayerPeer.TRANSFER_MODE_RELIABLE,
	GDTalk.CHANNELS.AUTH
	)
	

func request(login: String, password: String) -> void:
	_cmd_login.set_value(login)
	_cmd_password.set_value(password)
	SimusNetRPCGodot.invoke_on_server(_request_rpc, login, password)

func _request_rpc(login: String, password: String) -> void:
	var sender: int = multiplayer.get_remote_sender_id()
	
	if login.is_empty():
		SimusNetRPCGodot.invoke_on(sender, _send_error, "error.login_empty")
		return
	
	if password.is_empty():
		SimusNetRPCGodot.invoke_on(sender, _send_error, "error.password_empty")
		return
	
	for user in PKG_Users.get_connected_as_list():
		if user.login == login:
			SimusNetRPCGodot.invoke_on(sender, _send_error, "error.user_already_active")
			return
	
	var data: R_ServerData = C_User.register_server_data(login)
	var data_password: String = data.storage.get("password", "")
	
	if !data_password.is_empty():
		if data_password != password:
			SimusNetRPCGodot.invoke_on(sender, _send_error, "error.wrong_password")
			return
	
	on_server_login.emit(sender, login, password)
	SimusNetRPCGodot.invoke_on(sender, _send_success)
	

func _send_error(error: String) -> void:
	on_error.emit(error)

func _send_success() -> void:
	on_success.emit()
