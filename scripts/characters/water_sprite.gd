class_name WaterSprite extends BaseEnemy

func _physics_process(delta: float) -> void:
	handle_animations()
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func handle_animations():
	if direction != Vector2.ZERO:
		animation_player.play("walk")
	else:
		animation_player.play("idle")
