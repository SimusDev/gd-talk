extends CanvasLayer

@onready var control: Control = $Control
@onready var notification_container: AttachContainer = $Control/AttachContainer

func _ready() -> void:
	SimusNetRPCGodot.register_authority_reliable(
		[
			local_send,
			local_send_message,
			
		],
		GDTalk.CHANNELS.INFO_NOTIFICATIONS
	)

func local_send_message(text:String, time:float = 5.0, color:String = "white") -> void:
	var new_label:RichTextLabel = RichTextLabel.new()
	notification_container.add_child(new_label)
	new_label.bbcode_enabled = true
	new_label.fit_content = true 
	new_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	new_label.text = "[color=%s]%s[/color]" % [color, text]
	
	
	get_tree().create_timer(time).timeout.connect(
		notification_container.remove_item.bind(
			new_label)
			)
	

func local_send(text:String) -> void:
	local_send_message(text)

func send(text:String) -> void:
	SimusNetRPCGodot.invoke_all(
		local_send_message,
		text
		
	)

func send_message(text:String, time:float = 5.0, color:String = "white"):
	SimusNetRPCGodot.invoke_all(
		local_send_message,
		text,
		time,
		color
	)
