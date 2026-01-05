extends PKG
class_name PKG_Server

func try_host(dedicated: bool = false) -> void:
	SimusNetConnection.set_dedicated_server(dedicated)
	SimusNetConnectionENet.create_server(
		GDTalk.settings.main_server_port,
		GDTalk.settings.main_server_max_clients
	)
	
	if dedicated:
		get_tree().change_scene_to_file.call_deferred("res://scenes/dedicated_server.tscn")

func _initialized() -> void:
	if OS.has_feature("dedicated_server"):
		try_host(true)

func try_connect_to_main() -> void:
	SimusNetConnectionENet.create_client(
		GDTalk.settings.main_server_ip,
		GDTalk.settings.main_server_port
		)

func try_connect_to(ip: String) -> void:
	SD_Console.i().write("connecting... %s:%s" % [ip, GDTalk.settings.main_server_port])
	SimusNetConnectionENet.create_client(
		ip,
		GDTalk.settings.main_server_port
		)
