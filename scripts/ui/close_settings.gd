extends Button

func _on_button_down() -> void:
	$"../../..".queue_free()
	get_tree().paused = false
