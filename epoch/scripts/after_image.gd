extends Node2D

var timer := 0.0
var lifetime := 0.2
var m : Color

func _ready() -> void:
	m = modulate

func _physics_process(delta: float) -> void:
	timer += delta
	if timer >= lifetime:
		queue_free()
	
	var v := timer / lifetime
	
	modulate = Color(m.r, m.g, m.b, 1-v).lerp(Color(0.552, 0.003, 0.838, 1-v), v)
