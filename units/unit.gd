class_name Unit
extends CharacterBody2D

signal click_pressed(Unit)
signal click_released(Unit)

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var state_machine: StateMachine = $StateMachine


func _input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		click_released.emit(self)


func _on_unit_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		click_pressed.emit(self)


func destroy() -> void:
	queue_free()


func play_tick() -> void:
	if animation_player.has_animation("play_tick"):
		animation_player.play("play_tick")
		await animation_player.animation_finished
