class_name UnitState
extends State

var unit: Unit


func _ready() -> void:
	await owner._ready
	unit = owner as Unit
	assert(unit != null)
