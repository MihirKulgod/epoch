extends Button

@export var scene : PackedScene = null

func _on_pressed() -> void:
	get_tree().get_first_node_in_group("button_click").play()
	await Global.fade_out()
	get_tree().change_scene_to_packed(scene)
