extends Node
class_name C_Chat

var _messages: Array[R_ChatMessage] = []

var _connected_peers: PackedInt32Array = []

signal on_peer_connected()
signal on_peer_disconnected()

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
		
	], GDTalk.CHANNELS.CHAT)
	
	SimusNetRPCGodot.register_authority_reliable([
		_recieve,
		_recive_connect_or_disconnect,
		
	], GDTalk.CHANNELS.CHAT)

func synchronize() -> void:
	SimusNetRPCGodot.invoke_on_server(_send)

func _send() -> void:
	if _messages.is_empty():
		return
	
	SimusNetRPCGodot.invoke_on(multiplayer.get_remote_sender_id(), _recieve, R_ChatMessage.serialize_array(_messages))

func _recieve(bytes: PackedByteArray) -> void:
	_messages = R_ChatMessage.deserialize_array(bytes)

func _connect_peer(peer: int) -> void:
	on_peer_connected.emit(peer)

func _disconnect_peer(peer: int) -> void:
	on_peer_disconnected.emit(peer)

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
