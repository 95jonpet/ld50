extends Node2D

const BOMB_SCENE := preload("res://units/bomb.tscn")
const TILE_SCENE := preload("res://tiles/tile.tscn")

func _init() -> void:
	instantiate_grid_tiles()
	instantiate_plan_tiles()


func instantiate_grid_tiles() -> void:
	var n := 6
	var offset := 24 + 4
	var width := 384
	var height := 216
	
	for x in range(0, n):
		for y in range(0, n):
			var x_start := width / 2 - (n * offset) / 2
			var y_start := height / 2 - (n * offset) / 2
			
			var tile := TILE_SCENE.instantiate()
			tile.global_position = Vector2(x_start + x * offset, y_start + y * offset)
			add_child(tile)
	
	var bomb = BOMB_SCENE.instantiate()
	bomb.global_position = Vector2(width / 2 - 16, height / 2 - 16)
	add_child(bomb)


func instantiate_plan_tiles() -> void:
	var n := 7
	var offset := 24 + 4
	var width := 64
	var height := 216
	
	for i in range(0, n):
		var x_start := 8
		var y_start := height / 2 - (n * offset) / 2
		
		var tile := TILE_SCENE.instantiate()
		tile.global_position = Vector2(x_start, y_start + i * offset)
		add_child(tile)
