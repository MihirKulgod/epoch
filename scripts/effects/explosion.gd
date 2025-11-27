extends Node2D

func _ready() -> void:
	$White.emitting = true
	$Orange.emitting = true
	$AudioStreamPlayer2D.play()
	Global.camera.shake()
	await get_tree().create_timer(3).timeout
	queue_free()
