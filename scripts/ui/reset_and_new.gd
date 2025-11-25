extends Button

@onready var scene := preload("res://scenes/main.tscn")

func _on_pressed() -> void:
	Global.add_loading()
	await Server.request_reset()
	await Global.fade_out()
	Global.current_round = 0
	get_tree().change_scene_to_packed(scene)
