extends Control

var max_health     : float = 100
var current_health : float = 100

func clamp_health():
	current_health = clamp(current_health, 0, max_health)

func _on_apply_damage_pressed():
	current_health -= float($LineEdit.text)
	
func _on_apply_heal_pressed():
	current_health += float($LineEdit.text)

func _process(delta):
	clamp_health()
