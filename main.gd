extends Node2D

const player_scene := preload("res://player.tscn")
var dead_players = []
var player: Player2D

func _ready():
	spawn_player()
	player.died.connect(_on_player_died)

func spawn_player():
	player = player_scene.instantiate()
	add_child(player)

func kill_player():
	player.die(true)
	dead_players.append(player)
	spawn_player()

func _input(event):
	if event.is_action_pressed("die"):
		kill_player()

func _on_player_died(graceful) -> void:
	print(graceful)
	if not graceful:
		restart_level()

func restart_level() -> void:
	for i in dead_players:
		call_deferred("i.queue_free")
	#  reload current scene
	var current := get_tree().current_scene
	var path := current.scene_file_path
	get_tree().change_scene_to_file(path)
		
