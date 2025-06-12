class_name RestState extends StateMachine

signal restComplete

func HandleState() -> void:
	agent.isProcessingState = true

	# Stop movement
	agent.velocity.x = 0

	# Start rest timer
	var restTime = randi_range(1,3)
	await get_tree().create_timer(restTime).timeout

	agent.isProcessingState = false
	restComplete.emit()
