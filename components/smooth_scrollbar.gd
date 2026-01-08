class_name SmoothScrollContainer extends ScrollContainer

@export var scroll_speed: float = 50.0
@export var duration: float = 0.2

var _tween: Tween
@onready var _target_scroll: float = scroll_vertical

func _ready() -> void:
	scroll_ended.connect(_on_scroll_ended)

func _on_scroll_ended() -> void:
	_target_scroll = scroll_vertical

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var wheel_up:int = event.button_index == MOUSE_BUTTON_WHEEL_UP
		var wheel_down:int = event.button_index == MOUSE_BUTTON_WHEEL_DOWN
		
		if wheel_up or wheel_down:
			var direction := -1.0 if wheel_up else 1.0
			_smooth_scroll(direction)
			accept_event()

func _smooth_scroll(direction: float) -> void:
	var v_bar := get_v_scroll_bar()
	var max_scroll:float = max(0.0, v_bar.max_value - v_bar.page)
	
	_target_scroll = clamp(_target_scroll + direction * scroll_speed, 0, max_scroll)
	
	
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scroll_vertical", int(_target_scroll), duration)
