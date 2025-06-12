class_name BaseEnemy extends BaseCharacter

func _physics_process(delta: float) -> void:
	# Apply gravity when in the air
	if not is_on_floor():
		velocity.y += gravity * delta
	handle_animations()

	move_and_slide()

func setup_state_machine():
	wander.name = "Wander Action"
	wander.agent = self
	state_machine.add_child(wander)
	wander.connect("wanderComplete", state_machine_logic)

	rest_state.name = "Rest Action"
	rest_state.agent = self
	state_machine.add_child(rest_state)

	choose_target.name = "Choose Target Action"
	choose_target.agent = self
	state_machine.add_child(choose_target)
	choose_target.connect("targetChosen", handle_state_machine)

	select_skill.name = "Select Skill Action"
	select_skill.agent = self
	state_machine.add_child(select_skill)
	select_skill.connect("skillPicked", handle_state_machine)

	use_skill.name = "Select Skill Action"
	use_skill.agent = self
	state_machine.add_child(use_skill)
	use_skill.connect("FinishedCasting", handle_state_machine)

	positioning.name = "Combat Positioning"
	positioning.agent = self
	state_machine.add_child(positioning)
	positioning.connect("positionComplete", handle_state_machine)

	await get_tree().create_timer(1).timeout

	state_machine_logic()

func state_machine_logic():
	if isProcessingState:
		return

	set_task("rest")

	set_task("wander")
	
	if !enemies_detected.is_empty():
		set_task("Choose Target")

	handle_state_machine()

func handle_state_machine():
	match current_task:
		"rest":
			rest_state.HandleState()
		"wander":
			wander.HandleState()
		"Choose Target":
			choose_target.HandleState()
		"Pick Skill":
			pass
			#select_skill.HandleState()
		"Take Position":
			positioning.HandleState()
		"Use Skill":
			use_skill.HandleState()


func handle_animations():
	if direction != Vector2.ZERO:
		last_direction = direction
		animation_tree.handle_walking_anim(true)
	else:
		animation_tree.handle_walking_anim(false)
	
	animation_tree.update_blend()
