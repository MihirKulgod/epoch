extends Node2D

func _ready() -> void:
	Global.fade_in()
	await get_tree().create_timer(0.2).timeout
	$Cover.queue_free()
