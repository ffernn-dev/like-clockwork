class_name Lever extends "res://components/Interactable.gd"

signal toggled(state: bool)

var active := false

func interact(actor):
	active = !active
	print("active")
	emit_signal("toggled", active)
