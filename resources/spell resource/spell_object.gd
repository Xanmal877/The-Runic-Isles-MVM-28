extends SpellResource
class_name SpellObjectResource

@export var speed: float
@export var distance: float

func use_spell(agent: BaseCharacter, target: BaseCharacter, spell: SpellResource) -> void:
	if can_cast(agent, target, spell):
		const OBJECT_SCENE = preload("res://scenes/abilities/projectile_scene.tscn")
		var spell_scene = OBJECT_SCENE.instantiate()
		spell_scene.agent = agent
		spell_scene.target = target
		spell_scene.spell = spell

		var level_node = agent.get_tree().get_first_node_in_group("base_level")
		level_node.call_deferred("add_sibling", spell_scene)
	
