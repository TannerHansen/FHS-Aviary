extends BaseMenu


func _on_BackButton_pressed() -> void:
	disable_buttons()
	EventBus.emit_transition("back")


func _on_button_pressed():
	disable_buttons()


func _on_AfricaButton_pressed():
	EventBus.emit_transition("africa")


func _on_AustraliaButton_pressed():
	EventBus.emit_transition("australia")


func _on_SouthAmericaButton_pressed():
	EventBus.emit_transition("south_america")
