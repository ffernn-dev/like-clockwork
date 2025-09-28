class_name ButtonDoor extends "res://components/door.gd"

var closing := false

@export var button: GameButton
var buttonless

func _ready():
	if button:
		button.toggled.connect(_on_door_toggled)
		buttonless = false
	else:
		buttonless = true
	anim.play("closed")

func open(without_key := false):
	if buttonless or not without_key:
		anim.play("open")
	

func close(without_key := false):
	if buttonless or not without_key:
		closing = true
		anim.play_backwards("open")


func _on_sprite_animation_finished():
	if closing:
		anim.play("closed")
	closing = false
