extends Laser

class_name PlusLaser

@onready var anim := $AnimatedSprite2D

var enraged := false

func _ready() -> void:
	if enraged:
		anim.play("enraged")
		$PointLight2D.color = Color.RED
		$PointLight2D.texture_scale *= 1.5
		$PointLight2D.energy *= 1.5

func init(speed_ : float, direction : Vector2):
	super.init(speed_, direction)
	$CPUParticles2D.emitting = true

func enrage():
	enraged = true
	speed *= 1.5

func _process(delta: float) -> void:
	anim.rotation += delta
