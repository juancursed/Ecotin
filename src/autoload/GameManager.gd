extends Node

signal all_towers_destroyed

var towers: Array = []
var all_towers: Array = []

func register_tower(tower: Node) -> void:
	towers.append(tower)
	all_towers.append(tower)

func notify_tower_destroyed() -> void:
	# Filtra torres que siguen vivas
	towers = towers.filter(func(t): return is_instance_valid(t) and not t.is_destroyed)
	
	if towers.is_empty():
		emit_signal("all_towers_destroyed")
		

func notificar_reparar_mundo() -> void:
	for tower in all_towers:
		if is_instance_valid(tower):
			tower.set_aeolic_sprite()
	
	#trigger_victory()
	

func trigger_victory() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/victory.tscn")
