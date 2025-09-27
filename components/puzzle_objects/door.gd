extends StaticBody2D

@export var lever: Lever
var leverless

var closing := false

@onready var anim := $Sprite

func _ready():
	if lever:
		lever.toggled.connect(_on_lever_toggled)
		leverless = false
		anim.play("locked")
	else:
		anim.play("closed")
		leverless = true

func _on_lever_toggled(state: bool):
	if state:
		open()
	else:
		close()

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
