extends Node
class_name SpellTimers

@export var spell_timers  = {}
@onready var spell_unlocks = {}

func create_spell_timer(spell: SpellResource):
	var spell_duration = spell.spell_duration
	var spell_name = spell.Name
	
	spell_timers[spell_name] = spell_duration 
	await get_tree().create_timer(spell_duration, false, true, true).timeout
	spell_timers.erase(spell_name)
	print(spell_timers)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(spell_timers)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
