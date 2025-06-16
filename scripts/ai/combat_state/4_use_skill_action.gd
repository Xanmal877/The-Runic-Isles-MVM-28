class_name UseSkillAction extends StateMachine

@onready var castTimer: Timer = Timer.new()

@warning_ignore("unused_signal")
signal FinishedCasting

func _ready() -> void:
	castTimer.one_shot = true
	add_child(castTimer)
	castTimer.connect("timeout", CastSpell)
	castTimer.name = "Cast Timer"
	

func _physics_process(_delta: float) -> void:
	ForceStopMovement()
	#UpdateCastBar()

func HandleState() -> void:
	agent.isProcessingState = true

	if !agent.casting:
		StartCasting()

func CanCast() -> bool:
	if agent.skill_manager.currentSkill == null:
		print("Invalid skill")
		return false
	
	if !is_instance_valid(agent):
		return false

	if agent is Player:
		if is_instance_valid(GameManager.selectedTarget):
			agent.current_combat_target = GameManager.selectedTarget
	elif agent.is_in_group("AIControlled") and !is_instance_valid(agent.current_combat_target):
		return false

	# Check distance to target - USE SWINGLENGTH FOR MELEE
	if is_instance_valid(agent.current_combat_target):
		var skill_range = 60.0  # Default fallback
		
		# Check if it's a melee skill with swingLength
		if agent.skill_manager.currentSkill is MeleeSkillResource:
			skill_range = agent.skill_manager.currentSkill.swingLength
		
		var distance_to_target = agent.global_position.distance_to(agent.current_combat_target.global_position)
		if distance_to_target > skill_range:
			print("Target out of range: " + str(distance_to_target) + " > " + str(skill_range))
			return false

	if agent.skill_manager.currentSkill.onCooldown:
		print("Skill on cooldown")
		return false

	return true

# And in StartCasting(), if CanCast() fails, go back to target selection:
func StartCasting() -> void:
	if CanCast():
		if castTimer.is_stopped():
			agent.casting = true
			if agent.skill_manager.currentSkill.castTime > 0.1:
				castTimer.start(agent.skill_manager.currentSkill.castTime)
			else:
				CastSpell()
	else:
		# If we can't cast, go back to choose target
		agent.set_task("Choose Target")
		FinishCasting()

func CastSpell() -> void:
	if !CanCast():
		FinishCasting()
		return

	if agent.skill_manager.currentSkill and is_instance_valid(agent.current_combat_target):
		agent.skill_manager.currentSkill.UseSkill(agent, agent.current_combat_target, agent.skill_manager.currentSkill)
	if agent.skill_manager.currentSkill.cooldownTime > 0.1:
		GameManager.resourceTimerSystem.StartCooldownTimer(agent.skill_manager.currentSkill.cooldownTime, agent.skill_manager.currentSkill)
		agent.skill_manager.currentSkill.onCooldown = true

	FinishCasting()

func FinishCasting():
	#if await agent.charManager.CheckKilled(agent.current_combat_target):
		#agent.skill_manager.currentSkill = null
	agent.casting = false
	await get_tree().create_timer(1).timeout
	agent.isProcessingState = false
	emit_signal("FinishedCasting")

var cooldown_timers := {}

func StartCooldownTimer(duration: float, skill) -> void:
	# Cancel existing timer if any
	if skill in cooldown_timers and is_instance_valid(cooldown_timers[skill]):
		cooldown_timers[skill].queue_free()
		cooldown_timers.erase(skill)

	var timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	cooldown_timers[skill] = timer

	timer.start(duration)

	timer.timeout.connect(func():
		if is_instance_valid(skill):
			skill.onCooldown = false
		cooldown_timers.erase(skill)
		timer.queue_free())

func ForceStopMovement():
	if agent.casting:
		agent.direction = Vector2.ZERO
		agent.navAgent.set_target_position(agent.global_position)
		agent.velocity = Vector2.ZERO

		if is_instance_valid(agent.current_combat_target):
			agent.animDirection = agent.global_position.direction_to(agent.current_combat_target.global_position)

#func UpdateCastBar() -> void:
	#if is_instance_valid(agent.portrait.skill_bar):
		#if !castTimer.is_stopped():
			#agent.portrait.skill_bar.value = castTimer.wait_time - castTimer.time_left
			#agent.portrait.skill_bar.max_value = castTimer.wait_time
			#agent.portrait.skill_bar.visible = true
		#else:
			#agent.portrait.skill_bar.visible = false
