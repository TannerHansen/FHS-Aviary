extends BaseMenu


func _on_button_pressed() -> void:
	disable_buttons()


func _on_BirdButton_pressed() -> void:
	EventBus.emit_transition("world_map")


func _on_SponsorButton_pressed() -> void:
	EventBus.emit_transition("sponsors")


func _on_ContributorButton_pressed() -> void:
	EventBus.emit_transition("contributors")
