extends Area2D

const FILE_BEGIN = "res://scenes/levels/level_"
var can_interact = false

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"): 
		can_interact = true

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"):
		can_interact = false

func _process(_delta): 
	if can_interact and Input.is_action_just_pressed("Interact"):
		var current_scene_file = get_tree().current_scene.scene_file_path
		var next_level_number = current_scene_file.to_int() - 2
		
		var next_level_path = FILE_BEGIN + str(next_level_number) + ".tscn"
		get_tree().change_scene_to_file(next_level_path)
