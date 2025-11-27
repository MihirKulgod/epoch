extends Camera2D

class_name Camera

var isShaking := false

var t := 0.0
var shakeTime := 0.4
var maxZoom := 1.1

func _ready() -> void:
	Global.camera = self

func shake(_intensity := 1.0):
	if isShaking:
		return
	isShaking = true

func _process(delta: float) -> void:
	if isShaking:
		var p := t/shakeTime
		var h = p*2 - floor(p*2)
		t += delta
		if t >= shakeTime:
			t = 0.0
			isShaking = false
			offset = Vector2.ZERO
			zoom = Vector2.ONE
			return
		offset = Vector2(15 * (1-p) * sin(20 * t), 0)
		var z = h if p < 0.5 else (1-h)
		zoom = Vector2.ONE * (1 + z * (maxZoom - 1))
