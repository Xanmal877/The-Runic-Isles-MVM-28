class_name BaseCharacter extends CharacterBody2D

@export_group("Character Details")

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

var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO

var enemies_detected: Array = []
var current_combat_target: BaseCharacter

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum factions {PLAYER,ENEMY}
@export var current_faction: factions

@onready var character_sprite: Sprite2D = $"Character Sprite"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree

func character_detected(body: Node2D) -> void:
	if body is BaseCharacter and body.current_faction != current_faction:
		enemies_detected.append(body)
		print("Enemy found")

func character_exited(body: Node2D) -> void:
	pass # Replace with function body.

func check_killed():
	if health <= 0:
		queue_free()
