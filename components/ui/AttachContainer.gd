@tool
class_name AttachContainer extends Control

enum Align { LEFT, CENTER, RIGHT }

@export var horizontal_align: Align = Align.LEFT:
	set(val):
		horizontal_align = val
		_update()

@export_group("Settings")
@export var separation: float = 10.0:
	set(val):
		separation = val
		_update()

@export_group("Animation")
@export var animated: bool = true
@export var animation_duration: float = 3.0

func _ready():
	child_entered_tree.connect(_on_child_entered)
	child_order_changed.connect(_update)
	_update()

func _on_child_entered(node: Node) -> void:
	if node is Control:
		await get_tree().process_frame
		_add_item(node)
		_update()

func _add_item(new_item: Control) -> void:
	if not animated: return
	
	var target_pos = _get_target_pos(new_item)
	new_item.position = Vector2(target_pos.x, get_viewport_rect().size.y)
	
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(new_item, "position", target_pos, animation_duration)

func remove_item(item: Control) -> void:
	if animated:
		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tween.tween_property(item, "position:y", get_viewport_rect().size.y, animation_duration)
		tween.finished.connect(item.queue_free)
	else:
		item.queue_free()
	
	await get_tree().process_frame
	_update()

func _get_target_pos(item: Control) -> Vector2:
	var pos_x: float = 0.0
	match horizontal_align:
		Align.CENTER: pos_x = (size.x - item.size.x) / 2
		Align.RIGHT: pos_x = size.x - item.size.x
		
	var pos_y: float = 0.0
	for i in range(item.get_index()):
		var child = get_child(i)
		if child is Control and child.visible:
			pos_y += child.size.y + separation
			
	return Vector2(pos_x, pos_y)

func _update() -> void:
	for child in get_children():
		if child is Control and not child.is_queued_for_deletion():
			var target = _get_target_pos(child)
			if animated:
				var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
				tween.tween_property(child, "position", target, animation_duration)
			else:
				child.position = target
