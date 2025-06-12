class_name WaterGolem extends BaseEnemy


func setup_character():
	name = "Water Golem"
	health = 50
	max_health = 50
	
	damage = 6
	defense = 2
	
	normal_speed = 60
	speed = normal_speed
	run_speed = (normal_speed * 2)
