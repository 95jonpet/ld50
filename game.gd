class_name Game
extends Node2D

const TILE_SCENE := preload("res://tiles/tile.tscn")
const BUILDING_TILE_SCENE := preload("res://tiles/building_tile.tscn")
const ROCK_TILE_SCENE := preload("res://tiles/rock_tile.tscn")
const BUNKER_TILE_SCENE := preload("res://tiles/bunker_tile.tscn")
const BOMB_SCENE := preload("res://units/bomb.tscn")
const TANK_UNIT_SCENE := preload("res://units/tank_unit.tscn")
const TENTS_TILE_SCENE := preload("res://tiles/tents_tile.tscn")

const GAME_WIDTH := 384
const GAME_HEIGHT := 216
const GRID_SIZE := 24
const GRID_GAP := 4
const TICK_SEQUENCE_START_TIME := 0.2 # In seconds.
const TICK_SEQUENCE_WAIT_TIME := 2.0 # In seconds.

@onready var enemy_units := $EnemyUnits
@onready var player_units := $PlayerUnits
@onready var tiles := $Tiles

@onready var level: Level = $Level
var can_start_tick_sequence := false
var required_tile_count: int
var plan_tiles: Array[Tile]

var levels := [
	{
		"name": "The planning",
		"description": "You are under attack!\nPlan your defence using your units.",
		"units": ["tank"],
		"tiles": [
			[null, "tank", "tents"],
		],
	},
	{
		"name": "Coordination",
		"description": "Units will fire from the top left to the bottom right.",
		"units": ["tank", "tank"],
		"tiles": [
			[null, null, "tank", null, "tents"],
		],
	},
	{
		"name": "Concrete curtain",
		"description": "Concrete buildings are great for protection.",
		"units": ["tank"],
		"tiles": [
			[null, "building", "tank", "building", "tents"],
		],
	},
	{
		"name": "4x4",
		"description": "Position is everything.",
		"units": ["tank", "tank"],
		"tiles": [
			[null, "tents", null, "tank"],
			[null, "tank", "building", "tents"],
			[null, null, "tents", "building"],
			[null, null, "tents", null],
		],
	},
	{
		"name": "The strip",
		"description": "",
		"units": ["tank"],
		"tiles": [
			[null, "tank", null, "building", null, null, "tank", "tents"],
		],
	},
	{
		"name": "4x4 v2",
		"description": "War changes things.",
		"units": ["tank", "tank", "tank"],
		"tiles": [
			[null, "tents", null, "tank"],
			[null, "tank", "building", "tents"],
			[null, null, "tents", "building"],
			[null, null, "tents", null],
		],
	},
	{
		"name": "Inversion",
		"description": "",
		"units": ["Tank", "tank"],
		"tiles": [
			[null, "Tank", null, "tents"],			
			["tank", "building", null, "tents"],
		],
	},
	{
		"name": "The second strip",
		"description": "",
		"units": ["tank", "Tank"],
		"tiles": [
			[null, "tank", null, "building", null, null, "tank", null, "tents"],
		],
	},
]
var level_index := 0

func _ready() -> void:
	reset_level()


func _on_start_button_pressed() -> void:
	end_deployment()


func level_completed() -> bool:
	return enemy_units.get_child_count() == 0


func level_failed() -> String:
	if get_tree().get_nodes_in_group("required_tile").size() != required_tile_count:
		return "Civilians were killed."
	
	if player_units.get_child_count() == 0:
		return "All units have been destroyed.\nHope is lost."
	
	return ""


func complete_level() -> void:
	$TransitionScreen.transition("Level complete!")
	await $TransitionScreen.transitioned
	
	level_index = wrapi(level_index + 1, 0, len(levels))
	reset_level()


func restart_level(reason: String) -> void:
	$TransitionScreen.transition("Game over!", reason)
	await $TransitionScreen.transitioned
	
	reset_level()


func reset_level() -> void:
	# Remove everything from the level.
	clear_children($Plan)
	clear_children(tiles)
	clear_children(enemy_units)
	clear_children(player_units)
	
	# Instantiate everything in the level.
	instantiate_grid_tiles()
	instantiate_plan_tiles()
	
	$UI/LevelDetails/LevelName.text = str(level_index + 1) + ". " + levels[level_index].name
	$UI/LevelDetails/LevelDescription.text = levels[level_index].description
	$UI/HBoxContainer/StartButton.disabled = true
	$Timer.start()


