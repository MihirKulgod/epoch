extends Enemy

@onready var anim := $AnimatedSprite2D
@onready var light := $PointLight2D

@onready var laser := preload("res://scenes/enemy/plus/plus_laser.tscn")

@export var speed := 10.0
@export var laser_speed := 40.0
@export var rotation_speed := 0.4

var flipDir := false

var angle := 0.0
var aiming := Vector2.ZERO

func _physics_process(delta: float) -> void:
	var target := Global.player.global_position
	
	if Global.target_future and Global.futurePlayerPositions:
		var p = Global.futurePlayerPositions
		var i = 0
		target = Vector2(p[i], p[i+1])
	
	aiming = target - global_position
	
	if Global.oneIn(100):
		flipDir = not flipDir
	
	angle += delta * rotation_speed
	anim.rotation = angle

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	rotation = 0
	state.linear_velocity = aiming.normalized() * speed

func shoot_laser():
	var l1 : Laser = laser.instantiate()
	var l2 : Laser = laser.instantiate()
	var l3 : Laser = laser.instantiate()
	var l4 : Laser = laser.instantiate()
	
	var dx = 0
	var dy = 0
	l1.init(laser_speed, Vector2.RIGHT.rotated(angle))
	l2.init(laser_speed, Vector2.LEFT.rotated(angle))
	l3.init(laser_speed, Vector2.UP.rotated(angle))
	l4.init(laser_speed, Vector2.DOWN.rotated(angle))
	l1.global_position = global_position + Vector2(dx, dy)
	l2.global_position = global_position + Vector2(dx, dy)
	l3.global_position = global_position + Vector2(dx, dy)
	l4.global_position = global_position + Vector2(dx, dy)
	get_tree().current_scene.add_child(l1)
	get_tree().current_scene.add_child(l2)
	get_tree().current_scene.add_child(l3)
	get_tree().current_scene.add_child(l4)
	
	light.energy = 1
	var t = get_tree().create_tween()
	t.tween_property(light, "energy", 0, 0.3)

func anim_frame_changed() -> void:
	if anim:
		if anim.frame == 4:
			shoot_laser()
