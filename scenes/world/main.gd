extends Node2D

@onready var fixer = $"Fixer"

var final = false

func _ready() -> void:
	GAMEMANAGER.all_towers_destroyed.connect(_on_all_towers_destroyed)
	fixer.visible = false
	fixer.monitoring = false


func _process(delta: float) -> void:
	if final == true and Input.is_action_just_pressed("SPACE"):
		GAMEMANAGER.trigger_victory()

func _on_all_towers_destroyed() -> void:
	fixer.visible = true  # muestra el fixer
	fixer.monitoring = true

# Cuando el jugador toca el fixer, repara el mundo
func _on_fixer_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GAMEMANAGER.notificar_reparar_mundo()
		fixer.visible = false
		final = true 
