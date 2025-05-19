extends Control

@onready var Parent     = get_parent()
@onready var Health     = $Health
@onready var Alteration = $Alteration

@onready var parent_health_ratio : float = Parent.current_health / Parent.max_health
@onready var bar_health_ratio    : float = Health.size.x / Health.value

func alteration_position() -> Vector2:
	var _parent_health_ratio : float = Parent.current_health / Parent.max_health
	return Vector2(Health.size.x * _parent_health_ratio, Health.position.y + Health.size.y)

func _process(delta):
	
	var tween_health_value = create_tween()
	var tween_alteration_position = create_tween()
	Health.max_value = Parent.max_health
	Health.min_value = 0

	tween_health_value.tween_property(Health    , "value"   , Parent.current_health, 1)
	tween_alteration_position.tween_property(Alteration, "position", alteration_position(), 1)
	
	Alteration.max_value = Parent.current_health - Health.value
	Alteration.value = Parent.current_health - Health.value
