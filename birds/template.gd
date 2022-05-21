extends BaseMenu



func _on_BackButton_pressed():
	disable_buttons()
	EventBus.emit_transition("back")
