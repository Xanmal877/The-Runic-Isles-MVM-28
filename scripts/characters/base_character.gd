class_name BaseCharacter extends CharacterBody2D

@export_group("Character Details")

@export_subgroup("Stats")
@export var health: int = 0
@export var max_health: int = 0
@export var damage: int = 0
@export var defense: int = 0

@export_subgroup("Movement")
@export var speed: int = 0
@export var normal_speed: int = 0
@export var run_speed: int = 0
@export var acceleration: float = 0.0

@export var jump_height: float = 0.0

var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var character_sprite: Sprite2D = $"Character Sprite"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
