extends Node2D

const player_scene := preload("res://player.tscn")
var dead_players = []
var player: Player2D
var player_spawn_pos = Vector2(0, 0)

func _ready():
	for node in get_children():
		if is_instance_of(node, PlayerSpawn):
			player_spawn_pos = node.position
			break
	spawn_player()

func spawn_player():
	if len(dead_players) > 3:
		dead_players[0].call_deferred("queue_free")
		dead_players.pop_front()
	player = player_scene.instantiate()
	add_child(player)
	player.position = player_spawn_pos
	player.died.connect(_on_player_died)

func kill_player():
	player.die(true)
	dead_players.append(player)
	spawn_player()

func _input(event):
	if event.is_action_pressed("die"):
		kill_player()
	if event.is_action_pressed("restart"):
		restart_level()

func _on_player_died(graceful) -> void:
	if not graceful:
		restart_level()

func restart_level() -> void:
	for i in dead_players:
		i.call_deferred("queue_free")
	# reload current scene
	var current := get_tree().current_scene
	var path := current.scene_file_path
	get_tree().call_deferred("change_scene_to_file", path)
