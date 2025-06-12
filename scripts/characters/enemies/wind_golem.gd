class_name WindGolem extends BaseEnemy

func setup_character():
	name = "Wind Golem"
	health = 50
	max_health = 50
	
	damage = 6
	defense = 2
	
	normal_speed = 60
	speed = normal_speed
	run_speed = (normal_speed * 2)
