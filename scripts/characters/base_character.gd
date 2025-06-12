class_name BaseCharacter extends CharacterBody2D

#region variables

@onready var rest_state: RestState = RestState.new()
@onready var choose_target: ChooseTargetAction = ChooseTargetAction.new()
@onready var select_skill: SelectSkillAction = SelectSkillAction.new()
@onready var positioning: CombatPositioningAction = CombatPositioningAction.new()
@onready var use_skill: UseSkillAction = UseSkillAction.new()
@onready var wander: WanderState = WanderState.new()

var health: float = 0.0
var max_health: float = 0.0
var damage: float = 0.0
var defense: float = 0.0


var speed: int = 0
var normal_speed: int = 0
var run_speed: int = 0

var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO

var enemies_detected: Array = []
var current_combat_target: BaseCharacter
var currentExploreTarget: Vector2

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var isProcessingState: bool = false
var current_task
var casting: bool = false

enum factions {PLAYER,ENEMY}

@export var current_faction: factions

@onready var character_sprite: Sprite2D = $"Character Sprite"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: Node = $"State Machine"

@export var skill_manager: SkillManager

#endregion

func _ready() -> void:
	setup_character()
	setup_state_machine()

func setup_character():
	pass

func setup_state_machine():
	pass

func state_machine_logic():
	pass

func handle_state_machine():
	pass

func set_task(task: String):
	current_task = task

func character_detected(body: Node2D) -> void:
	if body is BaseCharacter and body.current_faction != current_faction:
		enemies_detected.append(body)
		print(self.name + " Has found Enemy: " + body.name)

func character_exited(_body: Node2D) -> void:
	pass # Replace with function body.

func check_killed():
	if health <= 0:
		queue_free()
		if self is Player:
			get_tree().quit()
