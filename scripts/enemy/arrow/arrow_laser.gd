extends Laser

class_name ArrowLaser

@onready var anim := $AnimatedSprite2D

func init(speed_ : float, direction : Vector2):
	super.init(speed_, direction)
	$CPUParticles2D.emitting = true
	rotation = direction.angle()

func _process(_delta: float) -> void:
	pass
