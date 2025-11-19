extends Laser

class_name DartLaser

func init(speed, direction):
	super.init(speed, direction)
	$CPUParticles2D.emitting = true
