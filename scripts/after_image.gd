extends Node2D

var timer := 0.0
var lifetime := 0.3

func _physics_process(delta: float) -> void:
	timer += delta
	if timer >= lifetime:
		queue_free()
	
	var v := timer / lifetime
	
	var m = Color(0.404, 0.757, 0.953, 1.0)	
	
	modulate = Color(m.r, m.g, m.b, 1-v).lerp(Color(0.552, 0.003, 0.838, 1-v), v)
