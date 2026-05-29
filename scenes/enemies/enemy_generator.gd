extends StaticBody2D

@export var enemy_scene: PackedScene        # arrastra Enemy.tscn
@export var destroyed_sprite: Texture2D     # sprite de ruina/basura
@export var aeolic_sprite: Texture2D  
@export var life: float = 10
@export var spawn_interval: float = 3.0    # segundos entre spawns
@export var max_enemies: int = 12           # límite de enemigos vivos a la vez
@export var spawn_radius: float = 60.0     # radio de spawn alrededor

var is_destroyed: bool = false
var spawned_enemies: Array = []
var player_in_range: bool = false

@onready var sprite: Sprite2D = $SpriteEnemyGenerator
@onready var collision: CollisionShape2D = $CollisionEnemyGenerator
@onready var spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	GAMEMANAGER.register_tower(self)
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_destroyed:
		player_in_range = true
		spawn_timer.start()  # empieza a spawnear solo cuando detecta al jugador

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		spawn_timer.stop()  # deja de spawnear si el jugador se va

func take_damage(amount: int) -> void:
	print("Vida Torre: ", life)
	if is_destroyed:
		return
	life -= amount
	if life <= 0:
		destroy()

func destroy() -> void:
	is_destroyed = true
	spawn_timer.stop()

	# Cambia al sprite de ruina
	if destroyed_sprite != null:
		sprite.texture = destroyed_sprite
		sprite.scale.x = 0.5
		sprite.scale.y = 0.5
		$".".remove_from_group("enemy")
		collision.scale = Vector2(0.5,0.5)
	else:
		sprite.modulate = Color(0.4, 0.4, 0.4)  # gris si no hay sprite
		
	GAMEMANAGER.notify_tower_destroyed()

	# Desactiva la colisión (ya no bloquea ni recibe daño)
	#collision.set_deferred("disabled", true)

	# Los enemigos ya spawnados siguen vivos (opcional: matarlos)
	# for e in spawned_enemies: if is_instance_valid(e): e.queue_free()

func _on_spawn_timer_timeout() -> void:
	if is_destroyed or enemy_scene == null:
		return

	# Limpia referencias inválidas (enemigos muertos)
	spawned_enemies = spawned_enemies.filter(
		func(e): return is_instance_valid(e)
	)

	if spawned_enemies.size() >= max_enemies:
		return  # ya hay suficientes, espera

	spawn_enemy()

func spawn_enemy() -> void:
	var enemy := enemy_scene.instantiate()
	
	# Intenta hasta 10 veces encontrar un punto libre
	var spawn_pos := _get_safe_spawn_position()
	enemy.global_position = spawn_pos
	
	# Espera un frame antes de añadir para evitar solapamiento de física
	get_parent().add_child(enemy)
	spawned_enemies.append(enemy)

func _get_safe_spawn_position() -> Vector2:
	var min_distance: float = 80.0   # distancia mínima desde el centro de la torre
	var max_distance: float = 130.0  # distancia máxima

	# 8 puntos fijos en círculo como opciones de spawn
	var attempts := 8
	for i in range(attempts):
		var angle := (TAU / attempts) * i + randf() * 0.3  # pequeña variación
		var distance := randf_range(min_distance, max_distance)
		var candidate := global_position + Vector2.from_angle(angle) * distance

		# Verifica que no haya un cuerpo físico en ese punto
		var space := get_world_2d().direct_space_state
		var query := PhysicsPointQueryParameters2D.new()
		query.position = candidate
		query.collision_mask = 0b0110  # capas de enemy y paredes
		query.exclude = [self.get_rid()]

		var results := space.intersect_point(query)
		if results.is_empty():
			return candidate  # punto libre encontrado

	# Si ningún punto está libre, usa el más alejado como fallback
	return global_position + Vector2.from_angle(randf() * TAU) * max_distance


func set_aeolic_sprite() -> void:
	if aeolic_sprite != null:
		sprite.texture = aeolic_sprite
