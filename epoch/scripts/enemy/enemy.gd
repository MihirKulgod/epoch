extends RigidBody2D

class_name Enemy

@onready var explosion := preload("res://scenes/effects/explosion.tscn")
var anim: AnimatedSprite2D

var explosion_scale := 1.0
var loaded := false

func _ready() -> void:
	anim = $AnimatedSprite2D
	process_mode =Node.PROCESS_MODE_DISABLED
	load_in()

func explode():
	Global.createAt(explosion, global_position)
	queue_free()
	Global.master.call_deferred("check_round_beaten")

func load_in() -> void:
	anim.modulate = Color(0.3, 0.3, 0.3, 0)
	var tween = get_tree().create_tween()
	tween.tween_property(anim, "modulate", Color.WHITE, 0.5)
	await tween.finished
	loaded = true
	process_mode =Node.PROCESS_MODE_INHERIT

func get_entity_name():
	return "dart"
