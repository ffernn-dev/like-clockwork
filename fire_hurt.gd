class_name FireHurt extends StaticBody2D

func disable():
	$CollisionShape2D.disabled = true
	get_parent().lifetime = 0.5
