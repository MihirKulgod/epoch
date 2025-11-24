extends Node2D

class_name Blackout

@onready var cover := $Black/ColorRect
@onready var darken := $CanvasModulate

func fade_in(time := 1.0, darken_delay := 0.3, darken_time := 0.7):
	cover.color = Color.BLACK
	darken.color = Color.BLACK
	var t1 = get_tree().create_tween()
	t1.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t1.tween_property(cover, "color", Color(0, 0, 0, 0), time).set_trans(Tween.TRANS_CIRC)
	
	await get_tree().create_timer(darken_delay).timeout
	var t2 = get_tree().create_tween()
	t2.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t2.tween_property(darken, "color", Color.WHITE, darken_time).set_trans(Tween.TRANS_CIRC)
	await t2.finished

func fade_out(time := 2.0):
	var t = get_tree().create_tween()
	cover.color = Color(0, 0, 0, 0)
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(cover, "color", Color.BLACK, time).set_trans(Tween.TRANS_LINEAR)
	await t.finished
