extends Area2D

var can_interact = false

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		can_interact = true


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"):
		can_interact = false
