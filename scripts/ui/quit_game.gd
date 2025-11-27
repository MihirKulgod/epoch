extends Button

func _on_pressed() -> void:
	get_tree().get_first_node_in_group("button_click").play()
	Global.quit()
