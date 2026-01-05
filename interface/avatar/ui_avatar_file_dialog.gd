extends FileDialog
class_name UI_AvatarFileDialog

signal on_image_selected(image: Image)

func _on_file_selected(path: String) -> void:
	var image: Image = Image.load_from_file(path)
	if image:
		on_image_selected.emit(image)
