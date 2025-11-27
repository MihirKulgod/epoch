extends HSlider

func _ready() -> void:
	value = Settings.settings.get_or_add("volume", 6)
	
func _on_drag_ended(value_changed: bool) -> void:
	if not value_changed:
		return
	Settings.settings["volume"] = int(value)
	Settings.set_global_volume(value * 10)
