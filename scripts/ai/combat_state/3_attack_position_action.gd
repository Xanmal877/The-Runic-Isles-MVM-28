class_name CombatPositioningAction extends StateMachine

signal positionComplete

var move_speed: float = 75.0
var acceptable_range: float = 60.0  # Default melee range

func HandleState() -> void:
	agent.isProcessingState = true
	
	# Check if we have a valid target and skill
	if not is_instance_valid(agent.current_combat_target) or not agent.skill_manager.currentSkill:
		agent.velocity = Vector2.ZERO
		agent.direction = Vector2.ZERO
		agent.isProcessingState = false
		agent.set_task("Choose Target")
		positionComplete.emit()
		return
	
	# Get skill range - USE SWINGLENGTH FOR MELEE
	var skill_range = acceptable_range  # Default fallback
	if agent.skill_manager.currentSkill is MeleeSkillResource:
		skill_range = agent.skill_manager.currentSkill.swingLength
	elif "range" in agent.skill_manager.currentSkill:
		skill_range = agent.skill_manager.currentSkill.range
	
	var distance_to_target = agent.global_position.distance_to(agent.current_combat_target.global_position)
	
	# Move until we reach the target or something goes wrong
	while distance_to_target > skill_range:
		# Check if target is still valid
		if not is_instance_valid(agent.current_combat_target) or agent.current_combat_target.health <= 0:
			break
		
		# Check if target moved too far away
		if distance_to_target > 500:
			break
		
		# Move towards target
		var target_position = agent.current_combat_target.global_position
		var move_direction = agent.global_position.direction_to(target_position)
		
		# Set the agent's direction for animations
		agent.direction = move_direction
		agent.last_direction = move_direction
		
		# Move towards target
		agent.velocity = move_direction * move_speed
		
		await get_tree().process_frame
		
		# Recalculate distance for next loop check
		if is_instance_valid(agent.current_combat_target):
			distance_to_target = agent.global_position.distance_to(agent.current_combat_target.global_position)
		else:
			break
	
	# Stop moving
	agent.velocity = Vector2.ZERO
	agent.direction = Vector2.ZERO
	
	# Check if we successfully reached the target
	if is_instance_valid(agent.current_combat_target) and distance_to_target <= skill_range:
		agent.isProcessingState = false
		agent.set_task("Use Skill")
		positionComplete.emit()
	else:
		# Something went wrong, go back to target selection
		agent.isProcessingState = false
		agent.set_task("Choose Target")
		positionComplete.emit()
