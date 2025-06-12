extends AnimationTree

@export var agent: BaseCharacter

func handle_walking_anim(value: bool):
	self["parameters/conditions/Idle"] = not value
	self["parameters/conditions/Walk"] = value

func update_blend():
	self["parameters/Idle/blend_position"] = agent.last_direction.x
	self["parameters/Walk/blend_position"] = agent.last_direction.x
