class_name DropZone
extends Position2D

@export var blocked: bool = false
@export var radius: float = 16

func snap_distance_squared() -> float:
	return radius * radius


func block() -> void:
	blocked = true


func unblock() -> void:
	blocked = false
