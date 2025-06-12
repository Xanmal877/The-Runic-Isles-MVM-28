class_name ProjectileSkillResource extends SkillResource

const PROJECTILE = preload("res://scenes/skills/projectile.tscn")

@export var currentSpeed: float = 150
@export var distance: float = 100

func UseSkill(agent: BaseCharacter, target: BaseCharacter, skill: SkillResource) -> void:
	if CanCast(agent, target, skill):
		var skillScene = PROJECTILE.instantiate()
		skillScene.agent = agent
		skillScene.target = target
		skillScene.skill = skill

		var worldnode = agent.get_tree().get_first_node_in_group("WorldNode")
		worldnode.call_deferred("add_child", skillScene)
