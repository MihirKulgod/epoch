extends Button

@export var scene : PackedScene = null

func _ready() -> void:
	get_tree().change_scene_to_packed(scene)
