class_name Player extends BaseCharacter

@export var animtree: AnimationTree

var jumping: bool = false

func _physics_process(delta: float) -> void:
	# Apply movement with acceleration
	handle_movement(delta)
	handle_animations()
	# Actually move the character
	move_and_slide()

func _input(_event: InputEvent) -> void:
	primary_attack()
	save_game()
	load_game()

func handle_movement(delta) -> void:
	handle_basic_movement(delta)
	handle_jump(delta)

func handle_basic_movement(delta):
	# Get movement input
	direction.x = Input.get_axis("walk_left", "walk_right")
	
	if direction.x != 0:
		velocity.x = direction.x * (speed * speed) * delta
	else:
		# Apply friction - gradual slowdown is more natural than instant stop
		velocity.x = 0.0
	
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
		# Don't set jumping to false here - let it complete naturally
	else:
		# Only reset jumping when we land
		if jumping:
			jumping = false
			animtree.handle_jump_end()  # New function to reset jump condition

	# Handle jumping - start jump
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		jumping = true
		animtree.handle_jump_anim()
		velocity.y = -sqrt(2 * gravity * jump_height)

func handle_animations():
	if jumping:
		# Don't handle walk/idle animations while jumping
		return
	
	if direction != Vector2.ZERO:
		animtree.handle_walking_anim(true)
	else:
		animtree.handle_walking_anim(false)
	
	animtree.update_blend()

func primary_attack():
	if Input.is_action_just_pressed("primary_attack"):
		if !enemies_detected.is_empty():
			for enemy in enemies_detected:
				if is_instance_valid(enemy) and global_position.distance_to(enemy.global_position) <= 50:
					enemy.health -= damage
					print("Damaged: " + str(enemy.name) + "remaining health: " + str(enemy.health))
					check_killed()
					enemy.check_killed()

func save_game():
	if Input.is_action_just_pressed("look_up"):
		SaveSystem.save_character(self)

func load_game():
	if Input.is_action_just_pressed("look_down"):
		SaveSystem.load_character(self)
