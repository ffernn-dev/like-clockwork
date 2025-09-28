class_name GameButton extends "res://components/interactable.gd"

signal toggled(state: bool)

var active := false
@onready var anim := $Sprite
@onready var collider = $StaticBody2D

func interact(actor, state = false):
	active = state
	if active:
		anim.play("pressed")
		collider.get_child(0).disabled = true
		collider.get_child(1).disabled = false
	else:
		anim.play("default")
		collider.get_child(1).disabled = true
		collider.get_child(0).disabled = false
	emit_signal("toggled", active)
