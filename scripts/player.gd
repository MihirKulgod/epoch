extends CharacterBody2D

class_name Player

@onready var anim := $AnimatedSprite2D
@onready var afterimage := preload("res://scenes/after_image.tscn")

var aiTimer := 0.0
var aiInterval := 0.05

var canDash := true
var dashQueued := false
var dashTime := 0.0
var dashVec := Vector2.RIGHT

var dir := {
	"left": false,
	"right": false,
	"up": false,
	"down": false
}

var upLast := false
var leftLast := false

var lastKnownVel := Vector2.RIGHT

func _ready() -> void:
	Global.player = self

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dash") and canDash:
		dash()
		canDash = false
		$Dash.start()
		await $Dash.timeout
		canDash = true

func dash():
	dashQueued = true

func _physics_process(delta: float) -> void:
	for key in dir.keys():
		dir.set(key, Input.is_action_pressed("move_" + key))
	
	if Input.is_action_just_pressed("move_up"): upLast = true
	if Input.is_action_just_pressed("move_down"): upLast = false
	if Input.is_action_just_pressed("move_left"): leftLast = true
	if Input.is_action_just_pressed("move_right"): leftLast = false
	
	var x := 0
	var y := 0
	
	x = -1 if (dir.get("left") and leftLast) else x
	x = 1 if (dir.get("right") and not leftLast) else x
	y = -1 if (dir.get("up") and upLast) else y
	y = 1 if (dir.get("down") and not upLast) else y
	
	var vec := Vector2(x, y)
	
	if dashQueued:
		dashQueued = false
		dashTime = 0.15
		dashVec = Vector2(x, y)
	
	var s := 80
	
	if dashTime > 0:
		dashTime -= delta
		vec = dashVec
		s = 200
	
	velocity = vec.normalized() * s
	
	if velocity != Vector2.ZERO:
		lastKnownVel = velocity
	
	var d := velocity
	if velocity == Vector2.ZERO:
		d = lastKnownVel
	set_direction(d)
	
	aiTimer += delta
	if aiTimer >= aiInterval:
		aiTimer = 0
		spawn_afterimage()
	
	move_and_slide()

func set_direction(direction := Vector2.UP):
	var angle := int(rad_to_deg(direction.angle())) + 180
	
	var map := {
		360: 1,
		45: 4,
		90: 2,
		135: 5,
		180: 0,
		225: 6,
		270: 3,
		315: 7
	}
		
	anim.frame = map.get_or_add(angle, 0)

func spawn_afterimage():
	var ai : Node2D = afterimage.instantiate()
	ai.transform = ai.transform.scaled(scale)
	ai.global_position = global_position
	get_tree().current_scene.add_child(ai)

func hurt(_body: Node2D) -> void:
	Global.master.die()
