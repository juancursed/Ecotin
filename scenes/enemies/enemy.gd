extends CharacterBody2D

@export var speed: float = 120.0
@export var life: float = 75
@export var bullet_scene: PackedScene  # arrastra Bullet.tscn aquí
@export var shoot_interval: float = 2.0  # segundos entre disparos
@export var spawn_distance: float = 40.0
@export var stop_distance: float = 110.0 
@export var comfort_margin: float = 60.0  

var player: Node2D = null
var shoot_timer: float = 0.0

func _physics_process(delta: float) -> void:
	if player == null:
		return
	var dist := global_position.distance_to(player.global_position)
	print("dist: ", dist, " stop: ", stop_distance)
	var direction := (player.global_position - global_position).normalized()


	if dist > stop_distance + comfort_margin:
		# Muy lejos — se acerca
		velocity = direction * speed
	elif dist < stop_distance - comfort_margin:
		# Muy cerca — retrocede suave
		velocity = -direction * (speed * 0.3)
	else:
		# En la zona de confort — se queda quieto
		velocity = Vector2.ZERO

	
	move_and_slide()

	# Disparo periódico
	shoot_timer += delta
	if shoot_timer >= shoot_interval:
		shoot_timer = 0.0
		shoot()
	
	#print("Vida enemigo: ", life)

func shoot() -> void:
	if bullet_scene == null or player == null:
		return
	
	var shoot_dir := (player.global_position - global_position).normalized()
	var bullet := bullet_scene.instantiate()
	
	bullet.global_position = global_position + shoot_dir * spawn_distance
	bullet.direction = shoot_dir
	bullet.rotation = shoot_dir.angle()
	bullet.from_player = false
	bullet.power = 10
	get_parent().add_child(bullet)

func take_damage(amount: int) -> void:
	life -= amount
	if life <= 0:
		queue_free()  # el enemigo desaparece

func _on_area_detection_enemy_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body as CharacterBody2D
