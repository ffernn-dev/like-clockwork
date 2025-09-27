extends Node2D

const player_scene := preload("res://player.tscn")
var dead_players = []
var player: Player2D

func _ready():
	spawn_player()

func spawn_player():
	player = player_scene.instantiate()
	add_child(player)

func kill_player():
	player.die()
	dead_players.append(player)
	spawn_player()

func _input(event):
	if event.is_action_pressed("die"):
		kill_player()
		
