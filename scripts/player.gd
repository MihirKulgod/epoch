extends CharacterBody2D

@onready var anim := $AnimatedSprite2D
@onready var afterimage := preload("res://scenes/after_image.tscn")

var aiTimer := 0.0
var aiInterval := 0.1

var dir := {
	"left": false,
	"right": false,
	"up": false,
	"down": false
}

var upLast := false
var leftLast := false

var lastKnownVel := Vector2.RIGHT

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
	
	velocity = Vector2(x, y).normalized() * 100
	
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
	ai.global_position = global_position
	get_tree().current_scene.add_child(ai)
