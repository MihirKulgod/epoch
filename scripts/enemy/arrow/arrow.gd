extends RigidBody2D

@export var speed := 20

@onready var anim = $AnimatedSprite2D

var canShoot := false
var isShooting := false
var aiming := Vector2.ZERO

func _physics_process(_delta: float) -> void:
	var target := Global.player.global_position
	var dp := target - global_position
	
	if Global.futurePlayerPositions:
		var p = Global.futurePlayerPositions
		var i = 0
		#target = Vector2(p[i], p[i+1])
	
	var d = target - global_position
	
	if not isShooting:
		anim.rotation = d.angle()
		aiming = d
	
	
	if canShoot and abs(d.angle_to(dp)) < PI / 4:
		shoot()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if isShooting:
		state.linear_velocity = Vector2.ZERO
	else:
		state.linear_velocity = (aiming * -1).normalized().rotated(3 * PI / 4) * speed

func shoot():
	isShooting = true
	anim.play("shoot")
	canShoot = false
	$Shoot.start()
	
	await anim.animation_finished
	
	anim.play("idle")
	isShooting = false
	
func _draw() -> void:
	if isShooting:
		var a := Vector2.ZERO
		var b := aiming.normalized() * 1000
		draw_line(a, a + b, Color(0.83, 0.816, 0.415, 1), 0.8, false)
	
func _process(_delta: float) -> void:
	queue_redraw()

func reload() -> void:
	canShoot = true
