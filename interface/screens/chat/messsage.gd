extends Panel
class_name UI_ChatMessage

@export var chat: C_Chat
@export var id: int = -1

@onready var ui_loading_animation: UI_LoadingAnimation = $UiLoadingAnimation

var resource: R_ChatMessage

static func get_scene() -> PackedScene:
	return load("res://interface/screens/chat/messsage.tscn")

func _ready() -> void:
	chat.on_message_synchronized.connect(_on_sync)
	chat.synchronize_message(id)

func _on_sync(_id: int, msg: R_ChatMessage) -> void:
	if id != _id:
		return
	
	resource = msg
	
	if is_instance_valid(ui_loading_animation):
		ui_loading_animation.queue_free()
	
	var sender: C_User = C_User.find_by_login(msg.sender)
	if sender:
		$ui_avatar.user = sender
		$SD_RichTextLabel.text = sender.get_login_richtext() + ": " + str(msg.data)
	else:
		$ui_avatar.user = null
		$SD_RichTextLabel.text = msg.sender + ": " + str(msg.data)
