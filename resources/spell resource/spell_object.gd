extends SpellResource
class_name SpellObjectResource

@export var speed: float
@export var distance: float

var spell_dict: SpellTimers
var obj_spells: ObjectSpells

func use_spell(agent: BaseCharacter, target: BaseCharacter, spell: SpellResource) -> void:
	if can_cast(agent, target, spell):
		const OBJECT_SCENE = preload("res://scenes/abilities/projectile_scene.tscn")
		var spell_scene = OBJECT_SCENE.instantiate()
		spell_scene.agent = agent
		spell_scene.target = target
		spell_scene.spell = spell

		var level_node = agent.get_tree().get_first_node_in_group("base_level")
		level_node.call_deferred("add_sibling", spell_scene)
	
	if spell_dict.spell_timers.has("Wind Wall"):
		while obj_spells.effect_area.area_entered:
			if target.is_in_group("liftable"):
				target.velocity.y = -sqrt(2 * target.gravity * effect_value)
