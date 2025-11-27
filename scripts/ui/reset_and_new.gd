extends Button

@onready var scene := preload("res://scenes/main.tscn")

func _on_pressed() -> void:
	get_tree().get_first_node_in_group("button_click").play()
	Global.add_loading()
	await Server.request_reset()
	await Global.fade_out()
	Global.current_round = 0
	Logger_.clear()
	get_tree().change_scene_to_packed(scene)
