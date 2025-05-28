extends SpellResource
class_name SpellSelfResource

func use_spell(agent: BaseCharacter, target: BaseCharacter, spell: SpellResource) -> void:
	if can_cast(agent, target, spell):
		const SELF_SPELL_SCENE = preload("res://scenes/abilities/self_spell_scene.tscn")
		var spell_scene = SELF_SPELL_SCENE.instantiate()
		spell_scene.agent = agent
		spell_scene.target = target
		spell_scene.spell = spell

		var level_node = agent.get_tree().get_first_node_in_group("base_level")
		level_node.call_deferred("add_sibling", spell_scene)
	
	if spell.effect_type == 0:
		apply_heal(agent, target, spell)
	
	if spell.effect_type != 0 or 5:
		apply_buff(agent, target, spell)
	
	if spell.Name == "Air Strider":
		var jumped = false
		
		if jumped == false:
			agent.jumping = true
			agent.animtree.handle_jump_anim()
			agent.velocity.y = -sqrt(2 * agent.gravity * agent.jump_height)
			jumped = true
			
		if agent.is_on_floor():
			jumped = false
