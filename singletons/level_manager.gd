# level_manager.gd (Add as AutoLoad)
extends Node

var level_scenes = {}

func _ready():
	# Preload all levels here - no circular dependencies
	level_scenes["level_0"] = preload("res://scenes/levels/level_0.tscn")
	level_scenes["level_1"] = preload("res://scenes/levels/level_1.tscn")
	level_scenes["level_2"] = preload("res://scenes/levels/level_2.tscn")

func get_level(level_id: String) -> PackedScene:
	return level_scenes.get(level_id)
