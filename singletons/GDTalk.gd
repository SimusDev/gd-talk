extends Node

const settings: R_GDTalkSettings = preload("res://gdtalk.tres")
@export var pkg_storage: PKG_Storage
@export var pkg_server: PKG_Server
@export var pkg_auth: PKG_Auth
@export var pkg_microphone: PKG_Microphone
@export var pkg_users: PKG_Users

@export var global_chat: C_Chat

enum CHANNELS {
	AUTH = 32,
	VOICE,
	USERS,
	CHAT,
	INFO_NOTIFICATIONS
}

const SERVER_ID: int = 1

var _sync_steps: PackedStringArray = []

signal on_steps_all_synchronized()
signal on_step_synchronized(id: String)

func _ready() -> void:
	SimusNetEvents.event_disconnected.listen(_on_gdtalk_disconnect)

func _on_gdtalk_disconnect() -> void:
	_sync_steps.clear()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	SD_Console.i().write_error("SERVER TURNED OFF.")

func for_async_synchronize() -> void:
	if SimusNetConnection.is_server():
		return
	
	if !_sync_steps.is_empty():
		await on_steps_all_synchronized

func synchronize_add_step(id: String) -> void:
	if _sync_steps.has(id):
		return
	
	_sync_steps.append(id)

func synchronize_remove_step(id: String) -> void:
	if _sync_steps.has(id):
		_sync_steps.erase(id)
		on_step_synchronized.emit(id)
		SD_Console.i().write_success("step synchronized: %s" % id)
		if _sync_steps.is_empty():
			on_steps_all_synchronized.emit()
			SD_Console.i().write_success("all steps synchronized, gdtalk is ready.")
