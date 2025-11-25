extends ColorRect

func _process(_delta: float) -> void:
	if Server.connected:
		queue_free()
