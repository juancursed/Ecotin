extends Node

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			restart()

func _on_restart_button_pressed() -> void:
	restart()

func restart() -> void:
	get_tree().change_scene_to_file("res://scenes/world/main.tscn")
