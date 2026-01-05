extends Node

func _ready() -> void:
	SD_Console.i().write_warning("Dedicated Server Started, port: %s" % GDTalk.settings.main_server_port)
	
