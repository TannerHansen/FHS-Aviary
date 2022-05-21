extends Control
# Keeps track of which menu path we're in
# Need to refactor this... its atrocious in here

signal adding_next_menu()
func emit_adding_next_menu():
	emit_signal("adding_next_menu")

export var menu := "main"
export var menus := {
	"main": preload("res://main_menu/main_menu.tscn"),
	"world_map": preload("res://world_map/world_map_menu.tscn"),
	"sponsors": preload("res://sponsors/sponsor_menu.tscn"),
	"contributors": preload("res://contributors/contributor_menu.tscn"),
	"africa": preload("res://bird_selection/bird_selection.tscn"),
	"australia": preload("res://bird_selection/bird_selection.tscn"),
	"south_america": preload("res://bird_selection/bird_selection.tscn"),
}
var menu_path := []

# Contains scenes under res://birds
# ignores any scenes with "template" in the name
# 	"continent": {
# 		"folder_name": load("res://birds/continent/folder_name/bird_name.tscn"),
# 		. . .
# 	}, {. . .}
var bird_menus := {}
# maps bird name to associated icon.png Texture
var bird_icons := {}

func _init() -> void:
	populate_bird_menus_and_icons_dicts()


func _ready() -> void:
	EventBus.connect("transition", self, "_on_transition")
	# This is to signal the menu (if any) under $Menu on startup
	# otherwise, buttons might be disabled permanently
	EventBus.emit_transitioned()
	
	menu_path.push_back(menus[menu])
	
	# Rotate to fix the dumb iPad issue with the TV
	if OS.has_feature("standalone"):
		get_tree().set_screen_stretch(
			SceneTree.STRETCH_MODE_VIEWPORT,
			SceneTree.STRETCH_ASPECT_KEEP,
			Vector2(2048, 1536)
		)
		self.rect_size = Vector2(1536, 2048)
		self.rect_rotation = -90
		self.rect_position.y = 1536


func transition(to: String) -> void:
	var going_back := false
	var bird_selection_menu := false
	var menu_resource: PackedScene
	
	if to == "back":
		assert(menu_path.size() >= 2, "Can't go back!")
		menu_resource = menu_path[menu_path.size()-2]
		going_back = true
		for continent in bird_menus.keys():
			for bird in bird_menus[continent].keys():
				if bird_menus[continent][bird] == menu_path.back():
					to = continent
	if to in [
			"africa", "antarctica", "asia", "australia",
			"europe", "north_america", "south_america"
			]:
		if not going_back:
			menu_resource = menus[to]
		bird_selection_menu = true
	if to in menus:
		menu_resource = menus[to]
	for birds_from_continent in bird_menus.values():
		if to in birds_from_continent:
			menu_resource = birds_from_continent[to]
			break
	assert(menu_resource != null, "The scene you requested to transition to does not exist!")
	
	$Transition.play("transition")
	yield(self, "adding_next_menu")
	
	$Menu.get_child(0).queue_free()
	$Menu.add_child(menu_resource.instance())
	if going_back:
		menu_path.pop_back()
	else:
		menu_path.push_back(menu_resource)
	if bird_selection_menu:
		EventBus.emit_send_bird_info(bird_icons[to], bird_menus[to])
	
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
# Scans res://birds and adds any icon.png's in folders to `bird_icons`
func populate_bird_menus_and_icons_dicts():
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
		bird_icons[continent] = {}
		
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
			
			# Scan res://birds/continent/bird_directory/* for any scene or texture file
			var scene: String
			var texture: String
			while true:
				var file := bird_directory.get_next()
				if file == "": break
				if file.begins_with("icon") and file.ends_with(".import"):
					texture = file.trim_suffix(".import")
				if file.ends_with(".tscn") or file.ends_with(".scn"):
					scene = file
				if scene and texture:
					break
			bird_directory.list_dir_end()
			if not scene:
				continue
			
			# Finally add it to the dictionary
			bird_menus[continent][folder] = load(
				"res://birds/" + continent + "/" + folder + "/" + scene
			)
			bird_icons[continent][folder] = load(
				"res://birds/" + continent + "/" + folder + "/" + texture
				if texture else "res://icon.png"
			)
		
		continent_directory.list_dir_end()
	
	OS.alert("Bird menus: " + str(bird_menus.values()))
	OS.alert("Bird menus: " + str(bird_icons.values()))
#	OS.alert("Bird menus: " + str(dir_contents("res://birds/australia/grasskeets")))


func dir_contents(path):
	var output := ""
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				output += "Found directory: " + file_name + "\n"
			else:
				output += "Found file: " + file_name + "\n"
			file_name = dir.get_next()
	else:
		output += "An error occurred when trying to access the path.\n"
	return output
