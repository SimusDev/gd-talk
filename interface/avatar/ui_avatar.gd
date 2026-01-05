extends Control
class_name UI_Avatar

@export var user: C_User : set = set_user

@onready var _icon: TextureRect = $_icon

func set_user(new: C_User) -> void:
	if is_instance_valid(user):
		user.on_avatar_changed.disconnect(_changed)
	
	user = new
	if !is_node_ready():
		await ready
	
	if is_instance_valid(user):
		user.on_avatar_changed.connect(_changed)
	_changed()

func get_scene() -> PackedScene:
	return load("uid://iv1pt2snl3c")

func _ready() -> void:
	if not user:
		user = C_User.get_local()
	

func _changed() -> void:
	if is_instance_valid(user):
		_icon.texture = user.get_avatar()
		$star.visible = user.is_admin()
	else:
		_icon.texture = null
		$star.visible = false
		
