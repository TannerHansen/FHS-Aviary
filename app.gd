extends Control
# Keeps track of which menu path we're in

signal adding_next_menu()
func emit_adding_next_menu():
	emit_signal("adding_next_menu")

export var menu := "main"
export var menus := {
	"main": preload("res://main_menu/main_menu.tscn"),
	"world_map": preload("res://world_map/world_map_menu.tscn"),
	"sponsors": preload("res://sponsors/sponsor_menu.tscn"),
	"contributors": preload("res://contributors/contributor_menu.tscn"),
}
var menu_path := []

# Contains scenes under res://birds
# ignores any scenes with "template" in the name
# 	"continent": {
# 		"folder_name": load("res://birds/continent/folder_name/bird_name.tscn"),
# 		. . .
# 	}, {. . .}
var bird_menus := {}


func _init() -> void:
	populate_bird_menus_dict()


func _ready() -> void:
	EventBus.connect("transition", self, "_on_transition")
	# This is to signal the menu (if any) under $Menu on startup
	# otherwise, buttons might be disabled permanently
	EventBus.emit_transitioned()
	
	menu_path.push_back(menus[menu])


func transition(to: String) -> void:
	assert(to in menus or to == "back", "The scene you requested to transition to does not exist!")
	$Transition.play("transition")
	
	yield(self, "adding_next_menu")
	$Menu.get_child(0).queue_free()
	if to == "back":
		menu_path.pop_back()
		var new_menu: Control = menu_path.back().instance()
		$Menu.add_child(new_menu)
	else:
		var new_menu: Control = menus[to].instance()
		$Menu.add_child(new_menu)
		menu_path.push_back(menus[to])
	
	print(menu_path)
	
	yield($Transition, "animation_finished")
	EventBus.emit_transitioned()


func _on_transition(to: String) -> void:
	transition(to)


func _on_MainMenu_button_pressed() -> void:
	pass


func _on_SponsorMenu_button_pressed() -> void:
	pass


# Scans res://birds and adds any valid birds to `bird_menus`
func populate_bird_menus_dict():
	for continent in [
			"africa", "antarctica", "asia", "australia",
			"europe", "north_america", "south_america"
			]:
		var continent_directory := Directory.new()
		if not continent_directory.dir_exists("res://birds/" + continent):
			continue
		continent_directory.open("res://birds/" + continent)
		continent_directory.list_dir_begin(true)
		bird_menus[continent] = {}
		
		# Scan res://birds/continent/* for valid bird folders
		# If there is one, add it to the dictionary
		while true:
			var folder := continent_directory.get_next()
			if folder == "": break
			if not continent_directory.current_is_dir() \
					or "template" in folder:
				continue
			
			var bird_directory := Directory.new()
			bird_directory.open("res://birds/" + continent + "/" + folder)
			bird_directory.list_dir_begin(true)
			
			# Scan res://birds/continent/bird_directory/* for any scene file
			var scene: String
			while true:
				var file := bird_directory.get_next()
				if file == "": break
				if file.ends_with(".tscn") or file.ends_with(".scn"):
					scene = file
					break
			bird_directory.list_dir_end()
			if not scene:
				continue
			
			# Finally add it to the dictionary
			bird_menus[continent][folder] = load(
				"res://birds/" + continent + "/" + folder + "/" + scene
			)
		
		continent_directory.list_dir_end()
#	OS.alert("Bird menus: " + str(bird_menus.values()))
