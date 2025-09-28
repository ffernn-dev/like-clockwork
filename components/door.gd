class_name Door extends Node2D

@export var anim: AnimatedSprite2D

func _ready():
	if not anim:
		push_warning("Door needs an AnimatedSprite2D assigned to play animations")

func _on_door_toggled(state: bool):
	if state:
		open()
	else:
		close()

func open():
	push_warning("Door opening not implemented")

func close():
	push_warning("Door closing not implemented")
