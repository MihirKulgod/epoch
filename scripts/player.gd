extends CharacterBody2D

var dir := {
	"left": false,
	"right": false,
	"up": false,
	"down": false
}

var upLast := false
var leftLast := false

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
	
	move_and_slide()
