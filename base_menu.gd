class_name BaseMenu
extends Control


export(Array, NodePath) var buttons := []


func _ready() -> void:
	disable_buttons()
	yield(EventBus, "transitioned")
	enable_buttons()


func enable_buttons():
	for button_path in buttons:
		get_node(button_path).disabled = false


func disable_buttons():
	for button_path in buttons:
		get_node(button_path).disabled = true
