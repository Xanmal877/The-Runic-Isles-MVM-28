extends Control

@export var bar_size     : Vector2i = Vector2i(256 , 32)
@export var frame_width  : int      = 4
@export var frame_color  : Color    = Color8(0  , 0  , 0  , 255)
@export var health_color : Color    = Color8(175, 0  , 0  , 255)
@export var text_color   : Color    = Color8(255, 255, 255, 225)
@export var show_text    : bool     = true

func apply_properties() -> void:
	size = bar_size
	$HealthBarFrame.size = size
	
	$HealthBarHealth.size     = Vector2i(bar_size.x - frame_width  , bar_size.y - frame_width  )
	$HealthBarHealth.position = Vector2i(position.x + frame_width/2, position.y + frame_width/2)
	
	$HealthBarLabel.self_modulate = text_color
	
	if show_text:
		$HealthBarLabel.text = "100%"

func _process(delta) -> void:
	apply_properties()
