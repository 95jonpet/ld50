extends Unit

const JAVELIN_SCENE := preload("res://units/javelin.tscn")

func fire() -> void:
	var javelin = JAVELIN_SCENE.instantiate()
	javelin.global_position = global_position
	add_sibling(javelin)
