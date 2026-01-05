extends Control

var reference: C_Chat : set = set_reference

@export var _container: Control

func _ready() -> void:
	if !reference:
		reference = GDTalk.global_chat

func _on_c_i_visibility_listener_on_changed(visibility: bool) -> void:
	if !is_instance_valid(reference):
		return
	
	if visibility:
		reference.request_connect()
	else:
		reference.request_disconnect()

func set_reference(chat: C_Chat) -> void:
	if is_instance_valid(reference):
		reference.on_user_connected.disconnect(_on_user_connected)
		reference.on_user_disconnected.connect(_on_user_disconnected)
		reference.on_synchronized.disconnect(_on_synchronized)
		reference.on_message_recieve.disconnect(_on_message_recieve)
	
	reference = chat
	
	if !is_node_ready():
		await ready
	
	reference.on_user_connected.connect(_on_user_connected)
	reference.on_user_disconnected.connect(_on_user_disconnected)
	reference.on_synchronized.connect(_on_synchronized)
	reference.on_message_recieve.connect(_on_message_recieve)

func _on_synchronized() -> void:
	SD_Nodes.async_clear_all_children(_container)
	for id in reference.get_message_count():
		_on_message_recieve(id)

func _on_user_connected(user: C_User) -> void:
	if user.is_local():
		reference.synchronize()

func _on_user_disconnected(user: C_User) -> void:
	if user.is_local():
		SD_Nodes.async_clear_all_children(_container)

func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text.is_empty():
		return
	
	$LineEdit.text = ""
	reference.send_message(new_text)

func _on_message_recieve(id: int) -> void:
	var ui: UI_ChatMessage = UI_ChatMessage.get_scene().instantiate()
	ui.id = id
	ui.chat = reference
	_container.add_child(ui)
