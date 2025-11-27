extends Enemy

@export var speed := 20

@onready var laser := preload("res://scenes/enemy/arrow/arrow_laser.tscn")

@onready var light = $PointLight2D

var canShoot := false
var isShooting := false
var aiming := Vector2.ZERO

var flipDir := false

var max_prediction_disp := 60.0

func _physics_process(_delta: float) -> void:
	var target := Global.player.global_position
	var dp := target - global_position
	
	if Global.target_future:
		var predicted := Global.get_predicted(0)
		if (predicted - target).length() < max_prediction_disp:
			target = predicted
	
	var d = target - global_position
	
	if not isShooting:
		anim.rotation = d.angle()
		aiming = d
	
	if Global.oneIn(100):
		flipDir = not flipDir
	
	if canShoot and abs(d.angle_to(dp)) < PI / 4:
		shoot()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	rotation = 0
	if isShooting:
		state.linear_velocity = Vector2.ZERO
	else:
		state.linear_velocity = (aiming * -1).normalized().rotated(Global.sign(flipDir) * 3 * PI / 4) * speed

func shoot():
	$ShootSound.play()
	isShooting = true
	anim.play("shoot")
	canShoot = false
	$Shoot.start(randf_range(1.0, 2.0))
	
	await anim.animation_finished
	
	anim.play("idle")
	isShooting = false

func shoot_laser():
	var l : Laser = laser.instantiate()
	
	var dx = 0
	var dy = 0
	l.init(500, aiming)
	l.global_position = global_position + Vector2(dx, dy)
	get_tree().current_scene.add_child(l)
	
	light.energy = 2
	var t = get_tree().create_tween()
	t.tween_property(light, "energy", 0, 0.8)
	
func _draw() -> void:
	if isShooting:
		var a := Vector2.ZERO
		var b := aiming.normalized() * 1000
		if int(Engine.get_physics_frames() / 2.0) % 2 == 0:
			draw_line(a, a + b, Color(0.83, 0.816, 0.415, 1), 0.8, false)
	
func _process(_delta: float) -> void:
	queue_redraw()

func reload() -> void:
	canShoot = true

func anim_frame_changed() -> void:
	if anim:
		if anim.frame == 2:
			shoot_laser()

func get_entity_name():
	return "arrow"
