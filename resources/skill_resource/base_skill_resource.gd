class_name SkillResource extends Resource

#region Variables

enum resources {Health, Stamina, Mana}
enum EffectType {Harm, Heal, Other}
enum ElementType {NONE, WATER, AIR, EARTH, FIRE, VOID, LIGHT}

@export_group("Basic Skill Info")
@export var Name: StringName
@export_multiline var description: String
@export var icon: Texture2D
@export var effect: float = 10
@export var effectType: EffectType = EffectType.Harm
@export var element: ElementType
@export var cost: float
@export var type: resources
@export var castTime: float = 0
@export var cooldownTime: float = 0

@export var requiredLevel: int
@export var dot: OverTimeSkillResource

@export_subgroup("Bools")
@export var onCooldown: bool
@export var learned: bool = false
@export var disabled: bool = false

#endregion

func UseSkill(_agent: BaseCharacter, _target: BaseCharacter, _skill: SkillResource) -> void:
	pass

func CanCast(agent: BaseCharacter, target: BaseCharacter, skill: SkillResource) -> bool:
	if skill.onCooldown:
		print("Skill on cooldown")
		return false

	if !is_instance_valid(agent):
		print("No Agent")
		return false

	if !is_instance_valid(target) and agent.is_in_group("AIControlled"):
		print("Invalid target")
		return false

	match type:
		resources.Health:
			if agent.health < cost:
				return false
			agent.health -= cost
		resources.Stamina:
			if agent.stamina < cost:
				return false
			agent.stamina -= cost
		resources.Mana:
			if agent.mana < cost:
				return false
			agent.mana -= cost

	return true

func ApplyDamage(agent: BaseCharacter, target: BaseCharacter, skill: SkillResource) -> void:
	# Start with base damage and apply stat scaling in one step
	var damage = skill.effect
	var defense = target.defense
	
	damage += agent.damage
	damage = damage * (100 / (100 + defense))
	damage = max(1.0, round(damage))
	target.health -= damage

func ApplyHeal(_agent: BaseCharacter, target: BaseCharacter, skill: SkillResource) -> void:
	# Calculate healing amount with stat bonuses in one step
	var healing = skill.effect
	
	# Apply Constitution and Wisdom bonuses directly
	if target is BaseCharacter:
		# Simple percentage bonus from Constitution and Wisdom
		var con_bonus = target.Constitution * 0.02  # 2% per point
		var wis_bonus = target.Wisdom * 0.01       # 1% per point
		healing *= (1.0 + con_bonus + wis_bonus)
	
	# Round and apply healing
	healing = round(healing)
	target.health = min(target.health + healing, target.maxHealth)

func ApplyBonusEffect():
	pass
