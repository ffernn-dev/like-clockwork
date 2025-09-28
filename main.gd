extends Node2D

const player_scene := preload("res://player.tscn")
var dead_players = []
var player: Player2D
var player_spawn_pos = Vector2(0, 0)

const levels = [
	"res://1.tscn",
	"res://2.tscn",
	"res://3.tscn",
	"res://4.tscn"
]

# Store each loaded `PackedScene` instead of only path
var level_resources: Dictionary = {}
var loaded = false

var current_level: Node
var current_level_idx: int

func _ready():
	set_process(false)
	_load()
	current_level_idx = 0
	EventBus.level_complete.connect(_on_level_complete)

func _load():
	for level in levels:
		ResourceLoader.load_threaded_request(level)
	set_process(true)

func _start_level(level: String):
	if current_level:
		current_level.queue_free()
	
	# Pull the existing PackedScene, not reload
	var packed: PackedScene = level_resources.get(level, null)
	if packed == null:
		push_error("Level not found in resources: " + level)
		return

	var new_level = packed.instantiate()
	call_deferred("_finalize_start_level", new_level)


func _finalize_start_level(new_level: Node):
	add_child(new_level)
	move_child(new_level, 0)
	current_level = new_level
	spawn_player()

func _on_level_complete():
	_clear_players()
	current_level_idx = (current_level_idx + 1) % levels.size()
	_start_level(levels[current_level_idx])

func _process(_delta):
	if not loaded:
		var all_done := true
		for level in levels:
			var status = ResourceLoader.load_threaded_get_status(level)
			if status == ResourceLoader.THREAD_LOAD_LOADED:
				if not level_resources.has(level):
					var res = ResourceLoader.load_threaded_get(level)
					if res:
						level_resources[level] = res
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
	if dead_players.size() > 3:
		dead_players[0].call_deferred("queue_free")
		dead_players.pop_front()
	player = player_scene.instantiate()
	add_child(player)
	player.position = current_level.player_spawn_pos
	player.died.connect(_on_player_died)

func kill_player():
	player.die(true)
	dead_players.append(player)
	spawn_player()

func _input(event):
	if event.is_action_pressed("die"):
		kill_player()
	elif event.is_action_pressed("restart"):
		restart_level()

func _on_player_died(graceful: bool) -> void:
	if not graceful:
		restart_level()

func _clear_players():
	for i in dead_players:
		i.call_deferred("queue_free")
	dead_players.clear()
	if player:
		player.call_deferred("queue_free")
		player = null

func restart_level() -> void:
	_clear_players()
	_start_level(levels[current_level_idx])
