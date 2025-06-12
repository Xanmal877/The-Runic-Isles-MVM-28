class_name ResetState extends StateMachine

var resetTimer: Timer
var waitTimer: Timer

func _ready() -> void:
	# Create timers
	resetTimer = Timer.new()
	resetTimer.one_shot = true
	resetTimer.wait_time = 10.0  # 10 seconds of no movement
	add_child(resetTimer)
	
	waitTimer = Timer.new()
	waitTimer.one_shot = true
	waitTimer.wait_time = 2.0  # 2 seconds wait after reset
	add_child(waitTimer)

func HandleState() -> void:
	# This is called when explicitly transitioning to ResetState
	agent.speech_bubble.text = "Resetting..."
	PerformReset()
	waitTimer.start()
	await waitTimer.timeout
	agent.StateMachineLogic()

func PerformReset() -> void:
	# Reset all navigation and state variables
	agent.currentTarget = null
	agent.navAgent.set_target_position(agent.global_position)
	agent.direction = Vector2.ZERO
	agent.velocity = Vector2.ZERO
	agent.animDirection = Vector2.ZERO
	
	# Optional: Clear any task-specific variables
	agent.set_task("Idle")
