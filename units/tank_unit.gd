class_name TankUnit, "res://units/tank_unit.png"
extends Unit

const EXPLOSION_SOUND := preload("res://units/explosion.wav")
const JAVELIN_SCENE := preload("res://units/javelin.tscn")

func fire() -> void:
	audio_player.stream = EXPLOSION_SOUND
	audio_player.play()
	
	var javelin = JAVELIN_SCENE.instantiate()
	javelin.global_position = $ProjectilePosition.global_position
	javelin.scale = scale
	get_parent().add_sibling(javelin)
