extends Laser

class_name PlusLaser

func init(speed_ : float, direction : Vector2):
	super.init(speed_, direction)
	$CPUParticles2D.emitting = true

func _process(delta: float) -> void:
	$AnimatedSprite2D.rotation += delta
