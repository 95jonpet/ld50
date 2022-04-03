extends UnitState

const CLICK_SOUND := preload("res://units/click.wav")
const LERP_SPEED := 25

var selectable := true
var selected := false
var previous_zone: Node2D
var rest_point: Vector2


func _ready() -> void:
	await super()
	rest_point = unit.global_position
	snap_to_zone()


func enter(_msg := {}) -> void:
	selectable = true
	if unit.animation_player.has_animation("undeployed"):
		unit.animation_player.play("undeployed")
	
	var rest_nodes := get_tree().get_nodes_in_group("zone")
	rest_point = unit.global_position if unit.rest_nodes.is_empty() else rest_nodes[0].global_position
	snap_to_zone()


func exit(_msg := {}) -> void:
	selectable = false


func select() -> void:
	if selected or not selectable:
		return
	
	selected = true
	play_sound_once(CLICK_SOUND)


func deselect() -> void:
	if not selected or not selectable:
		return
	
	selected = false
	play_sound_once(CLICK_SOUND)
	snap_to_zone()


func play_sound_once(stream: AudioStream) -> void:
	unit.audio_player.stream = stream
	unit.audio_player.play()


func physics_update(delta: float) -> void:
	var target_position := unit.get_global_mouse_position() if selected else rest_point
	unit.global_position = unit.global_position.lerp(target_position, LERP_SPEED * delta)


func snap_to_zone() -> void:
	for child in get_tree().get_nodes_in_group("zone"):
		if child.blocked or child == previous_zone:
			continue
		
		var distance_squared := unit.global_position.distance_squared_to(child.global_position)
		if distance_squared < child.snap_distance_squared():
			if previous_zone:
				previous_zone.unblock()
			child.block()
			rest_point = child.global_position
			previous_zone = child
			return # Only snap to the first zone.


func _on_unit_click_pressed(_unit: Unit) -> void:
	select()


func _on_unit_click_released(_unit: Unit) -> void:
	deselect()
