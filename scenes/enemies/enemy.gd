extends CharacterBody2D

@export var speed: float = 120.0
@export var life: float = 75
@export var bullet_scene: PackedScene
@export var shoot_interval: float = 2.0
@export var spawn_distance: float = 40.0

@onready var _animation_player: AnimationPlayer = $AnimationPlayer

@onready var sprite_idle: Sprite2D = $SpriteEnemy
@onready var sprite_right: Sprite2D = $SpriteWR
@onready var sprite_left: Sprite2D = $SpriteWL
@onready var sprite_down: Sprite2D = $SpriteWD
@onready var sprite_up: Sprite2D = $SpriteWU
@onready var sprite_shoot_right: Sprite2D = $SpriteSR
@onready var sprite_shoot_left: Sprite2D = $SpriteSL

var player: Node2D = null
var shoot_timer: float = 0.0
var last_direction: Vector2 = Vector2.RIGHT
var is_shooting: bool = false

func _ready() -> void:
	_animation_player.animation_finished.connect(_on_animation_finished)
	_show_only(sprite_idle)

func _physics_process(delta: float) -> void:
	if player == null:
		velocity = Vector2.ZERO
		move_and_slide()
		_show_only(sprite_idle)
		_play_animation_if_needed("idle")
		return

	var direction := (player.global_position - global_position).normalized()
	last_direction = direction

	velocity = direction * speed
	move_and_slide()

	shoot_timer += delta
	if shoot_timer >= shoot_interval and not is_shooting:
		shoot_timer = 0.0
		shoot()
		return

	if is_shooting:
		return

	_play_walk_animation(direction)

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

func shoot() -> void:
	if bullet_scene == null or player == null:
		return

	var shoot_dir := (player.global_position - global_position).normalized()
	last_direction = shoot_dir

	var bullet := bullet_scene.instantiate()
	bullet.global_position = global_position + shoot_dir * spawn_distance
	bullet.direction = shoot_dir
	bullet.rotation = shoot_dir.angle()
	bullet.from_player = false
	bullet.power = 10
	get_parent().add_child(bullet)

	_play_shoot_animation()

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Shoot_Right" or anim_name == "Shoot_Left":
		is_shooting = false

func take_damage(amount: int) -> void:
	life -= amount
	if life <= 0:
		queue_free()

func _on_area_detection_enemy_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body as CharacterBody2D

func _on_area_detection_enemy_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
