extends Position2D

@export var radius: float = 16

var blocked := false

func snap_distance_squared() -> float:
	return radius * radius


func block() -> void:
	blocked = true


func unblock() -> void:
	blocked = false
