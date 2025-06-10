extends Node
class_name SpellTimers

var spell_ref: SpellResource

@export var spell_timers  = {}
@onready var spell_unlocks = {}

func StartCooldownTimer(duration: float, spell) -> void:
	var timer_key = "cd_" + str(spell.get_instance_id())
	if spell_timers.has(timer_key) and is_instance_valid(spell_timers[timer_key]):
		spell_timers[timer_key].queue_free()
		spell_timers.erase(timer_key)
		
	var timer = Timer.new()
	timer.one_shot = true
	timer.name = "CooldownTimer_" + str(spell.get_instance_id())
	add_child(timer)
	spell_timers[timer_key] = timer
	
	# Store skill reference in the timer for the callback
	timer.set_meta("spell_ref", spell)
	timer.timeout.connect(_on_cooldown_timeout.bind(timer))
	
	timer.start(duration)
 
func _on_cooldown_timeout(timer: Timer) -> void:
	if timer.has_meta("spell_ref"):
		var spell = timer.get_meta("spell_ref")
		if is_instance_valid(spell):
			spell.onCooldown = false
 
	var timer_key = "cd_" + str(timer.get_meta("spell_ref").get_instance_id())
	if spell_timers.has(timer_key):
		spell_timers.erase(timer_key)
	timer.queue_free()

func _on_tree_exiting() -> void:
	for spells in spell_timers:
		spell_timers[spells].queue_free()
		
	spell_timers.clear()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tree_exiting.connect(_on_tree_exiting)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
