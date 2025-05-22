# Add this to your AnimationTree script
extends AnimationTree
@export var agent: BaseCharacter

func handle_walking_anim(value: bool):
	self["parameters/conditions/Idle"] = !value
	self["parameters/conditions/Walk"] = value

func handle_jump_anim():
	# Reset other conditions first
	self["parameters/conditions/Idle"] = false
	self["parameters/conditions/Walk"] = false
	# Set jump condition
	self["parameters/conditions/Jump"] = true

func handle_jump_end():
	# Reset jump condition when landing
	self["parameters/conditions/Jump"] = false

func update_blend():
	self["parameters/Idle/blend_position"] = agent.last_direction
	self["parameters/Walk/blend_position"] = agent.last_direction
	self["parameters/Jump/blend_position"] = agent.last_direction
