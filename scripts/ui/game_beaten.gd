extends Node2D

func _ready() -> void:
	$Cover.queue_free()
	Global.fade_in()
