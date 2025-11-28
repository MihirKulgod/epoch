extends Node2D

@onready var bullet := preload("res://scenes/bullet.tscn")

var timer := 2.0

func _process(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		timer = 0.4
		shoot()
	
func shoot():
	var newBullet : RigidBody2D = bullet.instantiate()
	get_tree().current_scene.add_child(newBullet)
	
	newBullet.position = position
	
	var playerPos : Vector2 = get_tree().get_first_node_in_group("player").global_position
	newBullet.linear_velocity = (playerPos - global_position).normalized() * 60
