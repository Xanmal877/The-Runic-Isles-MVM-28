extends PanelContainer


@export_group("Health Bar")
## The instance this [color=light_green]Health Bar[/color] 
## is related to.[br]
## The [color=light_green]Agent[/color] must contain 
## [color=hot_pink]health[/color] and [color=hot_pink]max_health[/color][br]
## If not assigned, [color=light_green]Agent[/color] will default
## to this [color=light_green]Node[/color]'s Parent.
@export var agent: Node

@export_subgroup("Color")
@export var heal_color: Color = Color8(0, 150, 0)
@export var damage_color: Color = Color8(210, 110, 0)
@export var health_color: Color = Color8(150, 0, 0)

@export_subgroup("Animation")
## The time (in seconds) the [color=light_green]Health Bar[/color]
## will take to animate changes in [color=hot_pink]health[/color].
@export_range(0, 1, 0.05) var animation_duration: float = 0.4
## The shake duration (in seconds) after damage was received.
@export_range(0, 1, 0.05) var shake_duration: float = 0.25
## The strength of the shake.
@export_range(0, 10, 0.05) var shake_strength: float = 4


var agent_health_copy: int : set = _on_agent_health_changed
var agent_health_ratio: float
var health_bar_tween: Tween = create_tween()
var alteration_bar_tween: Tween = create_tween()








func _ready():
	if agent is not Node:
		agent = get_parent()
	update_properties()


func _process(_delta):
	update_properties()
	handle_shake()
	handle_flash()

func _on_agent_health_changed(new_health):
	if agent_is("damaged"):
		health_bar("tween", "", animation_duration)
		$AlterationTweenTimer.start(animation_duration)
		alteration_bar("set", "color", damage_color)
		$ShakeTimer.start(shake_duration)
	
	elif agent_is("healed"):
		#tween_alteration_bar(animation_duration)
		alteration_bar("tween", "", animation_duration)
		$HealthTweenTimer.start(animation_duration)
		alteration_bar("set", "color", heal_color)
	
	agent_health_copy = new_health


func _on_alteration_tween_timer_timeout():
	alteration_bar("tween", "", animation_duration)


func _on_health_tween_timer_timeout():
	health_bar("tween", "", animation_duration)








func update_properties() -> void:
	agent_health_copy = agent.health
	agent_health_ratio = agent.health / agent.max_health
	$HealthBar.max_value = agent.max_health
	$AlterationBar.max_value = agent.max_health


func handle_shake() -> void:
	if not $ShakeTimer.is_stopped():
		shake()
	else:
		reposition_after_shake()


func shake() -> void:
		var random_x: float = randf_range(position.x - shake_strength, position.x + shake_strength)
		var random_y: float = randf_range(position.y - shake_strength, position.y + shake_strength)
		var random_position := Vector2(random_x, random_y).round()
		$HealthBar.position = random_position
		$AlterationBar.position = random_position
		$Shading.position = random_position


func reposition_after_shake() -> void:
	$HealthBar.position = position
	$AlterationBar.position = position
	$Shading.position = position


func handle_flash() -> void:
	if agent_is("low health") and health_bar("get", "alpha") > 0.0:
		health_bar("subtract", "alpha", 0.1)
		alteration_bar("subtract", "alpha", 0.1)
	else:
		health_bar("set", "alpha", 1.0)
		alteration_bar("set", "alpha", 1.0)


func agent_is(question: String = ""):
	if question == "damaged":
		return agent.health < agent_health_copy
	elif question == "healed":
		return agent.health > agent_health_copy
	elif question == "low health":
		return agent_health_ratio < 0.25
	else:
		return false


func tween_health_bar(duration: float) -> void:
	health_bar_tween.kill()
	health_bar_tween = create_tween()
	health_bar_tween.tween_property($HealthBar, "value", agent.health, duration)


func tween_alteration_bar(duration: float) -> void:
	alteration_bar_tween.kill()
	alteration_bar_tween = create_tween()
	alteration_bar_tween.tween_property($AlterationBar, "value", agent.health, duration)


func alteration_bar(method: String = "", property: String = "", value: Variant = null):
	if method == "set" and property == "color":
		$AlterationBar.get("theme_override_styles/fill").bg_color = value
		
	elif method == "set" and property == "alpha":
		$AlterationBar.get("theme_override_styles/fill").bg_color.a = value
	
	if method == "get" and property == "color":
		return $AlterationBar.get("theme_override_styles/fill").bg_color
		
	elif method == "get" and property == "alpha":
		return $AlterationBar.get("theme_override_styles/fill").bg_color.a
	
	if method == "add" and property == "alpha":
		$AlterationBar.get("theme_override_styles/fill").bg_color.a += value
	
	if method == "subtract" and property == "alpha":
		$AlterationBar.get("theme_override_styles/fill").bg_color.a -= value
	
	if method == "tween":
		alteration_bar_tween.kill()
		alteration_bar_tween = create_tween()
		alteration_bar_tween.tween_property($AlterationBar, "value", agent.health, value)


func health_bar(method: String = "", property: String = "", value: Variant = null):
	if method == "set" and property == "color":
		$HealthBar.get("theme_override_styles/fill").bg_color = value
		
	elif method == "set" and property == "alpha":
		$HealthBar.get("theme_override_styles/fill").bg_color.a = value
	
	if method == "get" and property == "color":
		return $HealthBar.get("theme_override_styles/fill").bg_color
		
	elif method == "get" and property == "alpha":
		return $HealthBar.get("theme_override_styles/fill").bg_color.a
	
	if method == "add" and property == "alpha":
		$HealthBar.get("theme_override_styles/fill").bg_color.a += value
	
	if method == "subtract" and property == "alpha":
		$HealthBar.get("theme_override_styles/fill").bg_color.a -= value
	
	if method == "tween":
		alteration_bar_tween.kill()
		alteration_bar_tween = create_tween()
		alteration_bar_tween.tween_property($HealthBar, "value", agent.health, value)


func debug_values() -> void:
	print(
		"PH[" + str(agent.health) + "]" 
		+ " HB[" + str($HealthBar.value) + "]"
		+ " AB[" + str($AlterationBar.value) +"]"
	)
