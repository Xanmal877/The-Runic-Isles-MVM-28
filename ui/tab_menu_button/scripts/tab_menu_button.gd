@tool
@icon("res://ui/tab_menu_button/assets/spr_tab_menu_button_normal.png")
class_name TabMenuButton extends TextureButton


## The [color=light_blue].tscn[/color] to instantiate/free on button pressed/released
@export var menu_instance: PackedScene


var canvas_layer: CanvasLayer
var child: Control


func _ready():
	toggle_mode = true
	texture_normal = load("res://ui/tab_menu_button/assets/spr_tab_menu_button_normal.png")
	texture_pressed = load("res://ui/tab_menu_button/assets/spr_tab_menu_button_pressed.png")
	texture_hover = load("res://ui/tab_menu_button/assets/spr_tab_menu_button_hover.png")
	size = texture_normal.get_size()
	canvas_layer = get_parent()


func _on_toggled(toggled_on):
	if toggled_on:
		menu("open")
	else:
		menu("close")


func menu(method: String = "") -> void:
	if method == "open":
		child = menu_instance.instantiate()
		canvas_layer.add_child(child)
	
	elif method == "close":
		var child_index = child.get_index()
		canvas_layer.get_child(child_index).queue_free()
	
	else:
		push_error("invalid [method: String] supplied.")