func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func instantiate_grid_tiles() -> void:
	# Calculate the level size.
	var current_level := levels[level_index]
	var x_size := len(current_level.tiles[0])
	var y_size := len(current_level.tiles)
	
	for row in current_level.tiles:
		x_size = max(x_size, len(row))
	
	var x_width := GRID_SIZE * x_size + (x_size - 1) * GRID_GAP
	var y_height := GRID_SIZE * y_size + (y_size - 1) * GRID_GAP
	
	var x_start := GAME_WIDTH / 2.0 - x_width / 2.0
	var y_start := GAME_HEIGHT / 2.0 - y_height / 2.0
	
	required_tile_count = 0
	for y in y_size:
		for x in x_size:
			var group := tiles
			var scene := TILE_SCENE
			var scene_scale = Vector2.ONE
			match current_level.tiles[y][x]:
				"building":
					scene = BUILDING_TILE_SCENE
				"Tank":
					scene = TANK_UNIT_SCENE
					scene_scale = Vector2(-1, 1)
					group = enemy_units
				"tank":
					scene = TANK_UNIT_SCENE
					group = enemy_units
				"tents":
					scene = TENTS_TILE_SCENE
				"none":
					scene = null
				null:
					pass # Intentionally left blank
				_:
					print_debug("Unknown level element: " + str(current_level.tiles[y][x]))
				
			if scene:
				var instance := scene.instantiate()
				instance.global_position = Vector2(
					x_start + x * (GRID_SIZE + GRID_GAP),
					y_start + y * (GRID_SIZE + GRID_GAP)
				).floor()
				instance.scale = scene_scale
				group.add_child(instance)
				
				if instance.is_in_group("required_tile"):
					required_tile_count += 1


func instantiate_plan_tiles() -> void:
	var current_level := levels[level_index]
	var plan_size := len(current_level.units)
	var plan_height = plan_size * GRID_SIZE + (plan_size - 1) * GRID_GAP
	
	for i in plan_size:
		var x_start := GRID_SIZE / 2.0 + GRID_GAP
		var y_start := GAME_HEIGHT / 2.0 - plan_height / 2.0
		
		var tile := TILE_SCENE.instantiate()
		tile.global_position = Vector2(x_start, y_start + i * (GRID_SIZE + GRID_GAP))
		$Plan.add_child(tile)
		
		var scene := TANK_UNIT_SCENE
		var scene_scale := Vector2.ONE
		match current_level.units[i]:
			"Tank":
				scene = TANK_UNIT_SCENE
				scene_scale = Vector2(-1, 1)
			"tank":
				scene = TANK_UNIT_SCENE
			_:
				print_debug("Unknown plan unit: " + str(current_level.units[i]))
		
		var unit := scene.instantiate()
		unit.global_position = tile.global_position
		unit.scale = scene_scale
		player_units.add_child(unit)
		plan_tiles.append(tile)
	
	for unit in enemy_units.get_children():
		unit.state_machine.transition_to("Idle")


func end_deployment() -> void:
	# Ensure that all units have been deployed.
	for tile in plan_tiles:
		if tile.is_blocked():
			return
	
	for unit in get_tree().get_nodes_in_group("unit"):
		unit.state_machine.transition_to("Idle")
	
	for tile in plan_tiles:
		tile.queue_free()
	plan_tiles.clear()
	
	await get_tree().create_timer(TICK_SEQUENCE_START_TIME).timeout
	can_start_tick_sequence = true
	await play_tick_sequence()


func play_tick_sequence() -> void:
	if not can_start_tick_sequence:
		return
	
	$UI/HBoxContainer/StartButton.disabled = true
	$Timer.stop()
	var units := get_tree().get_nodes_in_group("unit")
	units.sort_custom(compare_unit_positions)
	
	can_start_tick_sequence = false
	for unit in units:
		if not unit or unit.is_queued_for_deletion():
			continue
		unit.play_tick()
		await get_tree().create_timer(TICK_SEQUENCE_WAIT_TIME).timeout
		
		# Check for level completion.
		if level_completed():
			complete_level()
			return
		if level_failed():
			restart_level(level_failed())
			return
	can_start_tick_sequence = true
	$UI/HBoxContainer/StartButton.disabled = false
	$Timer.start()
	
	# Allow units to be redeployed.
	for child in player_units.get_children():
		var unit: Unit = child as Unit
		if not unit:
			print_debug(child)
			continue
		unit.state_machine.transition_to("Undeployed")


func compare_unit_positions(a: Node2D, b: Node2D) -> bool:
	if a.is_queued_for_deletion() or b.is_queued_for_deletion():
		return true
	
	if a.global_position.y < b.global_position.y:
		return true
	return a.global_position.x < b.global_position.x


func _on_timer_timeout() -> void:
	$UI/HBoxContainer/StartButton.disabled = false
	for tile in plan_tiles:
		if tile.is_blocked():
			$UI/HBoxContainer/StartButton.disabled = true
			break
