extends Sprite2D

func _process(_delta: float) -> void:
	queue_redraw()

func _draw():
	var o := 0.5
	if Global.futurePlayerPositions:
		var p = Global.futurePlayerPositions
		var j = int(len(p) / 2.0)
		for a in range(j):
			var i = 2*a
			var v = to_local(Vector2(p[i], p[i+1]))
			var w := pow(float(a)/float(j-1), 1)
			draw_circle(v, 20, Color(0.125, 0.663, 0.29, o).lerp(Color(1.0, 1.0, 1.0, o/2.0), w))
