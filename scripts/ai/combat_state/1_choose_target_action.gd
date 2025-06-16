class_name ChooseTargetAction extends StateMachine

@warning_ignore("unused_signal")
signal targetChosen

var target: BaseCharacter = null
#var allyToHeal: BaseCharacter = null

func HandleState() -> bool:
	agent.isProcessingState = true
	target = null

	agent.enemies_detected = agent.enemies_detected.filter(is_instance_valid)

	if EnemyLogic():
		agent.current_combat_target = target
	else:
		agent.current_combat_target = null
		return false

	agent.isProcessingState = false
	agent.set_task("Pick Skill")
	emit_signal("targetChosen")
	return true

func EnemyLogic() -> bool:
	var highPriorityEnemies = []
	var closestDistance = INF
	var found = false
	for enemy in agent.enemies_detected:
		if enemy.health <= 0:
			continue
		var distance = agent.global_position.distance_squared_to(enemy.global_position)
		if enemy.health < enemy.max_health * 0.25:
			highPriorityEnemies.append([enemy, distance])
		elif distance < closestDistance:
			closestDistance = distance
			target = enemy
			found = true
	if not highPriorityEnemies.is_empty():
		target = highPriorityEnemies.reduce(
			func(current, pair): return pair if pair[1] < current[1] else current, 
			highPriorityEnemies[0])[0]
		return true
	return found
