extends CharacterBody2D

@onready var _animation_player: AnimationPlayer = $AnimationPlayer

@onready var sprite_idle: Sprite2D = $SpritePlayer
@onready var sprite_right: Sprite2D = $SpriteWR
@onready var sprite_left: Sprite2D = $SpriteWl
@onready var sprite_down: Sprite2D = $SpriteWD
@onready var sprite_up: Sprite2D = $SpriteWU
@onready var sprite_shoot_right: Sprite2D = $SpriteSR
@onready var sprite_shoot_left: Sprite2D = $SpriteSL

@export var speed: float = 400.0
@export var life: float = 100
@export var bullet_scene: PackedScene
@export var spawn_distance: float = 40.0

@export var max_ammo: int = 30
@export var reload_time: float = 3.0

var last_direction: Vector2 = Vector2.RIGHT
var ammo: int = 20
var reloading: bool = false
var is_shooting: bool = false

@onready var reload_timer: Timer = $ReloadTimer

func _ready() -> void:
	reload_timer.wait_time = reload_time
	reload_timer.one_shot = true
	reload_timer.timeout.connect(_on_reload_finished)
	_animation_player.animation_finished.connect(_on_animation_finished)
	_show_only(sprite_idle)

func _physics_process(delta: float) -> void:
	var direction := Vector2(
		Input.get_axis("IZQUIERDA", "DERECHA"),
		Input.get_axis("ARRIBA", "ABAJO")
	)

	velocity = direction.normalized() * speed
	move_and_slide()

	if direction != Vector2.ZERO:
		last_direction = direction.normalized()

	if is_shooting:
		return

	if direction != Vector2.ZERO:
		_play_walk_animation(direction)
	else:
		_show_only(sprite_idle)
		_play_animation_if_needed("idle")

func _play_walk_animation(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			_show_only(sprite_right)
			_play_animation_if_needed("Walking_Right")
		else:
			_show_only(sprite_left)
			_play_animation_if_needed("Walking_Left")
	else:
		if direction.y > 0:
			_show_only(sprite_down)
			_play_animation_if_needed("Walking_Down")
		else:
			_show_only(sprite_up)
			_play_animation_if_needed("Walking_Up")

func _play_shoot_animation() -> void:
	is_shooting = true

	if last_direction.x >= 0:
		_show_only(sprite_shoot_right)
		_animation_player.play("Shoot_Right")
	else:
		_show_only(sprite_shoot_left)
		_animation_player.play("Shoot_Left")

func _show_only(sprite_to_show: Sprite2D) -> void:
	sprite_idle.visible = false
	sprite_right.visible = false
	sprite_left.visible = false
	sprite_down.visible = false
	sprite_up.visible = false
	sprite_shoot_right.visible = false
	sprite_shoot_left.visible = false

	sprite_to_show.visible = true

func _play_animation_if_needed(animation_name: String) -> void:
	if _animation_player.current_animation != animation_name:
		_animation_player.play(animation_name)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		shoot()

func shoot() -> void:
	if bullet_scene == null or reloading or is_shooting:
		return

	if ammo <= 0:
		start_reload()
		return

	var bullet := bullet_scene.instantiate()
	bullet.global_position = global_position + last_direction * spawn_distance
	bullet.direction = last_direction
	bullet.rotation = last_direction.angle()
	bullet.from_player = true
	bullet.power = 20
	get_parent().add_child(bullet)

	ammo -= 1
	_play_shoot_animation()

	if ammo <= 0:
		start_reload()

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Shoot_Right" or anim_name == "Shoot_Left":
		is_shooting = false

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
