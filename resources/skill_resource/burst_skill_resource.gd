class_name BurstSkillResource extends SkillResource

func UseSkill(agent: BaseCharacter, target: BaseCharacter, skill: SkillResource) -> void:
	if CanCast(agent, target, skill):
		if skill.effectType == skill.EffectType.Harm:
			ApplyDamage(agent,target,skill)
		elif skill.effectType == skill.EffectType.Heal:
			ApplyHeal(agent,target,skill)
