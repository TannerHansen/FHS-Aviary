extends BaseMenu
# Get the bird info for the country, place it into grid
# Not in charge of what info it gets


func _ready():
	EventBus.connect("send_bird_info", self, "_on_receive_bird_info")


func _on_receive_bird_info(icons: Dictionary, scenes: Dictionary) -> void:
	print(icons)
	print(scenes)
	for bird in icons.keys():
		var button := TextureButton.new()
		button.expand = true
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		button.texture_normal = icons[bird]
		$SafeMargin/GridContainer.add_child(button)
		button.connect("pressed", EventBus, "emit_transition", [bird])
	


func _on_BackButton_pressed():
	disable_buttons()
	EventBus.emit_transition("back")
