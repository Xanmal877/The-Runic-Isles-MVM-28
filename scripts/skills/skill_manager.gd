class_name SkillManager extends Node

signal addSkill(skillName)
signal removeSkill(skillName)
signal useSkill(skillName)
@warning_ignore("unused_signal")
signal updateSkillBook

@export var agent: BaseCharacter

var skillBook: Array = []
var currentSkill: SkillResource
var skillPaths: Dictionary = {
	"Water Bolt": "res://resources/skill_resource/projectiles/water_bolt.tres",
	"Basic Attack": "res://resources/skill_resource/melee/basic_attack.tres",
}

func _ready() -> void:
	addSkill.connect(AddData)
	removeSkill.connect(RemoveData)
	useSkill.connect(UseSkill)

func AddData(skillName: String) -> SkillResource:
	var skill
	if not skillPaths.has(skillName):
		push_error("Error: Skill name not found: " + skillName)
		return null

	var skillResource = ResourceLoader.load(skillPaths[skillName])
	if skillResource == null:
		push_error("Error: Skill resource not found: " + skillPaths[skillName])
		return null

	skill = skillResource

	for i in skillBook:
		if i.Name == skill.Name:
			return i

	var newSkill = skill.duplicate(true)
	newSkill.learned = true
	skillBook.append(newSkill)

	emit_signal("updateSkillBook")

	return newSkill

func RemoveData(skillName: String) -> void:
	for i in range(skillBook.size()):
		if skillBook[i].Name == skillName:
			skillBook.remove_at(i)
			emit_signal("updateSkillBook")
			break

func UseSkill(skillName: String) -> bool:
	for skill in skillBook:
		if skill.Name == skillName:
			if agent and !agent.casting:
				currentSkill = skill
				if agent.useSkillAction:
					agent.useSkillAction.StartCasting()
				return true
	return false
