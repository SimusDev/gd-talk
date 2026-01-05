extends Node
class_name PKG

func _ready() -> void:
	await get_parent().ready
	SimusNetEvents.event_connected.listen(_on_gdtalk_connected)
	SimusNetEvents.event_disconnected.listen(_on_gdtalk_disconnected)
	
	_initialized()

func _initialized() -> void:
	pass

func _on_gdtalk_connected() -> void:
	pass

func _on_gdtalk_disconnected() -> void:
	pass
