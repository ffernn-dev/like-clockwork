extends Node2D

const player_scene := preload("res://player.tscn")
var dead_players = []
var player: Player2D
var player_spawn_pos = Vector2(0, 0)

const levels = ["res://1.tscn", "res://2.tscn", "res://3.tscn", "res://4.tscn"]
var loaded_levels = []
var loaded = false

var current_level

func _ready():
	set_process(false)
	_load()
	
func _load():
	for level in levels:
		ResourceLoader.load_threaded_request(level)
	set_process(true)

func _start_level(level: String):
	if current_level:
		current_level.queue_free()
	var res = ResourceLoader.load_threaded_get(level)
	var new_level = res.instantiate()
	add_child(new_level)
	move_child(new_level, 0)
	current_level = new_level
	spawn_player()
	

func _process(_delta):
	if not loaded:
		var all_done := true
		for level in levels:
			var status = ResourceLoader.load_threaded_get_status(level)
			if status == ResourceLoader.THREAD_LOAD_LOADED:
				if !loaded_levels.has(level):
					loaded_levels.append(level)
					print("Loaded: ", level)
			elif status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				all_done = false
			elif status == ResourceLoader.THREAD_LOAD_FAILED:
				push_error("Failed to load " + level)
		
		if all_done:
			print("All levels loaded!")
			loaded = true
			$Loading.queue_free()
			_start_level(levels[0])
	

func spawn_player():
	if len(dead_players) > 3:
		dead_players[0].call_deferred("queue_free")
		dead_players.pop_front()
	player = player_scene.instantiate()
	add_child(player)
	print(current_level)
	player.position = current_level.player_spawn_pos
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
