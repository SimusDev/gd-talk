extends Node
class_name C_Chat

var _messages: Array[R_ChatMessage] = []
var _messages_count: int = 0

var _connected_peers: PackedInt32Array = []

signal on_user_connected(user: C_User)
signal on_user_disconnected(user: C_User)

signal on_synchronized(message_count: int)
signal on_message_synchronized(id: int, message: R_ChatMessage)

signal on_message_recieve(id: int)

var is_connected: bool = false

var _voice: C_VoiceChannel

func get_voice_channel() -> C_VoiceChannel:
	return

func get_message_count() -> int:
	return _messages_count

func get_connected_peers() -> PackedInt32Array:
	return _connected_peers

func _ready() -> void:
	set_multiplayer_authority(SimusNet.SERVER_ID)
	SimusNetVisibility.set_public_visibility(self, false)
	SimusNetVisibility.set_method_always_visible([
		_request_connect_or_disconnect,
		])
	
	SimusNetRPCGodot.register_any_peer_reliable([
		_request_connect_or_disconnect,
		_send,
		_send_message_on_server,
		_server_sync_message,
		
	], GDTalk.CHANNELS.CHAT)
	
	SimusNetRPCGodot.register_authority_reliable([
		_recieve,
		_recive_connect_or_disconnect,
		_server_broadcast_message,
		_client_sync_message,
		
	], GDTalk.CHANNELS.CHAT)

func synchronize() -> void:
	if !SimusNetConnection.is_server():
		_messages.clear()
		_messages_count = 0
	
	SimusNetRPCGodot.invoke_on_server(_send)

func _send() -> void:
	if _messages.is_empty():
		return
	
	SimusNetRPCGodot.invoke_on(multiplayer.get_remote_sender_id(), _recieve, _messages.size())

func _recieve(messages_count: int) -> void:
	_messages_count = messages_count
	on_synchronized.emit()
	

func _connect_peer(peer: int) -> void:
	if _connected_peers.has(peer):
		return
	
	SimusNetVisibility.set_visible_for(peer, self, true)
	var user: C_User = C_User.find_by_peer_id(peer)
	if user.is_local():
		is_connected = true
	on_user_connected.emit(user)
	_connected_peers.append(peer)

func _disconnect_peer(peer: int) -> void:
	if !_connected_peers.has(peer):
		return
	
	SimusNetVisibility.set_visible_for(peer, self, false)
	var user: C_User = C_User.find_by_peer_id(peer)
	if user.is_local():
		is_connected = false
	on_user_disconnected.emit(user)
	_connected_peers.erase(peer)

func request_connect() -> void:
	SimusNetRPCGodot.invoke_on_server(_request_connect_or_disconnect, false)

func request_disconnect() -> void:
	SimusNetRPCGodot.invoke_on_server(_request_connect_or_disconnect, true)

func _request_connect_or_disconnect(disconnect: bool) -> void:
	var peer: int = multiplayer.get_remote_sender_id()
	if disconnect:
		if _connected_peers.has(peer):
			_disconnect_peer(peer)
			SimusNetRPCGodot.invoke_on(peer, _recive_connect_or_disconnect, disconnect)
	else:
		if !_connected_peers.has(peer):
			_connect_peer(peer)
			SimusNetRPCGodot.invoke_on(peer, _recive_connect_or_disconnect, disconnect)

func _recive_connect_or_disconnect(disconnect: bool) -> void:
	if disconnect:
		_disconnect_peer(SimusNetConnection.get_unique_id())
	else:
		_connect_peer(SimusNetConnection.get_unique_id())

func send_message(msg: Variant) -> void:
	if !is_connected:
		return
	
	var message := R_ChatMessage.create(msg, C_User.get_local())
	SimusNetRPCGodot.invoke_on_server(_send_message_on_server, message.serialize())

func _send_message_on_server(msg: Variant) -> void:
	if SimusNetConnection.is_server():
		_messages.append(R_ChatMessage.deserialize(msg))
		SimusNetRPCGodot.invoke_all(_server_broadcast_message, _messages.size())
	

func _server_broadcast_message(msg_count: int) -> void:
	_messages_count = msg_count
	on_message_recieve.emit(msg_count - 1)

func synchronize_message(id: int) -> void:
	SimusNetRPCGodot.invoke_on_server(_server_sync_message, id)

func _server_sync_message(id: int) -> void:
	if _messages.size() >= id:
		var msg: R_ChatMessage = _messages.get(id)
		SimusNetRPCGodot.invoke_on(multiplayer.get_remote_sender_id(), _client_sync_message, msg.serialize(), id)

func _client_sync_message(message: Variant, id: int) -> void:
	var msg := R_ChatMessage.deserialize(message)
	on_message_synchronized.emit(id, msg)
	if !SimusNetConnection.is_server():
		_messages.append(msg)
