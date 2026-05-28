# Player.gd
extends CharacterBody2D

@export var speed: float = 400.0
@export var life: float = 100
@export var bullet_scene: PackedScene
@export var spawn_distance: float = 40.0

# --- Disparo ---
@export var max_ammo: int = 12
@export var reload_time: float = 3.0

var last_direction: Vector2 = Vector2.RIGHT
var ammo: int = 20
var reloading: bool = false

@onready var reload_timer: Timer = $ReloadTimer

func _ready() -> void:
	reload_timer.wait_time = reload_time
	reload_timer.one_shot = true
	reload_timer.timeout.connect(_on_reload_finished)

func _physics_process(delta: float) -> void:
	var direction := Vector2(
		Input.get_axis("IZQUIERDA", "DERECHA"),
		Input.get_axis("ARRIBA", "ABAJO")
	)
	velocity = direction.normalized() * speed
	move_and_slide()

	if direction != Vector2.ZERO:
		last_direction = direction.normalized()

func _unhandled_input(event: InputEvent) -> void:
	# Filtra SOLO el botón izquierdo del mouse, sin afectar movimiento
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		shoot()

func shoot() -> void:
	if bullet_scene == null or reloading:
		return

	if ammo <= 0:
		start_reload()
		return

	var bullet := bullet_scene.instantiate()
	# Usa last_direction que viene del movimiento, nunca del mouse
	bullet.global_position = global_position + last_direction * spawn_distance
	bullet.direction = last_direction
	bullet.rotation = last_direction.angle()
	bullet.from_player = true
	bullet.power = 20
	get_parent().add_child(bullet)

	ammo -= 1
	#print("Balas: ", ammo, " / ", max_ammo)

	if ammo <= 0:
		start_reload()

func start_reload() -> void:
	reloading = true
	print("Recargando...")
	reload_timer.start()

func _on_reload_finished() -> void:
	ammo = max_ammo
	reloading = false
	print("Recarga lista — balas: ", ammo)

func take_damage(amount: int) -> void:
	life -= amount
	if life <= 0:
		game_over()

func game_over() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/game_over.tscn")
