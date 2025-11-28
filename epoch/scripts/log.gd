extends Node2D

var last_projectiles = []

func _physics_process(_delta: float) -> void:
	if not Global.roundRunning:
		return
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	var enemies = get_tree().get_nodes_in_group("enemy")
	if not enemies:
		return
	var projectiles = get_tree().get_nodes_in_group("projectile")
	var pos = player.global_position
	var vel = player.velocity
	var player_state = [pos.x, pos.y, vel.x, vel.y]
	var enemy_list = []
	var projectile_list = []
	for e in enemies:
		enemy_list.append([
			e.global_position.x,
			e.global_position.y,
			e.linear_velocity.x,
			e.linear_velocity.y
		])
		
	last_projectiles = projectiles
	for p in projectiles:
		projectile_list.append([
			p.global_position.x,
			p.global_position.y,
			p.linear_velocity.x,
			p.linear_velocity.y
		])

	Logger_.log_frame(player_state, enemy_list, projectile_list)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if Settings.settings["debug_info"]:
		for p in last_projectiles:
			if not p:
				continue
			draw_string(ThemeDB.fallback_font, p.global_position, str(p.linear_velocity), HORIZONTAL_ALIGNMENT_CENTER, -1, 2, Color.WHITE)
