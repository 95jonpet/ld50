class_name Tile, "res://tiles/tile_outline.png"
extends StaticBody2D

@onready var drop_zone: DropZone = $DropZone


func is_blocked() -> bool:
	return drop_zone.blocked
