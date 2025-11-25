extends Node2D

@onready var bar := $Control/TextureProgressBar
@onready var next_button := $Control/Button

func _ready() -> void:
	Global.fade_in()
	await get_tree().create_timer(0.2).timeout
	$Cover.queue_free()
	
	Global.trainingStarted = false
	Global.trainingEnded = false
	Server.request_train()

func _process(_delta: float) -> void:
	if bar:
		bar.value = round(100.0 * Global.epoch / Global.max_epoch)
	if Global.trainingEnded and next_button:
		next_button.disabled = false
