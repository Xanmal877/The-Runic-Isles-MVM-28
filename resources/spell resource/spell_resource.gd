extends Resource
class_name SpellResource

enum stats {Health, Damage, Atk_range, J_height, Speed, None}
enum alignment {Water, Wind, Fire, Earth}
enum target {Area, Creature, Item, Self}
enum action {Dispel, Mend, Enchant, Projectile}

# Basic Spell Info
@export_group("Spell Info")
@export var Name: StringName
@export_multiline var description: String
@export var icon: Texture2D
@export var effect_value: float
@export var effect_type: stats
@export var spell_alignment: alignment
@export var spell_target: target
@export var spell_action: action
@export var spell_cooldown: float
@export var spell_duration: float

@export_subgroup("Bools")
@export var unlocked: bool
@export var disabled: bool
@export var on_cooldown: bool

var cd_timer: SpellTimers

# Spell Casting
func cast_spell(agent: BaseCharacter, target: Node2D, spell: SpellResource) -> void:
	pass

func can_cast(agent: BaseCharacter, target: Node2D, spell: SpellResource) -> bool:
	if spell.on_cooldown:
		print("Spell on cooldown")
		return false
	
	if spell.disabled:
		return false
	
	else:
		cd_timer.StartCooldownTimer(spell_cooldown, spell.Name)
		return true

func apply_damage(agent: BaseCharacter, target: BaseCharacter, spell: SpellResource) -> void:
	var damage = spell.effect_value
	var resistance = target.defense

	damage = damage * (100 / (100 + resistance))
	damage = max(1.0, round(damage))
	target.health -= damage

func apply_heal(agent: BaseCharacter, target: BaseCharacter, spell: SpellResource) -> void:
	var heal = spell.effect_value
	
	target.health += heal
	
func apply_buff(agent: BaseCharacter, target: BaseCharacter, spell: SpellResource) -> void:
	var buff_type = effect_type
	
	if buff_type == 1:
		target.damage += effect_value
	
	if buff_type == 3:
		target.jump_height += effect_value
	
	if buff_type == 4:
		target.speed += effect_value
	
func apply_dispel(agent: BaseCharacter, target: Node2D, spell: SpellResource) -> void:
	if target.is_in_group("Dispelable"):
		target.queue_free()
