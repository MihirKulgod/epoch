extends Enemy

@export var retreatSpeed := 25
@export var aggressiveSpeed := 40
@export var proximityRequired := 40
@export var projectile_speed := 80
@export var minDistanceForAttack := 30
@export var retreatDistance := 80

@onready var laser := preload("res://scenes/enemy/scout/scout_laser.tscn")

@onready var light = $PointLight2D

var canAttack := true
var isShooting := false
var aiming := Vector2.RIGHT

var flipDir := false
var aggressive := false

var max_prediction_disp := 60.0

var ticksSinceAggressive := 0.0
var maxPassiveTime := 150.0

var dplayer := Vector2.ZERO

func _physics_process(delta: float) -> void:
	var target := Global.player.global_position
	dplayer = target - global_position
	
	if Global.target_future:
		var predicted := Global.get_predicted(1)
		if (predicted - target).length() < max_prediction_disp:
			target = predicted
	
	var d := target - global_position
	
	var dr := aiming.angle_to(d)
	aiming = aiming.rotated(dr/16)
	
	anim.rotation = aiming.angle()
	
	if Global.oneIn(150):
		flipDir = not flipDir
	
	if canAttack and not aggressive and dplayer.length() >= minDistanceForAttack:
		if Global.oneIn(150) or ticksSinceAggressive >= maxPassiveTime:
			aggressive = true
		else:
			ticksSinceAggressive += delta
	else:
		ticksSinceAggressive = 0
		
	if aggressive and dr < PI / 16 and d.length() < proximityRequired:
		shoot()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	rotation = 0
	if aggressive:
		state.linear_velocity = aiming.normalized().rotated(Global.sign(flipDir) * 0.5 * PI / 4) * aggressiveSpeed
	elif dplayer.length() < retreatDistance:
		state.linear_velocity = aiming.normalized().rotated(Global.sign(flipDir) * 1 * PI / 4) * retreatSpeed * -1
	else:
		state.linear_velocity = aiming.normalized().rotated(Global.sign(flipDir) * PI / 2) * retreatSpeed
		
func shoot():
	canAttack = false
	aggressive = false
	$ShootSound.play()
	$Attack.start(2)
	
	shoot_laser()

func shoot_laser():
	var l1 : Laser = laser.instantiate()
	var l2 : Laser = laser.instantiate()
	var l3 : Laser = laser.instantiate()
	
	var dx = 0
	var dy = 0
	l1.init(projectile_speed, aiming)
	l2.init(projectile_speed, aiming.rotated(-PI/6))
	l3.init(projectile_speed, aiming.rotated(PI/6))
	l1.global_position = global_position + Vector2(dx, dy)
	l2.global_position = global_position + Vector2(dx, dy)
	l3.global_position = global_position + Vector2(dx, dy)
	get_tree().current_scene.add_child(l1)
	get_tree().current_scene.add_child(l2)
	get_tree().current_scene.add_child(l3)
	
	light.energy = 2
	var t = get_tree().create_tween()
	t.tween_property(light, "energy", 0, 0.8)

func ready_attack() -> void:
	canAttack = true

func _draw() -> void:
	if not Settings.settings["debug_info"]:
		return
	var c := Color.GREEN
	if aggressive:
		c = Color.RED
	draw_line(Vector2.ZERO, aiming * 20, c, 2)

func _process(_delta: float) -> void:
	queue_redraw()

func get_entity_name():
	return "scout"
