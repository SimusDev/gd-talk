extends Control
class_name UI_Avatar

@export var user: C_User : set = set_user

@onready var _icon: TextureRect = $_icon

var msg:R_ChatMessage = null

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
	_changed()

func _changed() -> void:
	$star.visible = false
	
	if is_instance_valid(user):
		_icon.texture = user.get_avatar()
		$star.visible = user.is_admin()

func set_texture(texture: Texture) -> void:
	if !is_node_ready():
		await ready
	_icon.texture = texture
