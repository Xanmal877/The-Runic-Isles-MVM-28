class_name MeleeSkillResource extends SkillResource

@export var swingLength: float = 0.0

func UseSkill(agent: BaseCharacter, target: BaseCharacter, skill: SkillResource) -> void:
	const MELEE = preload("res://scenes/skills/melee.tscn")
	if CanCast(agent, target, skill):
		var skillScene = MELEE.instantiate()
		skillScene.agent = agent
		skillScene.skill = skill
		var worldnode = agent.get_tree().get_first_node_in_group("WorldNode")
		worldnode.call_deferred("add_child", skillScene)

#func IsInRange(agent: BaseCharacter, target: BaseCharacter) -> bool:
	#if target.global_position.distance_to(agent.global_position) <= swingLength:
		#return true
	#return false
