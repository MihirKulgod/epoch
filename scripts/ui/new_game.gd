extends Button

@export var scene : PackedScene = null

func _on_pressed() -> void:
	await Global.fade_out()
	Global.current_round = 0
	get_tree().change_scene_to_packed(scene)
