class_name WanderState extends StateMachine

# Parameters for wandering
var spawnPosition: Vector2
var wanderDistance: int = 100
signal wanderComplete

func _ready():
	# Set spawn position as center point
	spawnPosition = agent.global_position

func HandleState() -> void:
	agent.isProcessingState = true
	GenerateWanderTarget()
	
	# Move towards target using direct velocity control
	var move_direction = sign(agent.currentExploreTarget.x - agent.global_position.x)
	var move_speed = 50.0
	
	# Set the agent's direction for animations
	agent.direction = Vector2(move_direction, 0)
	
	# Move until we reach the target
	while abs(agent.currentExploreTarget.x - agent.global_position.x) > 5:
		agent.velocity.x = move_direction * move_speed
		await get_tree().process_frame
	
	# Stop moving
	agent.velocity.x = 0
	agent.direction = Vector2.ZERO  # Stop direction when done
	
	agent.isProcessingState = false
	wanderComplete.emit()

func GenerateWanderTarget() -> void:
	var random_direction = [-1, 1].pick_random()
	var offset = randi_range(50, wanderDistance)
	agent.currentExploreTarget = Vector2(spawnPosition.x + (random_direction * offset), 0)
