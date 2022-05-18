extends BaseMenu


func _on_BackButton_pressed() -> void:
	disable_buttons()
	EventBus.emit_transition("back")
