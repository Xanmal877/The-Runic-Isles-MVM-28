class_name SelectSkillAction extends StateMachine

@warning_ignore("unused_signal")
signal skillPicked

func HandleState() -> void:
	agent.isProcessingState = true
	agent.skill_manager.currentSkill = null
	var spells_by_priority = []

	# First check if skillBook is empty or null
	if agent.skill_manager.skillBook.size() == 0:
		print("Warning: " + agent.Name + " has no skills in skillbook")
		agent.isProcessingState = false
		return

	# Score all available skills
	for skill in agent.skill_manager.skillBook:
		if skill == null or skill.onCooldown:
			continue

		## Check resource costs
		#match skill.type:
			#SkillResource.resources.Mana:
				#if agent.mana < skill.cost:
					#continue
			#SkillResource.resources.Stamina:
				#if agent.stamina < skill.cost:
					#continue
			#SkillResource.resources.Health:
				#if agent.health <= skill.cost:
					#continue
#
		## In the skill scoring loop, after the resource checks:
		#print(agent.name + " checking skill: " + str(skill.Name) + " (Mana: " + str(agent.mana) + "/" + str(skill.cost) + " CD: " + str(skill.onCooldown) + ")")

		var score_data = CalculateSpellScore(skill)
		# After calculating score:
		print("  Score: " + str(score_data.score))
		if score_data.score > 0:
			spells_by_priority.append({"skill": skill, "score": score_data.score})

	# Select the highest scoring skill
	if spells_by_priority.size() > 0:
		spells_by_priority.sort_custom(func(a, b): return b["score"] > a["score"])
		agent.skill_manager.currentSkill = spells_by_priority[0]["skill"]
		print(agent.name + " using skill: " + str(agent.skill_manager.currentSkill.Name))
		agent.set_task("Take Position")
	else:
		# Fallback to first available skill if no skills scored positively
		if agent.skill_manager.skillBook.size() > 0 and agent.skill_manager.skillBook[0] != null:
			agent.skill_manager.currentSkill = agent.skill_manager.skillBook[0]
			print(agent.name + " using fallback skill: " + str(agent.skill_manager.currentSkill.Name))
			agent.set_task("Take Position")
		else:
			print(agent.name + " has no valid skills to use")
			agent.set_task("Wander")

	agent.isProcessingState = false
	emit_signal("skillPicked")

func CalculateSpellScore(skill) -> Dictionary:
	var score = 0
	var result = {"score": 0}

	# Check if this is a healing skill
	if skill.effectType == skill.EffectType.Heal:
		score = CalculateHealingScore(skill)
	else:
		score = CalculateDamageScore(skill)

	result.score = score
	return result

func CalculateHealingScore(skill) -> int:
	var score = 0
	
	# Skip healing if target is an enemy
	if not is_instance_valid(agent.current_combat_target):
		return -100
	
	if agent.current_combat_target in agent.enemiesDetected:
		return -100
	
	var target = agent.current_combat_target
	var healthPercentage = float(target.health) / float(target.maxHealth)
	
	# Base healing score
	score += int(skill.effect * 1.0)
	
	# Scale score based on how low the target's health is
	# Lower health = higher priority
	var urgencyMultiplier = 1.0 + (2.0 * (1.0 - healthPercentage))
	score = int(score * urgencyMultiplier)
	
	# Give healing spells priority over damage spells
	score += 100
	
	# Critical health bonus (below 25%)
	if healthPercentage < 0.25:
		score += 150
	
	return score

func CalculateDamageScore(skill) -> int:
	var score = 0
	
	# Base damage score
	if skill.effect > 0:
		score += int(skill.effect * 0.5)
	
	return score
