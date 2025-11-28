extends PointLight2D

func _process(_delta: float) -> void:
	energy = 1.5 + 1.5 * sin(Engine.get_process_frames() * 0.015)
