extends Panel
class_name UI_ChatMessage

@export var chat: C_Chat
@export var id: int = -1

@onready var ui_loading_animation: UI_LoadingAnimation = $UiLoadingAnimation
@onready var message_text_label: SD_RichTextLabel = $MessageTextLabel
@onready var user_name_label: RichTextLabel = $UserNameLabel
@onready var time_label: SD_RichTextLabelSimple = $Time

var resource: R_ChatMessage

static func get_scene() -> PackedScene:
	return load("res://interface/screens/chat/messsage.tscn")

func _ready() -> void:
	chat.on_message_synchronized.connect(_on_sync)
	GDTalk.pkg_users.on_user_connected.connect(_on_user_connected)

func _on_user_connected(user: C_User) -> void:
	if !resource:
		return
	
	if user.login == resource.sender:
		$ui_avatar.user = user

var _synced: bool = false
func _on_sync(_id: int, msg: R_ChatMessage) -> void:
	if id != _id or _synced:
		return
	
	_synced = true
	
	resource = msg
	
	if is_instance_valid(ui_loading_animation):
		ui_loading_animation.queue_free()
	
	var sender: C_User = C_User.find_by_login(msg.sender)
	var username: String = msg.sender
	if sender:
		username = sender.get_login_richtext()
	
	$ui_avatar.user = sender
	if !sender:
		$ui_avatar.set_texture(C_User.get_user_avatar(msg.sender))
	
	user_name_label.text = "[font_size=24]%s[/font_size]" % str( msg.sender )
	time_label.text = "[color=gray]%s" % [msg.time]
	message_text_label.text = str(msg.data)

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	if _synced:
		return
	chat.synchronize_message(id)
