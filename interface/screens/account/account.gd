extends Control

@export var user: C_User : set = set_user

@export var _ui_avatar: UI_Avatar

func set_user(new: C_User) -> void:
	user = new
	if is_instance_valid(user):
		if !is_node_ready():
			await ready
			_update()
			

func _ready() -> void:
	if !user:
		user = C_User.get_local()
	
	_update()

func _update() -> void:
	_ui_avatar.user = user
	%LoginLabel.text = user.get_login_richtext()

func _on_avatar_pressed() -> void:
	$AvatarFileDialog.popup()

func _on_avatar_file_dialog_on_image_selected(image: Image) -> void:
	C_User.get_local().set_avatar(image)
