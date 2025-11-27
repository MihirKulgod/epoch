extends Label

var timer := 0.0
var cd := 1.0

func _process(delta: float) -> void:
	if not Settings.settings["debug_info"]:
		text = ""
		return
	
	timer += delta
	if timer >= cd:
		text = str(get_tree().get_node_count_in_group("projectile")) + " projectiles"
		timer = 0
