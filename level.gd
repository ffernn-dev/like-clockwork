class_name Level extends Node

var player: Player2D
var player_spawn_pos = Vector2(0, 0)

func _ready():
	for node in get_children():
		if is_instance_of(node, PlayerSpawn):
			player_spawn_pos = node.position
			break
