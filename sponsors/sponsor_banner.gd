extends Container

export(float, 0, 200) var spacing := 30.0
export(float, 1, 500) var scroll_speed := 35.0
export var sponsor_path := "res://sponsors/images"

var sponsor_textures := []
var sponsor_index := 0

func _init() -> void:
	# Load sponsor textures
	var sponsor_directory := Directory.new()
	if sponsor_directory.open(self.sponsor_path) == OK:
		sponsor_directory.list_dir_begin(true)
		while true:
			var file_name = sponsor_directory.get_next()
			# File validation checks
			if file_name == "":
				break
			if sponsor_directory.current_is_dir() \
				or file_name.ends_with(".import"):
				continue
			var image = load(self.sponsor_path + "/" + file_name)
			if not image is Texture:
				continue
			
			self.sponsor_textures.append(image)


func _ready() -> void:
	# Controls dont update their properties until the first draw call i think
	# this is my hack :skull:
	yield(get_tree(), "idle_frame")
	
	var next_image_x_position := 0.0
	for i in len(self.sponsor_textures):
		# Cause GDScript doesnt have zip() ..
		var texture = self.sponsor_textures[i] as Texture
		
		if next_image_x_position >= self.rect_position.x + self.rect_size.x:
			break
		
		add_sponsor(next_image_x_position)
		next_image_x_position += get_child(get_child_count()-1).rect_size.x + spacing


func _process(delta: float) -> void:
	if get_child(0).rect_position.x <= -get_child(0).rect_size.x - spacing:
		get_child(0).queue_free()
	
	var last_child: TextureRect = get_child(max(0, get_child_count()-1))
	if last_child.rect_position.x <= self.rect_position.x + self.rect_size.x:
		self.add_sponsor(
			last_child.rect_position.x + last_child.rect_size.x + self.spacing
		)
	
	for sponsor in get_children():
		assert(sponsor is TextureRect)
		sponsor.rect_position.x -= scroll_speed * delta


func add_sponsor(x: float) -> void:
	var texture := self.sponsor_textures[self.sponsor_index] as Texture
	var sponsor := TextureRect.new()
	var scale := self.rect_size.y / texture.get_height() as float
	sponsor.expand = true
	sponsor.rect_size = texture.get_size() * scale
	sponsor.rect_position = Vector2(x, 0.0)
	
	sponsor.texture = texture
	sponsor_index = (sponsor_index + 1) % sponsor_textures.size()
	self.add_child(sponsor)
