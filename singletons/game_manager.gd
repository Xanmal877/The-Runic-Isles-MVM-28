extends Node

static var selectedTarget: Node2D

var menus_open := {
	"character_sheet": false,
	"inventory": false,
	"shop": false,
	"skill_tree": false
}

var resourceTimerSystem: ResourceTimers = ResourceTimers.new()

func _ready() -> void:
	add_child(resourceTimerSystem)
