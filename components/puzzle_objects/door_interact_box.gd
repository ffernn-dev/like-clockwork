extends Area2D

func highlight(active: bool):
	if active:
		get_parent().open(true)
	else:
		get_parent().close(true)
