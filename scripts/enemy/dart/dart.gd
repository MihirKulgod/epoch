extends Enemy

@onready var cdTimer := $"Shoot CD"
@onready var light := $PointLight2D

@onready var laser := preload("res://scenes/enemy/dart/dart_laser.tscn")

@export var speed := 80.0
@export var shootMargin := 3
@export var lastDir := Vector2.from_angle(PI / 4)

var isShooting := false
var canShoot := false

var max_prediction_disp := 60.0

func _physics_process(_delta: float) -> void:
	var target := Global.player.global_position
	if Global.target_future:
		var predicted := Global.get_predicted(2)
		if (predicted - target).length() < max_prediction_disp:
			target = predicted
	
	anim.flip_h = target.x > global_position.x
	
	if abs(target.y - global_position.y) <= shootMargin and canShoot:
		shoot()

func shoot():
	canShoot = false
	isShooting = true
	anim.play("shoot")
	
	await anim.animation_finished
	
	anim.play("idle")
	cdTimer.start()
	isShooting = false

func off_cooldown() -> void:
	canShoot = true

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var v = state.linear_velocity
	
	if v.length() > 0:
		lastDir = Global.nearest_vector(v, Global.DIAGONAL_AXES)
	
	if isShooting:
		state.linear_velocity = Vector2.ZERO
	else:
		state.linear_velocity = lastDir * speed

func shoot_laser():
	$Shoot.play()
	var l : Laser = laser.instantiate()
	
	var dx = 3 if anim.flip_h else -3
	var dy = 2
	l.init(150, Vector2(Global.sign(anim.flip_h), 0))
	l.global_position = global_position + Vector2(dx, dy)
	get_tree().current_scene.add_child(l)
	
	light.energy = 1
	var t = get_tree().create_tween()
	t.tween_property(light, "energy", 0, 0.5)

func anim_frame_changed() -> void:
	if anim:
		if anim.frame == 3:
			shoot_laser()
			
func get_entity_name():
	return "dart"
	
