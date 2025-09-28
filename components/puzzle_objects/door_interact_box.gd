extends Area2D

func highlight(active: bool):
	if active:
		get_parent().open(true)
		get_parent().get_child(0).material.set_shader_parameter("width", 1.0)
	else:
		get_parent().close(true)
		get_parent().get_child(0).material.set_shader_parameter("width", 0.0)

func interact(actor, _state = false):
	if get_parent().state:
		EventBus.emit_signal("level_complete")
