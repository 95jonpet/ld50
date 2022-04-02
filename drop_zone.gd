extends Position2D

@export var radius: float = 16

func _draw() -> void:
#	draw_circle(Vector2.ZERO, radius, Color.BLANCHED_ALMOND)
	pass


func snap_distance_squared() -> float:
	return radius * radius


func select() -> void:
	for child in get_tree().get_nodes_in_group("zone"):
		child.deselect()
	modulate = Color.WEB_MAROON


func deselect() -> void:
	modulate = Color.WHITE
