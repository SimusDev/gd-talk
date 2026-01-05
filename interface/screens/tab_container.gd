extends TabContainer

func _ready() -> void:
	for id in GDTalk.settings.app_screens:
		var scene: PackedScene = GDTalk.settings.app_screens[id]
		var instance: Control = scene.instantiate()
		var localizator: SD_NodeLocalizatorProperty = SD_NodeLocalizatorProperty.new()
		localizator.key = id
		localizator.property = "name"
		instance.add_child(localizator)
		instance.visible = false
		add_child(instance)
