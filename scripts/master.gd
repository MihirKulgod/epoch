extends Node

class_name Master

@onready var blackout : Blackout = $"../Black"

func _ready() -> void:
	Global.master = self
	
	get_tree().paused = true
	await blackout.ready
	await blackout.fade_in(1)
	get_tree().paused = false

func die() -> void:
	get_tree().paused = true
	await blackout.fade_out(1.5)
	await get_tree().create_timer(1).timeout
	get_tree().call_deferred("reload_current_scene")
