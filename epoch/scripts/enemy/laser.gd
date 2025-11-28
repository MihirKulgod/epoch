extends RigidBody2D

class_name Laser

var speed := 100.0

func init(speed_ : float, direction : Vector2):
	self.speed = speed_
	linear_velocity = direction.normalized() * speed

func _process(_delta: float) -> void:
	get_sprite().flip_h = linear_velocity.x < 0
	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var v = state.linear_velocity
	if v.is_equal_approx(Vector2.ZERO):
		queue_free()
	state.linear_velocity = v.normalized() * speed
	
	#get_sprite().rotation_degrees = v.angle()

func get_sprite() -> AnimatedSprite2D:
	return $AnimatedSprite2D
