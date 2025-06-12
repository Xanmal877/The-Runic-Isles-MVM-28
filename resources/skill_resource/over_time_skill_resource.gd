class_name OverTimeSkillResource extends SkillResource

# How long the effect lasts
@export var duration: float = 5.0 
# How often the effect triggers (in seconds)
@export var tickInterval: float = 1.0
# Effect per tick (damage/healing per tick)
@export var effectPerTick: float = 5.0

func UseSkill(agent: BaseCharacter, target: BaseCharacter, skill: SkillResource) -> void:
	#print("Applying over-time effect: ", skill.Name, " from ", agent.name, " to ", target.name)
	if CanCast(agent, target, skill):
		if skill is OverTimeSkillResource:
			GameManager.resourceTimerSystem.StartDoTTimer(agent, agent.current_combat_target, agent.skill_manager.currentSkill)
		else:
			GameManager.resourceTimerSystem.StartDoTTimer(agent, agent.current_combat_target, agent.skill_manager.currentSkill.dot)

func ApplyTickEffect(agent: BaseCharacter, target: BaseCharacter, skill: SkillResource) -> void:
	if !is_instance_valid(agent) and !is_instance_valid(target):
		return

	if skill.effectType == skill.EffectType.Harm:
		ApplyDamageOverTime(agent, target, skill)
	elif skill.effectType == skill.EffectType.Heal:
		ApplyHealOverTime(agent, target, skill)

	if is_instance_valid(agent):
		agent.charManager.CheckKilled(target)

func ApplyDamageOverTime(agent: BaseCharacter, target: BaseCharacter, _skill: SkillResource) -> void:
	if !is_instance_valid(agent) and !is_instance_valid(target):
		return

	var damage = effectPerTick
	var defense = target.defense
	
	# Add agent's level-scaled damage (reduced scaling for DoTs)
	if is_instance_valid(agent):
		damage += (agent.damage * 0.2) * agent.level
	
		# Apply defense reduction (less effective against DoTs)
		damage = damage * (100 / (100 + (defense * 0.8)))
		
		# Ensure minimum damage and round to whole number
		damage = max(1.0, round(damage))
	
		# Apply damage to target
		target.health -= damage

func ApplyHealOverTime(_agent: BaseCharacter, target: BaseCharacter, _skill: SkillResource) -> void:
	var healing = effectPerTick

	# Apply Constitution and Wisdom bonuses
	if target is BaseCharacter:
		var con_bonus = target.Constitution * 0.01
		var wis_bonus = target.Wisdom * 0.005
		healing *= (1.0 + con_bonus + wis_bonus)

	# Round and apply healing
	healing = round(healing)
	target.health = min(target.health + healing, target.maxHealth)

func CreateEffectVisual(target: BaseCharacter, skill: SkillResource) -> Node2D:
	var effectn = Node2D.new()
	effectn.name = "OvertimeEffect_" + skill.Name
	
	# Create particles to show the effect
	var particles = CPUParticles2D.new()
	particles.name = "EffectParticles"
	particles.amount = 100
	particles.emitting = true
	particles.lifetime = 1.0
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 16.0
	particles.direction = Vector2(0, -1)
	particles.spread = 60.0
	particles.gravity = Vector2(0, -20)
	
	# Set particle color based on effect type and element
	if skill.effectType == skill.EffectType.Harm:
		match skill.element:
			skill.ElementType.NONE:
				particles.color = Color(0.8, 0.8, 0.8, 0.8)  # Gray for non-elemental
			skill.ElementType.WATER:
				particles.color = Color(0.2, 0.4, 1.0, 0.8)  # Blue for water
			skill.ElementType.AIR:
				particles.color = Color(0.7, 0.7, 1.0, 0.8)  # Light blue/white for air
			skill.ElementType.EARTH:
				particles.color = Color(0.6, 0.4, 0.2, 0.8)  # Brown for earth
			skill.ElementType.FIRE:
				particles.color = Color(1.0, 0.3, 0.1, 0.8)  # Orange-red for fire
			skill.ElementType.VOID:
				particles.color = Color(0.5, 0.1, 0.7, 0.8)  # Purple for void
			skill.ElementType.LIGHT:
				particles.color = Color(1.0, 0.9, 0.5, 0.8)  # Yellow-white for light
	else:
		# Healing effects get different colors based on element
		match skill.element:
			skill.ElementType.NONE:
				particles.color = Color(0.2, 1.0, 0.2, 0.8)  # Green for basic healing
			skill.ElementType.WATER:
				particles.color = Color(0.2, 0.8, 1.0, 0.8)  # Aqua blue for water healing
			skill.ElementType.AIR:
				particles.color = Color(0.9, 0.9, 1.0, 0.8)  # Light blue/white for air healing
			skill.ElementType.EARTH:
				particles.color = Color(0.5, 0.8, 0.3, 0.8)  # Earthy green for earth healing
			skill.ElementType.FIRE:
				particles.color = Color(1.0, 0.6, 0.3, 0.8)  # Warm orange for fire healing
			skill.ElementType.VOID:
				particles.color = Color(0.7, 0.4, 0.9, 0.8)  # Light purple for void healing
			skill.ElementType.LIGHT:
				particles.color = Color(1.0, 1.0, 0.7, 0.8)  # Bright yellow for light healing
	
	# You could also customize particle behavior based on element
	match skill.element:
		skill.ElementType.FIRE:
			# Fire particles rise up more
			particles.gravity = Vector2(0, -40)
			particles.initial_velocity_min = 20
			particles.initial_velocity_max = 40
		skill.ElementType.WATER:
			# Water particles fall and spread
			particles.gravity = Vector2(0, 20)
			particles.spread = 90.0
		skill.ElementType.EARTH:
			# Earth particles are heavier and spread less
			particles.gravity = Vector2(0, 40)
			particles.spread = 30.0
		skill.ElementType.AIR:
			# Air particles float and spread widely
			particles.gravity = Vector2(0, -10)
			particles.spread = 180.0
		skill.ElementType.VOID:
			# Void particles pulse and have a unique movement
			particles.gravity = Vector2(0, 0)
			# Could add custom code for pulsing or swirling motion
		skill.ElementType.LIGHT:
			# Light particles fade out more gradually and spread everywhere
			particles.lifetime = 1.5
			particles.spread = 360.0

	if is_instance_valid(target):
		# Add the particles to the effect node
		effectn.add_child(particles)
		
		# Add a timer to remove the effect after duration
		var cleanup_timer = Timer.new()
		cleanup_timer.one_shot = true
		cleanup_timer.wait_time = duration
		effectn.add_child(cleanup_timer)
		
		# Connect timer to remove the particles when done
		cleanup_timer.timeout.connect(func():
			effectn.queue_free()
		)
		# Attach the effect to the target
		target.add_child(effectn)

		# Start the cleanup timer
		cleanup_timer.start()
	
	return effectn
