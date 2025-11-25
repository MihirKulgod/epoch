extends RichTextLabel

@export var label := ""
@export var addDot := 0.6

var timer := 0.0
var dots := 1

func _process(delta: float) -> void:
	timer += delta
	if timer >= addDot:
		timer = 0
		dots += 1
		if dots > 3:
			dots = 1
	text = label + ".".repeat(dots)
