extends UnitState

func enter(_msg := {}) -> void:
	unit.animation_player.play("idle")


func exit() -> void:
	unit.animation_player.stop()
