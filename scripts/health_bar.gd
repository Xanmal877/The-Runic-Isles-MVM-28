extends Node2D


func _on_alteration_tween_timer_timeout():
	handle_negative_alteration()


func _on_health_tween_timer_timeout():
	handle_positive_health_change()


@export var parent: Node
var parent_health_copy: int : set = _on_parent_health_change
var parent_health_ratio: float

var tween_positive_health_change: Tween
var tween_negative_health_change: Tween
var tween_positive_alteration: Tween
var tween_negative_alteration: Tween

@export var heal_color: Color = Color8(0, 150, 0)
@export var damage_color: Color = Color8(255, 150, 0)


func _ready():
	if parent is not Node:
		parent = get_parent()
	parent_health_copy = parent.health
	parent_health_ratio = parent.health / parent.max_health


func _process(delta):	
	parent_health_copy = parent.health
	update_max_health()


func _on_parent_health_change(param1):
	if parent.health < parent_health_copy:
		handle_negative_health_change()
		set_alteration_bar_color(damage_color)
		#print("dmg was applied")
	
	elif parent.health > parent_health_copy:
		handle_positive_alteration()
		set_alteration_bar_color(heal_color)
		#print("heal was applied")
	
	parent_health_copy = param1


func handle_positive_health_change() -> void:
	if tween_positive_health_change is Tween:
		tween_positive_health_change.kill()
		#print("tween positive health change killed")
	
	tween_positive_health_change = create_tween()
	tween_positive_health_change.tween_property($HealthBar, "value", parent.health, 0.2)
	#print("tween positive health change started")


func handle_positive_alteration() -> void:
	if tween_positive_alteration is Tween:
		tween_positive_alteration.kill()
		#print("tween positive alteration killed")
	
	$HealthTweenTimer.start(0.2)
	tween_positive_alteration = create_tween()
	tween_positive_alteration.tween_property($AlterationBar, "value", parent.health, 0.2)
	#print("tween positive alteration started")


func handle_negative_health_change() -> void:
	if tween_negative_health_change is Tween:
			tween_negative_health_change.kill()
			#print("tween negative health change killed")
		
	$AlterationTweenTimer.start(0.2)
	tween_negative_health_change = create_tween()
	tween_negative_health_change.tween_property($HealthBar, "value", parent.health, 0.2)
	#print("tween negative health change started")


func handle_negative_alteration() -> void:
	if tween_negative_alteration is Tween:
		tween_negative_alteration.kill()
		#print("tween negative alteration killed")
	
	tween_negative_alteration = create_tween()
	tween_negative_alteration.tween_property($AlterationBar, "value", parent.health, 0.2)
	#print("tween negative alteration started")


func set_alteration_bar_color(color: Color) -> void:
	$AlterationBar.get("theme_override_styles/fill").bg_color = color


func update_max_health() -> void:
	$HealthBar.max_value = parent.max_health
	$AlterationBar.max_value = parent.max_health


func debug() -> void:
	print(
		"PH[" + str(parent.health) + "]" 
		+ " HB[" + str($HealthBar.value) + "]"
		+ " AB[" + str($AlterationBar.value) +"]"
	)
