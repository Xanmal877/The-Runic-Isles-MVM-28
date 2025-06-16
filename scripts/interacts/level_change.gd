class_name LevelChange extends Area2D
@export var target_level_id: String = "level_0"
@export var spawn_point_name: String = "EnterLocation"
var can_interact = false
var player: BaseCharacter
var world: Node2D

func _process(_delta):  # Fixed syntax
	if can_interact and Input.is_action_just_pressed("Interact"):
		transition_to_level()

func transition_to_level():
	if target_level_id.is_empty():
		print("No target level ID configured")
		return
		
	player = get_tree().get_first_node_in_group("Player")
	world = get_tree().get_first_node_in_group("World")
	
	if not player or not world:
		print("Missing required components for level transition")
		return
	
	# Get level from manager
	var level_scene = LevelManager.get_level(target_level_id)
	if not level_scene:
		print("Level not found: " + target_level_id)
		return
	
	# Remove old level first
	remove_current_level()
	
	# Add new level
	var level = level_scene.instantiate()
	world.add_child(level)
	
	# Set player position
	set_player_position(level, spawn_point_name)

func remove_current_level():
	for child in world.get_children():
		if not child.is_in_group("Player") and not child.is_in_group("UI"):
			if child.name.begins_with("level") or child.has_meta("is_level"):
				child.queue_free()

func set_player_position(level: Node, spawn_name: String):
	var spawn_point = level.get_node_or_null(spawn_name)
	
	if not spawn_point:
		# Try fallback names
		var spawn_names = ["EnterLocation", "SpawnPoint", "PlayerSpawn", "Enter", "Spawn"]
		for fallback_name in spawn_names:
			spawn_point = level.get_node_or_null(fallback_name)
			if spawn_point:
				break
	
	if spawn_point:
		player.global_position = spawn_point.global_position
		print("Player moved to: " + str(spawn_point.global_position))
	else:
		print("Warning: No spawn point found in new level")

func BodyEnteredArea(body: Node2D) -> void:
	if body.is_in_group("Player"):
		can_interact = true
		print("Player can exit level")

func BodyLeftArea(body: Node2D) -> void:
	if body.is_in_group("Player"):
		can_interact = false
		print("Player moved away from exit")
