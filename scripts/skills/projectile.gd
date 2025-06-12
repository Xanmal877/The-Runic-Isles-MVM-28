class_name Projectile extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var projectile_life_span: Timer = $ProjectileLifeSpan

var agent: BaseCharacter
var target: Node2D
var direction: Vector2
var skill: SkillResource

func _ready() -> void:
	sprite.play(skill.Name)
	projectile_life_span.wait_time = 2.5
	# Create a visual effect if needed
	#var effectVisual = CreateEffectVisual(self, skill)
	#if effectVisual:
		#self.add_child(effectVisual)
	projectile_life_span.start()
	SetupDirection()

func _physics_process(delta: float) -> void:
	if agent.is_in_group("AIControlled") and !is_instance_valid(target):
		queue_free()
		return

	global_position += direction * skill.currentSpeed * delta

func SetupDirection():
	if agent.is_in_group("AIControlled"):
		print("Setup direction towards:" + str(target.Name))
		#agent.skillDirection = 
		direction = agent.global_position.direction_to(target.global_position)
		look_at(global_position + direction)
		global_position = agent.global_position + direction
	else:
		print("Setup direction")
		direction = agent.global_position.direction_to(get_global_mouse_position())
		look_at(global_position + direction)
		global_position = agent.global_position + direction

func CanDamage(area: Area2D) -> bool:
	if area is Projectile:
		return false


	if area.get_owner() == agent:
		return false

	# Also check if the target is another skill
	if area.get_owner() is Projectile:
		return false
	
	return true

func EnemyHit(area: Area2D) -> void:
	if !CanDamage(area):
		return
	ApplyEffect()
	queue_free()

func ApplyEffect() -> void:
	if is_instance_valid(agent) and is_instance_valid(target):
	
		if skill.effectType == skill.EffectType.Harm:
			skill.ApplyDamage(agent, target, skill)
		elif skill.effectType == skill.EffectType.Heal:
			skill.ApplyHeal(agent,target,skill)

		if skill.dot:
			skill.dot.UseSkill(agent, target, skill)

		if await agent.charManager.CheckKilled(target):
			return

		#var bodyFaction = agent.factionState["Self"]
		#if target.factionState["Enemies"].has(bodyFaction):
			#if target is CharacterBody2D and skill.effectType == skill.EffectType.Harm:
				#target.enemiesDetected.append(agent)
				#target.StateMachineLogic()

func SplashDamage():
	return
	#if skill.splashRadius > 0:
		#var enemies = get_tree().get_nodes_in_group("Enemy")
		#for enemy in enemies:
			#if is_instance_valid(enemy) and enemy != target:
				#var distance = enemy.global_position.distance_to(global_position)
				#if distance <= skill.splashRadius:
					#if skill.damage > 0:
						#skill.ApplyDamage(agent, skill, enemy)
					#elif skill.heal > 0:
						#skill.ApplyHeal(skill, enemy)

func CreateEffectVisual(_target: Node2D, _skill: SkillResource) -> Node2D:
	var effect = Node2D.new()
	effect.name = "ProjectileEffect_" + skill.Name
	
	# Create particles to show the effect
	var particles = CPUParticles2D.new()
	particles.amount = 200
	particles.lifetime = 1.0
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 10.0
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
	
	effect.add_child(particles)
	return effect

func ProjectileTimeout() -> void:
	queue_free()
