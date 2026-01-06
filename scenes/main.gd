extends Control

@export var _ip: LineEdit

func _ready() -> void:
	#get_tree().root.position = DisplayServer.screen_get_size(DisplayServer.get_primary_screen()) / 2
	#get_tree().root.size = Vector2i(640, 480)
	#get_tree().root.position -= Vector2i(640, 480) / 2
	#SimusNetEvents.event_connected.published.connect(_start)
	pass

func _start() -> void:
	#await GDTalk.for_async_synchronize()
	#if not SimusNetConnection.is_dedicated_server():
		#get_tree().change_scene_to_file.call_deferred("res://scenes/auth.tscn")
	pass

func _on__create_server_pressed() -> void:
	GDTalk.pkg_server.try_host()

func _on__connect_pressed() -> void:
	GDTalk.pkg_server.try_connect_to(_ip.text)

func _on__connect_to_main_pressed() -> void:
	GDTalk.pkg_server.try_connect_to_main()
