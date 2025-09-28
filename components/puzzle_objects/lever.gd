class_name Lever extends "res://components/interactable.gd"

signal toggled(state: bool)

var active := false
@onready var anim := $Sprite

func _ready():
	EventBus.player_died.connect(reset)
	
func reset(graceful):
	if active:
		anim.play_backwards("default")
		emit_signal("toggled", active)
		active = false

func interact(actor):
	if active:
		anim.play_backwards("default")
	else:
		anim.play("default")
	active = !active
	emit_signal("toggled", active)

func highlight(active: bool):
	if active:
		anim.material.set_shader_parameter("width", 1.0)
	else:
		anim.material.set_shader_parameter("width", 0.0)
