extends Laser

class_name DartLaser

func init(speed_ : float, direction : Vector2):
	super.init(speed_, direction)
	$CPUParticles2D.emitting = true
