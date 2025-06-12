class_name Player extends BaseCharacter

var jumping: bool = false
var jump_height: float = 0.0
var acceleration: float = 0.0
var is_attacking: bool = false  # Add this flag
@onready var pivot: Node2D = $Pivot

func setup_character():
	name = "Player"
	health = 100
	max_health = 100
	
	damage = 10
	defense = 4
	
	normal_speed = 12500
	speed = normal_speed
	run_speed = (normal_speed * 2)
	
	jump_height = 100
	acceleration = 10
	
func turnLeft():
	pivot.scale.x = -1
func turnRight():
	pivot.scale.x = 1
func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_animations()
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("primary_attack"):
		primary_attack()

func handle_movement(delta) -> void:
	handle_basic_movement(delta)
	handle_jump(delta)

func handle_basic_movement(delta):
	# Get movement input
	direction.x = Input.get_axis("walk_left", "walk_right")
	
	if direction.x != 0:
		velocity.x = direction.x * speed * delta  # Fixed: removed extra speed multiplication
		if direction.x > 0:
			turnRight()
		elif direction.x < 0:
			turnLeft()
	else:
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
	else:
		# Only reset jumping when we land
		if jumping:
			jumping = false
			animation_player.play("jump")
	
	# Handle jumping - start jump
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		jumping = true
		animation_player.play("jump")
		velocity.y = -sqrt(2 * gravity * jump_height)

func handle_animations():
	if jumping or is_attacking:  # Don't handle walk/idle while attacking OR jumping
		return
	
	if direction != Vector2.ZERO:
		animation_player.play("run")
		animation_player.speed_scale = abs(velocity.x/120)
	else:
		animation_player.play("stance")
		animation_player.speed_scale = 1

func primary_attack():
	# Guard clause - prevent attack if already attacking
	if is_attacking:
		return

	is_attacking = true
	animation_player.play("attack")

	if !enemies_detected.is_empty():
		for enemy in enemies_detected:
			if is_instance_valid(enemy) and global_position.distance_to(enemy.global_position) <= 100:
				enemy.health -= damage
				#print("Damaged: " + str(enemy.name) + " remaining health: " + str(enemy.health))
				check_killed()
				enemy.check_killed()
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("attack"):
		animation_player.play("stance")
	pass # Replace with function body.


func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name == "stance":
		is_attacking = false
	if anim_name == "run":
		is_attacking = false
	if anim_name == "jump":
		is_attacking = false
	if anim_name == "attack":
		animation_player.speed_scale = 1
	pass # Replace with function body.
