extends Button

@export var scene : PackedScene = null

func _on_pressed() -> void:
	await Global.fade_out()
	get_tree().change_scene_to_packed(scene)
