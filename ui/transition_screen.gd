class_name TransitionScreen
extends CanvasLayer

signal transitioned()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_to_black":
		await get_tree().create_timer(0.5).timeout
		transitioned.emit()
		await get_tree().create_timer(0.5).timeout
		$AnimationPlayer.play("fade_to_normal")


func transition(title: String = "", message: String = "") -> void:
	$AnimationPlayer.play("fade_to_black")
	$VBoxContainer/Title.text = title
	$VBoxContainer/Message.text = message
