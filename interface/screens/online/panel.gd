extends Button

var user: C_User

func _ready() -> void:
	$ui_avatar.user = user
	$SD_RichTextLabelSimple.text = user.get_login_richtext()
	user.on_disconnected.connect(queue_free)
