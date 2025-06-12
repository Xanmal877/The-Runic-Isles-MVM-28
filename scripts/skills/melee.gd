class_name MeleeScene extends Area2D

@onready var projectile_lifespan: Timer = $"Projectile Lifespan"
#@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite: Sprite2D = $Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var agent: BaseCharacter
var target: BaseCharacter
var direction: Vector2
var skill: SkillResource

func _ready() -> void:
	animation_player.play(skill.Name)
	SetupDirection()
	print("I am called!")

func SetupDirection():
	var target_position: Vector2
	
	# Check if this is an AI enemy or player
	if agent is not Player and is_instance_valid(agent.current_combat_target):
		# For AI, swing towards their current target
		target_position = agent.current_combat_target.global_position
		print(agent.name + " swinging towards: " + agent.current_combat_target.name)
	else:
		target_position = get_global_mouse_position()
	
	direction = agent.global_position.direction_to(target_position) * 15
	look_at(global_position + direction)
	global_position = agent.global_position + direction

func EnemyHit(area: Area2D) -> void:
	print("Melee hit detected!")
	target = area.get_owner()
	print("Target hit: ", target.name if target else "null")
	
	if target == agent:
		print("Hit self, ignoring")
		return

	projectile_lifespan.wait_time = 0.1
	ApplyEffect()
	queue_free()

func ApplyEffect() -> void:
	print("Applying effect to: ", target.name if target else "null")
	if is_instance_valid(agent):
		if skill.effectType == skill.EffectType.Harm:
			print("Applying damage: ", skill.effect)
			skill.ApplyDamage(agent, target, skill)
		elif skill.effectType == skill.EffectType.Heal:
			skill.ApplyHeal(agent,target,skill)
		if skill.dot != null:
			skill.dot.UseSkill(agent, target, skill)
		
		agent.check_killed()
		target.check_killed()
		#if await agent.charManager.CheckKilled(target):
			#return

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

func ProjectileTimeout() -> void:
	queue_free()
