extends Area2D
class_name ProjectileSpells

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var spell_anim: AnimationPlayer = $AnimationPlayer
@onready var spells: SpellProjectileResource

func _ready() -> void:
	spell_anim.play(spells.Name)
