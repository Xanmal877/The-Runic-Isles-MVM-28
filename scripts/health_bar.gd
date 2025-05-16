extends Node2D


#region signal
func _on_alteration_tween_timer_timeout():
	handle_negative_alteration()


func _on_health_tween_timer_timeout():
	handle_positive_health_change()
#endregion


#region export
## The [member Host] of the [annotation HealthBar].   [br]
## [b][u]Asigning a [member Host] is optional.[/u][/b][br]
## The Host will default to this Node's parent.       [br]
## You can assign another Host than the Node's parent if you need to.
@export var host: Node

## The [annotation Color] that will be used to indicate heal.
@export var heal_color: Color = Color8(0, 150, 0)

## The [annotation Color] that will be used to indicate damage.
@export var damage_color: Color = Color8(210, 110, 0)

## The [annotation Color] that will be used to indicate health.
@export var health_color: Color = Color8(150, 0, 0)

## The [member size] of the [annotation Healthbar]
@export var size: Vector2i = Vector2i(256, 16)

## The [member reaction] can be tweaked to change how reactive 
## the [annotation HealthBar] behaves.
@export var reaction: float = 0.4
#endregion


#region var
var host_health_copy: int : set = _on_host_health_change
var host_health_ratio: float

var tween_positive_health_change: Tween
var tween_negative_health_change: Tween
var tween_positive_alteration: Tween
var tween_negative_alteration: Tween
#endregion


#region gameloop
func _ready():
	if host is not Node:
		host = get_parent()
	host_health_copy = host.health
	host_health_ratio = host.health / host.max_health


func _process(_delta):
	set_health_bar_color(health_color)
	update_max_health()
	update_health()
	update_size()
#endregion


#region func
func _on_host_health_change(param1):
	if host.health < host_health_copy:
		handle_negative_health_change()
		set_alteration_bar_color(damage_color)
		#print("dmg was applied")
	
	elif host.health > host_health_copy:
		handle_positive_alteration()
		set_alteration_bar_color(heal_color)
		#print("heal was applied")
	
	host_health_copy = param1


func handle_positive_health_change() -> void:
	if tween_positive_health_change is Tween:
		tween_positive_health_change.kill()
		#print("tween positive health change killed")
	
	tween_positive_health_change = create_tween()
	tween_positive_health_change.tween_property($HealthBar, "value", host.health, reaction)
	#print("tween positive health change started")


func handle_positive_alteration() -> void:
	if tween_positive_alteration is Tween:
		tween_positive_alteration.kill()
		#print("tween positive alteration killed")
	
	$HealthTweenTimer.start(reaction)
	tween_positive_alteration = create_tween()
	tween_positive_alteration.tween_property($AlterationBar, "value", host.health, reaction)
	#print("tween positive alteration started")


func handle_negative_health_change() -> void:
	if tween_negative_health_change is Tween:
			tween_negative_health_change.kill()
			#print("tween negative health change killed")
		
	$AlterationTweenTimer.start(reaction)
	tween_negative_health_change = create_tween()
	tween_negative_health_change.tween_property($HealthBar, "value", host.health, reaction)
	#print("tween negative health change started")


func handle_negative_alteration() -> void:
	if tween_negative_alteration is Tween:
		tween_negative_alteration.kill()
		#print("tween negative alteration killed")
	
	tween_negative_alteration = create_tween()
	tween_negative_alteration.tween_property($AlterationBar, "value", host.health, reaction)
	#print("tween negative alteration started")


func set_health_bar_color(color) -> void:
	$HealthBar.get("theme_override_styles/fill").bg_color = color


func set_alteration_bar_color(color: Color) -> void:
	$AlterationBar.get("theme_override_styles/fill").bg_color = color


func update_max_health() -> void:
	$HealthBar.max_value = host.max_health
	$AlterationBar.max_value = host.max_health


func update_health() -> void:
	host_health_copy = host.health


func update_size() -> void:
	$HealthBar.size = size
	$AlterationBar.size = size


func debug() -> void:
	print(
		"PH[" + str(host.health) + "]" 
		+ " HB[" + str($HealthBar.value) + "]"
		+ " AB[" + str($AlterationBar.value) +"]"
	)
#endregion
