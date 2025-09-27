extends StaticBody2D

@export var lever: Lever

@onready var anim := $Sprite

func _ready():
	lever.toggled.connect(_on_lever_toggled)

func _on_lever_toggled(state: bool):
	if state:
		open()
	else:
		close()

func open():
	anim.play("open")

func close():
	anim.play("locked")
