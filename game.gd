extends Node2D

const TILE_SCENE := preload("res://tiles/tile.tscn")
const BOMB_SCENE := preload("res://units/bomb.tscn")

func _init() -> void:
	instantiate_grid_tiles()
	instantiate_plan_tiles()


func _on_start_button_pressed() -> void:
	end_deployment()


func instantiate_grid_tiles() -> void:
	var n := 6
	var offset := 24 + 4
	var width := 384
	var height := 216
	
	for x in range(0, n):
		for y in range(0, n):
			var x_start := width / 2 - (n * offset) / 2
			var y_start := height / 2 - (n * offset) / 2 + 16
			
			var tile := TILE_SCENE.instantiate()
			tile.global_position = Vector2(x_start + x * offset, y_start + y * offset)
			add_child(tile)


func instantiate_plan_tiles() -> void:
	var n := 6
	var offset := 24 + 4
	var width := 64
	var height := 216
	
	for i in range(0, n):
		var x_start := 12 + 4
		var y_start := height / 2 - (n * offset) / 2 + 16
		
		var tile := TILE_SCENE.instantiate()
		tile.global_position = Vector2(x_start, y_start + i * offset)
		add_child(tile)
		
		var bomb = BOMB_SCENE.instantiate()
		bomb.global_position = Vector2(x_start, y_start + i * offset)
		add_child(bomb)


func end_deployment() -> void:
	for unit in get_tree().get_nodes_in_group("unit"):
		unit.state_machine.transition_to("Idle")
