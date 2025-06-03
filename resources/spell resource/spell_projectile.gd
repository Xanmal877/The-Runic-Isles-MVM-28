extends SpellResource
class_name SpellProjectileResource

@export var speed: float
@export var distance: float

func use_spell(agent: BaseCharacter, target: BaseCharacter, spell: SpellResource) -> void:
	if can_cast(agent, target, spell):
		const PROJECTILE_SCENE = preload("res://scenes/abilities/projectile_scene.tscn")
		var spell_scene = PROJECTILE_SCENE.instantiate()
		spell_scene.agent = agent
		spell_scene.target = target
		spell_scene.spell = spell

		var level_node = agent.get_tree().get_first_node_in_group("base_level")
		level_node.call_deferred("add_sibling", spell_scene)
		
		if spell.effect_type == 1:
			apply_damage(agent, target, spell)
		
		if spell.spell_action == 0:
			apply_dispel(agent, target, spell)
	
