extends UnitState

const LERP_SPEED := 25

var selected := false
var previous_zone: Node2D
var rest_point: Vector2


func _ready() -> void:
	await super()
	rest_point = unit.global_position


func enter(_msg := {}) -> void:
	var rest_nodes := get_tree().get_nodes_in_group("zone")
	rest_point = unit.global_position if unit.rest_nodes.is_empty() else rest_nodes[0].global_position
	snap_to_zone()


func select() -> void:
	selected = true


func deselect() -> void:
	selected = false
	snap_to_zone()


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


func _on_unit_click_pressed(Unit) -> void:
	select()


func _on_unit_click_released(Unit) -> void:
	deselect()
