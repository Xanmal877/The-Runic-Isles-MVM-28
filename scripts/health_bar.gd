extends ProgressBar

@onready var parent = get_parent()

func _process(delta):
	max_value = parent.max_health
	min_value = 0
	value     = parent.current_health
