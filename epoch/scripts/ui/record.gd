extends Sprite2D

class_name Record

var showTime := 0.04
var timer := 0.0

func _process(delta: float) -> void:
	if timer > 0:
		timer -= delta
	else:
		visible = false
		
func _show():
	if not Settings.settings["debug_info"]:
		return
	visible = true
	timer = showTime
