extends Node

# See app.gd for valid menus to switch to
signal transition(to)
func emit_transition(to: String) -> void:
	emit_signal("transition", to)

signal transitioned()
func emit_transitioned() -> void:
	emit_signal("transitioned")


signal send_bird_info(icons, scenes)
func emit_send_bird_info(icons: Dictionary, scenes: Dictionary) -> void:
	emit_signal("send_bird_info", icons, scenes)
