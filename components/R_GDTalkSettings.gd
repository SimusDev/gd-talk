extends Resource
class_name R_GDTalkSettings

@export_group("Main Server", "main_server")
@export var main_server_ip: String = "localhost"
@export var main_server_port: int = 8080
@export var main_server_max_clients: int = 100

@export_group("App")
@export var app_screens: Dictionary[StringName, PackedScene] = {}
