class_name Player extends BaseCharacter

func _physics_process(delta: float) -> void:
	# Apply movement with acceleration
	handle_movement(delta)
	# Actually move the character
	move_and_slide()

func handle_movement(delta) -> void:
	handle_basic_movement(delta)
	handle_jump(delta)

func handle_basic_movement(delta):
	# Get movement input
	direction.x = Input.get_axis("walk_left", "walk_right")
	
	if direction.x != 0:
		# Apply acceleration when moving - Fixed formula
		# Just use speed directly instead of speed*speed
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
	else:
		# Apply friction - gradual slowdown is more natural than instant stop
		velocity.x = move_toward(velocity.x, 0, acceleration * delta)
	
	# Handle running (shift)
	if Input.is_action_pressed("run"):
		speed = run_speed
	else:
		speed = normal_speed

	# Store the last non-zero direction for animations
	if direction != Vector2.ZERO:
		last_direction = direction

func handle_jump(delta):
	# Apply gravity when in the air
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle jumping - Fixed formula for consistent jump height
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		# For a consistent jump height, use this formula instead
		velocity.y = -sqrt(2 * gravity * jump_height)
