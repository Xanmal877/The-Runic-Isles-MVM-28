class_name SaveSystem extends Resource

#region Variables

@export_group("Character Details")
@export_subgroup("Basic Info")
@export var character_name: String = ""
@export var save_timestamp: String = ""

@export_subgroup("Stats")
@export var health: float = 0.0
@export var max_health: float = 0.0
@export var damage: float = 0.0
@export var defense: float = 0.0

@export_subgroup("Movement")
@export var speed: int = 0
@export var normal_speed: int = 0
@export var run_speed: int = 0
@export var acceleration: float = 0.0
@export var jump_height: float = 0.0
@export var direction: Vector2 = Vector2.ZERO
@export var last_direction: Vector2 = Vector2.ZERO

@export_subgroup("Game State")
@export var position: Vector2 = Vector2.ZERO
@export var enemies_detected: Array = []

#endregion

#region Character Saves

static func save_character(agent: BaseCharacter) -> bool:
	var save_game: SaveSystem = SaveSystem.new()
	@warning_ignore("shadowed_variable")
	var character_name: String = agent.name

	if !DirAccess.dir_exists_absolute("user://SaveGames/"):
		DirAccess.make_dir_absolute("user://SaveGames/")

	var path_name: String = "user://SaveGames/" + character_name + ".tres"

	# Basic info
	save_game.character_name = character_name
	save_game.save_timestamp = Time.get_datetime_string_from_system()

	# Stats
	save_game.health = agent.health
	save_game.max_health = agent.max_health
	save_game.damage = agent.damage
	save_game.defense = agent.defense

	# Movement
	save_game.speed = agent.speed
	save_game.normal_speed = agent.normal_speed
	save_game.run_speed = agent.run_speed
	save_game.acceleration = agent.acceleration

	save_game.position = agent.get_global_position()
	save_game.jump_height = agent.jump_height
	save_game.direction = agent.direction
	save_game.last_direction = agent.last_direction
	save_game.enemies_detected = agent.enemies_detected.duplicate()

	# Save with error handling
	var error = ResourceSaver.save(save_game, path_name)
	if error == OK:
		print("Character '", character_name, "' saved successfully")
		return true
	else:
		print("Failed to save character '", character_name, "'. Error code: ", error)
		return false

static func load_character(agent: BaseCharacter) -> bool:
	@warning_ignore("shadowed_variable")
	var character_name: String = agent.name
	var path_name: String = "user://SaveGames/" + character_name + ".tres"

	# Check if save file exists
	if not FileAccess.file_exists(path_name):
		print("No save file found for character: ", character_name)
		return false

	# Load with error handling
	var load_game: SaveSystem = ResourceLoader.load(path_name)
	if load_game == null:
		print("Failed to load save file for character: ", character_name)
		return false

	# Apply loaded data to agent
	agent.health = load_game.health
	agent.max_health = load_game.max_health
	agent.damage = load_game.damage
	agent.defense = load_game.defense
	agent.speed = load_game.speed
	agent.normal_speed = load_game.normal_speed
	agent.run_speed = load_game.run_speed
	agent.acceleration = load_game.acceleration
	agent.direction = load_game.direction
	agent.last_direction = load_game.last_direction

	# Set position if agent supports it
	agent.set_global_position(load_game.position)

	print("Character '", character_name, "' loaded successfully")
	return true

@warning_ignore("shadowed_variable")
static func delete_character_save(character_name: String) -> bool:
	var path_name: String = "user://saveGame_" + character_name + ".tres"
	if FileAccess.file_exists(path_name):
		var error = DirAccess.remove_absolute(path_name)
		return error == OK
	return false

@warning_ignore("shadowed_variable")
static func get_save_info(character_name: String) -> Dictionary:
	var path_name: String = "user://saveGame_" + character_name + ".tres"

	if not FileAccess.file_exists(path_name):
		return {}

	var save_data: SaveSystem = ResourceLoader.load(path_name)
	if save_data == null:
		return {}

	return {
		"character_name": save_data.character_name,
		"timestamp": save_data.save_timestamp,
		"health": save_data.health,
		"max_health": save_data.max_health,
		"level_or_position": save_data.position
	}

#endregion
