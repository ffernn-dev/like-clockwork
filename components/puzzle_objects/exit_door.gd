class_name ExitDoor extends "res://components/door.gd"

var closing := false

@export var lever: Lever
var leverless

func _ready():
	if lever:
		lever.toggled.connect(_on_door_toggled)
		leverless = false
		anim.play("locked")
	else:
		anim.play("closed")
		leverless = true

func open(without_key := false):
	if leverless or not without_key:
		anim.play("open")
	

func close(without_key := false):
	if leverless or not without_key:
		closing = true
		anim.play_backwards("open")


func _on_sprite_animation_finished():
	if closing:
		if leverless:
			anim.play("closed")
		else:
			anim.play("locked")
	closing = false
