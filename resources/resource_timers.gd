class_name ResourceTimers extends Node

# Dictionary to store DoT data
class DotData:
	var agent_id: int
	var target_id: int
	var skill_ref: OverTimeSkillResource
	var current_tick: int
	var total_ticks: int

# Store timers for cooldowns and DoTs
var resourceTimers := {}
var dotDataMap := {}

func _ready() -> void:
	# Connect cleanup to tree exiting to prevent errors on scene change
	tree_exiting.connect(_on_tree_exiting)

func _on_tree_exiting() -> void:
	# Clean up all timers when the node exits the tree
	for key in resourceTimers:
		if is_instance_valid(resourceTimers[key]):
			resourceTimers[key].queue_free()
	resourceTimers.clear()
	dotDataMap.clear()

# Start a cooldown timer for skills
func StartCooldownTimer(duration: float, skill) -> void:
	# Cancel existing timer if any
	var timer_key = "cd_" + str(skill.get_instance_id())
	if resourceTimers.has(timer_key) and is_instance_valid(resourceTimers[timer_key]):
		resourceTimers[timer_key].queue_free()
		resourceTimers.erase(timer_key)
		
	var timer = Timer.new()
	timer.one_shot = true
	timer.name = "CooldownTimer_" + str(skill.get_instance_id())
	add_child(timer)
	resourceTimers[timer_key] = timer
	
	# Store skill reference in the timer for the callback
	timer.set_meta("skill_ref", skill)
	timer.timeout.connect(_on_cooldown_timeout.bind(timer))
	
	timer.start(duration)

func _on_cooldown_timeout(timer: Timer) -> void:
	if timer.has_meta("skill_ref"):
		var skill = timer.get_meta("skill_ref")
		if is_instance_valid(skill):
			skill.onCooldown = false

	var timer_key = "cd_" + str(timer.get_meta("skill_ref").get_instance_id())
	if resourceTimers.has(timer_key):
		resourceTimers.erase(timer_key)
	timer.queue_free()

# Start a damage-over-time timer
func StartDoTTimer(agent: BaseCharacter, target: BaseCharacter, skill: OverTimeSkillResource) -> void:
	if !is_instance_valid(agent) or !is_instance_valid(target) or !is_instance_valid(skill):
		return
	
	# Generate unique key for this DoT effect
	var dot_key = "dot_" + str(agent.get_instance_id()) + "_" + str(target.get_instance_id()) + "_" + str(skill.get_instance_id())
	
	# Remove any old timer for this combination
	if resourceTimers.has(dot_key) and is_instance_valid(resourceTimers[dot_key]):
		resourceTimers[dot_key].queue_free()
		resourceTimers.erase(dot_key)
	
	# Calculate total number of ticks
	var total_ticks = int(skill.duration / skill.tickInterval)
	if total_ticks <= 0:
		total_ticks = 1
	
	# Create DoT data
	var dot_data = DotData.new()
	dot_data.agent_id = agent.get_instance_id()
	dot_data.target_id = target.get_instance_id()
	dot_data.skill_ref = skill
	dot_data.current_tick = 1  # Start at 1 (first tick applied immediately)
	dot_data.total_ticks = total_ticks
	
	# Store the data
	dotDataMap[dot_key] = dot_data
	
	# Create the visual effect
	skill.CreateEffectVisual(target, skill)
	
	# Apply initial damage/healing tick immediately
	skill.ApplyTickEffect(agent, target, skill)
	
	# Only start timer if there are more ticks to apply
	if total_ticks > 1:
		# Create tick timer
		var tick_timer = Timer.new()
		tick_timer.name = "DoTTimer_" + dot_key
		add_child(tick_timer)
		tick_timer.one_shot = false  # Repeating timer
		tick_timer.wait_time = skill.tickInterval
		
		# Store timer reference
		resourceTimers[dot_key] = tick_timer
		
		# Store the dot_key in the timer for callback reference
		tick_timer.set_meta("dot_key", dot_key)
		
		# Connect timeout signal to handler
		tick_timer.timeout.connect(_on_dot_tick.bind(tick_timer))
		
		# Start timer
		tick_timer.start()

# Handle DoT tick events
func _on_dot_tick(timer: Timer) -> void:
	if !timer.has_meta("dot_key"):
		timer.queue_free()
		return
	
	var dot_key = timer.get_meta("dot_key")
	if !dotDataMap.has(dot_key):
		if resourceTimers.has(dot_key):
			resourceTimers.erase(dot_key)
		timer.queue_free()
		return
	
	var dot_data = dotDataMap[dot_key]
	
	# Get the agent and target instances
	var agent = instance_from_id(dot_data.agent_id)
	var target = instance_from_id(dot_data.target_id)
	var skill = dot_data.skill_ref
	
	# Check if objects are still valid
	if !is_instance_valid(agent) or !is_instance_valid(target) or !is_instance_valid(skill):
		# Clean up
		dotDataMap.erase(dot_key)
		if resourceTimers.has(dot_key):
			resourceTimers.erase(dot_key)
		timer.queue_free()
		return
	
	# Increment tick counter
	dot_data.current_tick += 1
	
	# Apply damage/healing for this tick
	skill.ApplyTickEffect(agent, target, skill)
	
	# Debug print (can remove later)
	print("DoT tick " + str(dot_data.current_tick) + "/" + str(dot_data.total_ticks) + 
		  " applied to " + target.Name + " from " + agent.Name + 
		  " with skill " + skill.Name)
	
	# Check if we're done with all ticks
	if dot_data.current_tick >= dot_data.total_ticks:
		# Clean up
		dotDataMap.erase(dot_key)
		if resourceTimers.has(dot_key):
			resourceTimers.erase(dot_key)
		timer.queue_free()
		print("DoT finished: " + skill.Name)
