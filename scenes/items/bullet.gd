extends CharacterBody2D

@export var speed: float = 500.0
@export var power: int = 20       # 20 si jugador, 10 si enemigo
@export var from_player: bool = true

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	rotation = direction.angle()
	# Agrega el grupo por código como respaldo
	add_to_group("bullet")

func _physics_process(delta: float) -> void:
	velocity = direction * speed
	var collision := move_and_collide(velocity * delta)

	if collision:
		var hit := collision.get_collider()

		if from_player and hit.is_in_group("enemy"):
			hit.take_damage(power)
			queue_free()
		elif not from_player and hit.is_in_group("player"):
			hit.take_damage(power)
			queue_free()
		elif not hit.is_in_group("enemy") and not hit.is_in_group("player") and not hit.is_in_group("bullet"):
			queue_free() # impactó pared u otro objeto




func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
