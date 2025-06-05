@icon("res://ui/mouse_cursor/assets/spr_cursor_arrow_default.png")
class_name MouseCursor extends Node


@export_group("Sprite")
@export var default: CompressedTexture2D
@export var clicked: CompressedTexture2D


func _process(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.set_custom_mouse_cursor(clicked, Input.CURSOR_ARROW)
	else:
		Input.set_custom_mouse_cursor(default, Input.CURSOR_ARROW)
