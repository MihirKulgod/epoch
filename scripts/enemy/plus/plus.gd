extends Enemy

@onready var light := $PointLight2D
var lightColor : Color

@onready var laser := preload("res://scenes/enemy/plus/plus_laser.tscn")

@export var speed := 10.0
@export var laser_speed := 40.0
@export var rotation_speed := 0.4
@export var enrage_distance := 100.0
@export var enrage_time := 3.0
@export var enrage_rotation_mult := 4.0
@export var enrage_movement_mult := 0.5
@export var enrage_denom := 250

var flipDir := false
var enraged := false

var angle := 0.0
var aiming := Vector2.ZERO

func _ready() -> void:
	super._ready()
	lightColor = light.color

func _physics_process(delta: float) -> void:
	var target := Global.player.global_position
	
	aiming = target - global_position
	
	if Global.oneIn(300):
		flipDir = not flipDir
		
	if not enraged and aiming.length() > enrage_distance:
		if Global.oneIn(enrage_denom):
			start_rage()
	
	var mult := 1.0
	if enraged:
		mult = enrage_rotation_mult
	angle += delta * rotation_speed * mult
	if anim:
		anim.rotation = angle

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	rotation = 0
	var mult := 1.0
	if enraged:
		mult = enrage_movement_mult
	state.linear_velocity = aiming.normalized().rotated(Global.sign(flipDir) * PI/8) * speed * mult

func shoot_laser():
	$Shoot.play()
	
	var l1 : PlusLaser = laser.instantiate()
	var l2 : PlusLaser = laser.instantiate()
	var l3 : PlusLaser = laser.instantiate()
	var l4 : PlusLaser = laser.instantiate()
	
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
	
	if enraged:
		l1.enrage()
		l2.enrage()
		l3.enrage()
		l4.enrage()
	
	get_tree().current_scene.add_child(l1)
	get_tree().current_scene.add_child(l2)
	get_tree().current_scene.add_child(l3)
	get_tree().current_scene.add_child(l4)
	
	light.energy = 2 if enraged else 1
	var t = get_tree().create_tween()
	t.tween_property(light, "energy", 0, 0.3)

func anim_frame_changed() -> void:
	if anim:
		if anim.frame == 4:
			shoot_laser()

func start_rage() -> void:
	light.color = Color.RED
	enraged = true
	if anim:
		anim.play("enraged")
	$Enrage.start(enrage_time)

func end_rage() -> void:
	enraged = false
	anim.play("default")
	light.color = lightColor

func get_entity_name():
	return "plus"
	
