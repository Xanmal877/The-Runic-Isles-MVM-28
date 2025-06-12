extends PanelContainer

#region export
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
@export_range(0, 1, 0.1) var animation_duration: float = 0.4
## The shake duration (in seconds) after damage was received.
@export_range(0, 1, 0.1) var shake_duration: float = 0.2
## The strength of the shake.
@export_range(0, 10, 0.1) var shake_strength: float = 4

#endregion

#region variables

var agent_health_copy: int : set = _on_agent_health_changed
var agent_health_ratio: float

#endregion

#region gameloop

func _ready():
	if agent == null:
		agent = get_parent()
	update_properties()


func _process(_delta):
	update_properties()
	handle_shake()
	handle_flash()
	debug_values(false)

func _on_agent_health_changed(new_health):
	if agent_is("damaged"):
		health_bar("tween", "value", animation_duration)
		$AlterationTweenTimer.start(animation_duration)
		alteration_bar("set", "color", damage_color)
		$ShakeTimer.start(shake_duration)
	
	elif agent_is("healed"):
		alteration_bar("tween", "value", animation_duration)
		$HealthTweenTimer.start(animation_duration)
		alteration_bar("set", "color", heal_color)
	
	agent_health_copy = new_health


func _on_alteration_tween_timer_timeout():
	alteration_bar("tween", "value", animation_duration)


func _on_health_tween_timer_timeout():
	health_bar("tween", "value", animation_duration)

#endregion

#region functions

func update_properties() -> void:
	if is_instance_valid(agent):
		agent_health_copy = agent.health
		agent_health_ratio = agent.health / agent.max_health
		$Health.max_value = agent.max_health
		$Alteration.max_value = agent.max_health


func handle_shake() -> void:
	if not $ShakeTimer.is_stopped():
		shake_effect(true)
	else:
		shake_effect(false)


func shake_effect(shake: bool) -> void:
	if shake:
		var random_x: float = randf_range(-shake_strength, shake_strength)
		var random_y: float = randf_range(-shake_strength, shake_strength)
		var random_position: Vector2 = Vector2(random_x, random_y).round()
		$Background.position = random_position
		$Alteration.position = random_position
		$Health.position = random_position
		$Frame.position = random_position
		$Shading.position = random_position
	
	else:
		$Background.position = Vector2.ZERO
		$Alteration.position = Vector2.ZERO
		$Health.position = Vector2.ZERO
		$Shading.position = Vector2.ZERO
		$Frame.position = Vector2.ZERO


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


func alteration_bar(method: String = "", property: String = "", value: Variant = null):
	if method == "set" and property == "color":
		$Alteration.get("theme_override_styles/fill").bg_color = value
	
	elif method == "set" and property == "alpha":
		$Alteration.get("theme_override_styles/fill").bg_color.a = value
	
	elif method == "get" and property == "color":
		return $Alteration.get("theme_override_styles/fill").bg_color
	
	elif method == "get" and property == "alpha":
		return $Alteration.get("theme_override_styles/fill").bg_color.a
	
	elif method == "add" and property == "alpha":
		$Alteration.get("theme_override_styles/fill").bg_color.a += value
	
	elif method == "subtract" and property == "alpha":
		$Alteration.get("theme_override_styles/fill").bg_color.a -= value
	
	elif method == "tween":
		create_tween().tween_property($Alteration, property, agent.health, value)
	
	else:
		push_error("wrong count or wrong type of argument supplied")


func health_bar(method: String = "", property: String = "", value: Variant = null):
	if method == "set" and property == "color":
		$Health.get("theme_override_styles/fill").bg_color = value
	
	elif method == "set" and property == "alpha":
		$Health.get("theme_override_styles/fill").bg_color.a = value
	
	elif method == "get" and property == "color":
		return $Health.get("theme_override_styles/fill").bg_color
	
	elif method == "get" and property == "alpha":
		return $Health.get("theme_override_styles/fill").bg_color.a
	
	elif method == "add" and property == "alpha":
		$Health.get("theme_override_styles/fill").bg_color.a += value
	
	elif method == "subtract" and property == "alpha":
		$Health.get("theme_override_styles/fill").bg_color.a -= value
	
	elif method == "tween":
		create_tween().tween_property($Health, property, agent.health, value)
	
	else:
		push_error("wrong count or wrong type of argument supplied")


func debug_values(debug: bool) -> void:
	if debug:
		print(
			"agent_health: " + str(agent.health) + "    "
			+ "bar_health: " + str($Health.value) + "    "
			+ "bar_alteration: " + str($Alteration.value)
		)

#endregion
