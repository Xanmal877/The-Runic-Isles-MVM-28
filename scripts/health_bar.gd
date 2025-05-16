extends Control

@onready var frame      = $HealthBarFrame
@onready var health     = $HealthBarHealth
@onready var percentage = $HealthBarPercentage

func _process(delta):
	health.size.x = 80 # <- change this number and run project
	
	
	percentage.text = str( round(health.size.x / 252 * 100) ) + "%"
