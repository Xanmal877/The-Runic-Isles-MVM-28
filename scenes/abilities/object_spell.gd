extends AnimatableBody2D
class_name ObjectSpells

@onready var body: AnimatableBody2D = $"."
@onready var barrier: CollisionShape2D = $Barrier
@onready var sprite: Sprite2D = $Sprite2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var spell_anim: AnimationPlayer = $AnimationPlayer
@onready var effect_area: Area2D = $AoE
@onready var spells: SpellProjectileResource
@onready var player: Player

func _ready() -> void:
	spell_anim.play(spells.Name)

func _physics_process(delta: float) -> void:
	if spells.spell_duration == 0:
		body.queue_free()
