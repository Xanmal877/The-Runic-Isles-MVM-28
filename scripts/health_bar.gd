# Author @McKillerroy
# Add health_bar.tscn as a Child Node to a Parent Node
# The Parent Node must contain "var current_health" & "var max_health"
# Only "current_health" should be modified to apply damage or heals
# Only @export var's should be modified to change the bar's appearence in the inspector dock ->

extends Control

@export var bar_size     : Vector2 = Vector2(256 , 32)
@export var frame_width  : float   = 4
@export var frame_color  : Color   = Color8(0  , 0  , 0  , 255)
@export var health_color : Color   = Color8(175, 0  , 0  , 255)
@export var text_color   : Color   = Color8(255, 255, 255, 225)
@export var show_text    : bool    = true

@onready var host : Object = get_parent()

func get_current_to_max_health_ratio() -> float:
	return (host.current_health / host.max_health)
func get_remaining_health_percentage() -> float:
	return get_current_to_max_health_ratio() * 100

func update_frame()      -> void:
	$HealthBarFrame.position = position
	$HealthBarFrame.size     = bar_size
func update_health()     -> void:
	var _pos_x  : float = position.x + (frame_width / 2)
	var _pos_y  : float = position.y + (frame_width / 2)
	var _size_x : float = (bar_size.x - frame_width) * get_current_to_max_health_ratio()
	var _size_y : float = bar_size.y - frame_width
	
	$HealthBarHealth.position = Vector2(_pos_x, _pos_y)
	$HealthBarHealth.size     = Vector2(_size_x, _size_y)
func update_label()      -> void:
	var _pos_x = position.x + ($HealthBarFrame.size.x / 2) - ($HealthBarLabel.size.x / 2)
	var _pos_y = position.y
	
	$HealthBarLabel.position      = Vector2(_pos_x, _pos_y)
	$HealthBarLabel.self_modulate = text_color
	
	if show_text:
		$HealthBarLabel.text = str(get_remaining_health_percentage()) + "%"
func update_health_bar() -> void:
	update_frame()
	update_health()
	update_label()

@warning_ignore("unused_parameter")
func _process(delta) -> void:
	update_health_bar()
