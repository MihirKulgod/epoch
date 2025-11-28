extends Node

@onready var one := $"1"

func _process(_delta: float) -> void:
	if not Global.roundRunning:
		if one.playing:
			one.stop()
		return
	if not one.playing:
		one.play()

func _on__finished() -> void:
	one.play()
	
