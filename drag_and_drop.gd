extends Node2D

const LERP_SPEED := 25

var selected: bool = false
var rest_point: Vector2 = Vector2.ZERO
var rest_nodes: Array[Node2D] = []

func _ready() -> void:
	rest_nodes = get_tree().get_nodes_in_group("zone")
	rest_point = global_position if rest_nodes.is_empty() else rest_nodes[0].global_position
	snap_to_zone()


func _on_area_2d_input_event(_viewport: Node, _event: InputEvent, _shape_idx: int) -> void:
	if Input.is_action_just_pressed("click"):
		selected = true


func _physics_process(delta: float) -> void:
	var target_position := get_global_mouse_position() if selected else rest_point
	global_position = global_position.lerp(target_position, LERP_SPEED * delta)


func _input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		selected = false
		snap_to_zone()


func snap_to_zone() -> void:
	for child in rest_nodes:
		var distance_squared := global_position.distance_squared_to(child.global_position)
		if distance_squared < child.snap_distance_squared():
			child.select()
			rest_point = child.global_position
			return # Only snap to the first zone.
