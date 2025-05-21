extends Node2D


@onready var parent: Object = get_parent()
@onready var parent_health_ratio: float = parent.health / parent.max_health


func _process(delta):
	positive_health_change()
	positive_alteration()
	negative_health_change()
	negative_alteration()
	alteration_color_switch()
	update_max_health()


func positive_health_change() -> void:
	if $HealthBar.value < parent.health:
		$HealthBar.value = lerp($HealthBar.value, parent.health, 0.05)


func positive_alteration() -> void:
	if $AlterationBar.value < parent.health:
		$AlterationBar.value = lerp($AlterationBar.value, parent.health, 0.5)


func negative_health_change() -> void:
	if parent.health < $HealthBar.value:
		$HealthBar.value = lerp($HealthBar.value, parent.health, 0.5)


func negative_alteration() -> void:
	if parent.health < $AlterationBar.value:
		$AlterationBar.value = lerp($AlterationBar.value, parent.health, 0.05)


func alteration_color_switch() -> void:
	if parent.health < $AlterationBar.value:
		$AlterationBar.get("theme_override_styles/fill").bg_color = Color8(255, 150, 0)
	
	if $AlterationBar.value < parent.health:
		$AlterationBar.get("theme_override_styles/fill").bg_color = Color8(0, 150, 0)


func update_max_health() -> void:
	$HealthBar.max_value = parent.max_health
	$AlterationBar.max_value = parent.max_health


func debug() -> void:
	print(
		"PH[" + str(parent.health) + "]" 
		+ " HB[" + str($HealthBar.value) + "]"
		+ " AB[" + str($AlterationBar.value) +"]"
	)
