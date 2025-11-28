extends RichTextLabel

var phase := 0
var prevPhase := 0
# 0 Not started, 1 started, 2 ended

@export var addDot := 0.6

var timer := 0.0
var dots := 1

var label := "Waiting to start training"

func _process(delta: float) -> void:
	phase = 0 if not Global.trainingStarted else 1
	if Global.trainingEnded:
		phase = 2
	
	timer += delta
	if timer >= addDot:
		timer = 0
		dots += 1
		if dots > 3:
			dots = 1
	
	match phase:
		0:
			label = "Waiting to start training" + ".".repeat(dots)
		1:
			label = "Training" + ".".repeat(dots)
		2:
			label = "Training complete!"
	text = label
	
	if prevPhase == 1 and phase == 2:
		$"../../Complete".play()
	
	prevPhase = phase
