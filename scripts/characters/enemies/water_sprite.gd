class_name WaterSprite extends BaseEnemy

func setup_character():
	name = "Water Sprite"
	health = 50
	max_health = 50

	damage = 6
	defense = 2

	normal_speed = 60
	speed = normal_speed
	run_speed = (normal_speed * 2)

	skill_manager.emit_signal("addSkill", "Basic Attack")
	skill_manager.emit_signal("addSkill", "Water Bolt")
