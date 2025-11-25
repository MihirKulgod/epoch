extends RigidBody2D

class_name Enemy

@onready var explosion := preload("res://scenes/effects/explosion.tscn")

var explosion_scale := 1.0

func explode():
	Global.createAt(explosion, global_position)
	queue_free()
	Global.master.call_deferred("check_round_beaten")
