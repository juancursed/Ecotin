extends Node2D

@onready var fixer = $"Fixer"

func _ready() -> void:
	GAMEMANAGER.all_towers_destroyed.connect(_on_all_towers_destroyed)
	fixer.visible = false

func _on_all_towers_destroyed() -> void:
	fixer.visible = true  # muestra el fixer

# Cuando el jugador toca el fixer, repara el mundo
func _on_fixer_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GAMEMANAGER.notificar_reparar_mundo()
		fixer.visible = false
