extends Node
class_name C_VoiceChannel

var _chat: C_Chat

func register(chat: C_Chat) -> void:
	_chat = chat
	_chat.on_user_connected.connect(_on_user_connected)
	_chat.on_user_disconnected.connect(_on_user_disconnected)

func _ready() -> void:
	set_physics_process(false)

func _on_user_connected(user: C_User) -> void:
	if user.is_local():
		set_physics_process(true)

func _on_user_disconnected(user: C_User) -> void:
	if user.is_local():
		set_physics_process(false)
