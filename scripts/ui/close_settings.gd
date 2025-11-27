extends Button

func _on_button_down() -> void:
	get_tree().get_first_node_in_group("button_click").play()
	$"../../..".queue_free()
	get_tree().paused = false
