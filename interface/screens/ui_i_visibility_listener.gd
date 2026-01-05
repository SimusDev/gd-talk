@tool
extends Node
class_name C_IVisibilityListener

@export var item: CanvasItem

var _visible: bool = false

signal on_changed(visibility: bool)

func _ready() -> void:
	if !item:
		item = get_parent()
	
	_visible = item.is_visible_in_tree()
	item.visibility_changed.connect(_on_changed)

func _on_changed() -> void:
	if _visible == item.is_visible_in_tree():
		return
	_visible = item.is_visible_in_tree()
	on_changed.emit(item.is_visible_in_tree())
	
