extends Control

@export var _login: LineEdit
@export var _password: LineEdit

@export var _message: SD_Label

func _ready() -> void:
	GDTalk.pkg_auth.on_error.connect(_on_error)
	GDTalk.pkg_auth.on_success.connect(_on_success)
	
	_login.text = GDTalk.pkg_auth.get_last_login()
	_password.text = GDTalk.pkg_auth.get_last_password()

func _on_error(err: String) -> void:
	_message.self_modulate = Color.RED
	_message.localization_key = err

func _on_success() -> void:
	get_tree().change_scene_to_file("res://scenes/app.tscn")

func _on__enter_pressed() -> void:
	GDTalk.pkg_auth.request(_login.text, _password.text)

func _on_avatar_button_pressed() -> void:
	$AvatarFileDialog.popup()
