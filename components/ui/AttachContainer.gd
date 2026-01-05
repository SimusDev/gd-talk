@tool
class_name AttachContainer extends Control

enum Align {
	LEFT,
	CENTER,
	RIGHT
}

@export var vertical_align:Align = 0
@export_group("Settings")
@export var separation:float = 10.0
@export_group("Animation")
@export var animated:bool = true
@export var animation_duration:float = 1.0

func _ready():
	child_entered_tree.connect(_on_child_entered)
	_update()

func _on_child_entered(node: Node):
	if node is Control:
		_update()
		_add_item(node)

func _add_item(new_item:Control) -> void:
	var pos_x:float = get_item_pos_x(new_item)
	var pos_y:float = get_item_pos_y(new_item)
	
	var start_pos:Vector2 = Vector2(pos_x, get_tree().root.size.y -new_item.size.y)
	var end_pos:Vector2 = Vector2(pos_x, pos_y)
	
	new_item.position = start_pos
	
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property(
		new_item,
		"position",
		end_pos,
		animation_duration
	)

func get_item_pos_x(item:Control) -> float:
	if vertical_align == Align.CENTER:
		return (size.x / 2) - (item.size.x / 2)
	elif vertical_align == Align.RIGHT:
		return size.x - item.size.x
	return 0.0

func get_item_pos_y(item:Control) -> float:
	var result:float = 0.0
	for i in range(0, item.get_index()):
		var child = get_child(i)
		if child == item:
			continue
		if child is Control:
			result += child.size.y + separation
	return result

func _update() -> void:
	for c in get_children():
		if c is Control:
			c.position = Vector2(
				get_item_pos_x(c),
				get_item_pos_y(c)
			)
