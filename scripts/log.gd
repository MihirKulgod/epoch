extends Node

func _process(delta):
	var player = get_tree().get_first_node_in_group("player")
	var projectiles = get_tree().get_nodes_in_group("projectile")

	var pos = player.global_position
	var vel = player.velocity

	var player_state = [pos.x, pos.y, vel.x, vel.y]

	var projectile_list = []
	for p in projectiles:
		projectile_list.append([
			p.global_position.x,
			p.global_position.y,
			p.linear_velocity.x,
			p.linear_velocity.y
		])

	Logger_.log_frame(player_state, projectile_list)
