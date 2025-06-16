class_name CombatPositioningAction extends StateMachine

signal positionComplete

var move_speed: float = 75.0
var acceptable_range: float = 60.0  # Default melee range
var range_buffer: float = 5.0  # Small buffer to prevent edge cases

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
	
	# Get skill range with proper fallbacks
	var skill_range = get_skill_range()
	print(agent.name + " positioning for range: " + str(skill_range))
	
	var distance_to_target = agent.global_position.distance_to(agent.current_combat_target.global_position)
	print("Current distance: " + str(distance_to_target))
	
	# Check if we're already in range
	if distance_to_target <= skill_range:
		print("Already in range!")
		finish_positioning_success()
		return
	
	# Start moving towards target
	move_to_target(skill_range)

func get_skill_range() -> float:
	var skill_range = acceptable_range  # Default fallback
	
	if agent.skill_manager.currentSkill is MeleeSkillResource:
		# For melee skills, use swingLength but add a small buffer
		skill_range = agent.skill_manager.currentSkill.swingLength
		print("Using melee range (swingLength): " + str(agent.skill_manager.currentSkill.swingLength))
	
	# Ensure minimum range
	return max(skill_range, 10.0)

func move_to_target(target_range: float) -> void:
	var max_time = 5.0  # Maximum time to spend moving (seconds)
	var start_time = Time.get_time_dict_from_system()
	
	while true:
		# Check timeout
		var current_time = Time.get_time_dict_from_system()
		var elapsed = (current_time.hour * 3600 + current_time.minute * 60 + current_time.second) - \
					 (start_time.hour * 3600 + start_time.minute * 60 + start_time.second)
		if elapsed > max_time:
			print("Movement timeout")
			finish_positioning_failed()
			return
		
		# Check if target is still valid
		if not is_instance_valid(agent.current_combat_target) or agent.current_combat_target.health <= 0:
			print("Target became invalid during movement")
			finish_positioning_failed()
			return
		
		var distance_to_target = agent.global_position.distance_to(agent.current_combat_target.global_position)
		
		# Check if we've reached the target
		if distance_to_target <= target_range:
			print("Reached target! Distance: " + str(distance_to_target) + " <= " + str(target_range))
			finish_positioning_success()
			return
		
		# Check if target moved too far away
		if distance_to_target > 500:
			print("Target too far away: " + str(distance_to_target))
			finish_positioning_failed()
			return
		
		# Calculate movement
		var target_position = agent.current_combat_target.global_position
		var move_direction = agent.global_position.direction_to(target_position)
		
		agent.direction = move_direction
		agent.last_direction = move_direction
		agent.velocity = move_direction * move_speed
		
		# Wait for next frame - this should be OUTSIDE any counting loop
		await get_tree().process_frame

func finish_positioning_success() -> void:
	# Stop moving
	agent.velocity = Vector2.ZERO
	agent.direction = Vector2.ZERO
	
	agent.isProcessingState = false
	agent.set_task("Use Skill")
	positionComplete.emit()

func finish_positioning_failed() -> void:
	# Stop moving
	agent.velocity = Vector2.ZERO
	agent.direction = Vector2.ZERO
	
	# Something went wrong, go back to target selection
	agent.isProcessingState = false
	agent.set_task("Choose Target")
	positionComplete.emit()
