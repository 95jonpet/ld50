extends CharacterBody2D

const SPEED := 48
const EXPLOSION_SCENE := preload("res://effects/explosion.tscn")
const TILE_SCENE := preload("res://tiles/tile.tscn")

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer

func _ready() -> void:
	velocity = Vector2(SPEED, 0)
	await get_tree().create_timer(0.4).timeout
	collision_shape.set_deferred("disabled", false)


func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision:
		var colliding_object := collision.get_collider()
		if colliding_object.is_in_group("destructible_tile"):
			var tile = TILE_SCENE.instantiate()
			tile.global_position = colliding_object.global_position
			colliding_object.add_sibling(tile)
			colliding_object.queue_free()
		if colliding_object.is_in_group("unit"):
			colliding_object.destroy()
		explode()


func _on_timer_timeout() -> void:
	queue_free()


func explode() -> void:
	var explosion := EXPLOSION_SCENE.instantiate()
	explosion.global_position = global_position
	add_sibling(explosion)
	timer.stop()
	queue_free()
