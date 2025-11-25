extends ItemList

func _ready() -> void:
	for i in range(item_count):
		set_item_tooltip_enabled(i, false)
		var selected := false
		match i:
			0:
				selected = Settings.settings["draw_future"]
			1:
				selected = Settings.settings["debug_info"]
		if selected:
			select(i, false)

func _on_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	match index:
		0:
			Settings.toggle("draw_future")
		1:
			Settings.toggle("debug_info")
