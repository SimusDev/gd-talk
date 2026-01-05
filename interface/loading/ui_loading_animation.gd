@tool
extends Control
class_name UI_LoadingAnimation

@onready var sd_label: SD_Label = $SD_Label

var _state: int = 0

@export var time: float = 0.5
var _timer: float = 0

func _ready() -> void:
	_update()

func _process(delta: float) -> void:
	_timer = move_toward(_timer, time, delta)
	if _timer >= time:
		_timer = 0
		_update()

func _update() -> void:
	_state += 1
	if _state > 3:
		_state = 0
	sd_label.text = ""
	for i in _state:
		sd_label.text += "."
		
