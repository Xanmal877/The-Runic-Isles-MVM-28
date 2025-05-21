extends Control

var max_health     : float = 100
var health : float = 100

func clamp_health():
	health = clamp(health, 0, max_health)

func _on_apply_damage_pressed():
	health -= float($LineEdit.text)
	
func _on_apply_heal_pressed():
	health += float($LineEdit.text)

@warning_ignore("unused_parameter")
func _process(delta):
	clamp_health()
