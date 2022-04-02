extends Node2D

const TILE_SCENE := preload("res://tiles/tile.tscn")
const BUILDING_TILE_SCENE := preload("res://tiles/building_tile.tscn")
const ROCK_TILE_SCENE := preload("res://tiles/rock_tile.tscn")
const BOMB_SCENE := preload("res://units/bomb.tscn")
const TANK_UNIT_SCENE := preload("res://units/tank_unit.tscn")

const TICK_SEQUENCE_START_TIME := 0.2 # In seconds.
const TICK_SEQUENCE_WAIT_TIME := 0.2 # In seconds.

var can_start_tick_sequence := false

func _init() -> void:
	instantiate_grid_tiles()
	instantiate_plan_tiles()


func _on_start_button_pressed() -> void:
	end_deployment()


func _on_play_tick_button_pressed() -> void:
	play_tick_sequence()


func instantiate_grid_tiles() -> void:
	var n := 6
	var offset := 24 + 4
	var width := 384
	var height := 216
	
	for x in range(0, n):
		for y in range(0, n):
			var x_start := width / 2.0 - (n * offset) / 2.0
			var y_start := height / 2.0 - (n * offset) / 2.0 + 16
			
			var tile := ROCK_TILE_SCENE.instantiate() if randf() < 0.2 else TILE_SCENE.instantiate()
			tile.global_position = Vector2(x_start + x * offset, y_start + y * offset)
			add_child(tile)


func instantiate_plan_tiles() -> void:
	var n := 6
	var offset := 24 + 4
	var height := 216
	
	for i in range(0, n):
		var x_start := 12 + 4
		var y_start := height / 2.0 - (n * offset) / 2.0 + 16
		
		var tile := TILE_SCENE.instantiate()
		tile.global_position = Vector2(x_start, y_start + i * offset)
		add_child(tile)
		
		var item = TANK_UNIT_SCENE.instantiate() if i % 2 == 0 else BOMB_SCENE.instantiate()
		item.global_position = Vector2(x_start, y_start + i * offset)
		add_child(item)


func end_deployment() -> void:
	for unit in get_tree().get_nodes_in_group("unit"):
		unit.state_machine.transition_to("Idle")
	
	await get_tree().create_timer(TICK_SEQUENCE_START_TIME).timeout
	can_start_tick_sequence = true
	await play_tick_sequence()


func play_tick_sequence() -> void:
	if not can_start_tick_sequence:
		return
	
	can_start_tick_sequence = false
	for unit in get_tree().get_nodes_in_group("unit"):
		await unit.play_tick()
		await get_tree().create_timer(TICK_SEQUENCE_WAIT_TIME).timeout
	can_start_tick_sequence = true
