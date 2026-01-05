extends Control

@export var user_scene: PackedScene

@export var _container: Control

func _ready() -> void:
	for user in C_User.get_connected_as_list():
		_add(user)
	
	C_User.get_package().on_user_connected.connect(_add)

func _add(user: C_User) -> void:
	var scene: Node = user_scene.instantiate()
	scene.user = user
	_container.add_child(scene)
