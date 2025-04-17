extends Node2D

signal loaded

@export var n_ticks : int

var image_size = Vector2i(0,0);

var camera_config = {
	"max_zoom" : 5,
	"move" : 0.05,
	"zoom" : 0.1,
}
var world_bounds : Vector2

# Pixel value to layer (all below)
const heights = {
	0 : "ocean",
	1 : "shore",
	2 : "grass",
	3 : "objects",
}

var structures = {
	4 : [4, Vector2i(6,14), 0], #Well
	5 : [4, Vector2i(10,5), 0], #Windmill
	6 : [4, Vector2i(9,9),0] # House
}



# Layer information for each named layer
# [layer_id, terrain_set_id, terrain_id, default_source_id, default_atlas_coords]
const layers = {
	"ocean" : [0, 0, 3, [Vector3i(0,4,2)]],
	"shore" : [1, 0, 2, [Vector3i(0,1,1)]],
	"grass" : [2, 0, 1, [Vector3i(0,1,4),Vector3i(2,0,1),Vector3i(2,1,1),Vector3i(2,2,1)]],
	"objects" : [3, 0, 0, [Vector3i(1,1,0), Vector3i(1,2,0), Vector3i(1,3,0)]]
}

var min_world_bounds
var max_world_bounds
var world_size

var scroll_width = Vector2.ONE * 100

# Meant for external reference
var image_data
var selected
var highlighted

var decay_tiles = {}
var decayed = {}


func _ready():
	
	var image = load("res://assets/maps/map.tres").get_image()
	load_image(image)

func _input(event):
	# Camera Movement
	var view_size = $Camera2D.get_viewport_rect().size
	var move_step = min(view_size.x, view_size.y) * camera_config["move"] / $Camera2D.zoom.x
	var move = Vector2.ZERO
	var zoom = 0
	
	if event.is_action("cam_down"):
		move.y += move_step
	if event.is_action("cam_up"):
		move.y -= move_step
	if event.is_action("cam_right"):
		move.x += move_step
	if event.is_action("cam_left"):
		move.x -= move_step
	
	if event.is_action("cam_zoom_in"):
		zoom += camera_config["zoom"]
	if event.is_action("cam_zoom_out"):
		zoom -= camera_config["zoom"]
		
	$Camera2D.zoom += camera_zoom(zoom) * Vector2.ONE
	$Camera2D.position += camera_move(move)
	
	if event.is_action_pressed("left_click"):
		var mouse_pos = $Camera2D.get_viewport().get_mouse_position()
		var screen_bounds = $Camera2D.get_viewport_rect().size
		var tile_px_size = Vector2($ocean.tile_set.tile_size) * $Camera2D.zoom
		var screen_tile_size = screen_bounds / tile_px_size
		var mouse_tile_pos = mouse_pos * screen_tile_size / screen_bounds + $Camera2D.position / tile_px_size * $Camera2D.zoom - screen_tile_size/2 + Vector2(1,0.5)

		select(mouse_tile_pos)
	
func camera_move(proposed_move):
	var out = Vector2.ZERO
	var size = $Camera2D.get_viewport_rect().size / $Camera2D.zoom 
	var center = $Camera2D.get_screen_center_position()
	
	var min_corner = center - size / 2
	var max_corner = center + size / 2
	
	if min_corner.x + proposed_move.x < min_world_bounds.x:
		out.x = min_world_bounds.x - min_corner.x
	elif max_corner.x + proposed_move.x > max_world_bounds.x:
		out.x = max_world_bounds.x - max_corner.x
	else:
		out.x = proposed_move.x
		
	if min_corner.y + proposed_move.y < min_world_bounds.y:
		out.y = min_world_bounds.y - min_corner.y
	elif max_corner.y + proposed_move.y > max_world_bounds.y:
		out.y = max_world_bounds.y - max_corner.y
	else:
		out.y = proposed_move.y
	
	return out
	
func camera_zoom(proposed_move):
	var min_zoom = max(
		 $Camera2D.get_viewport_rect().size.x / world_size.x,
		$Camera2D.get_viewport_rect().size.y / world_size.y,
		)
		
	var max_zoom = camera_config["max_zoom"]
		
	if $Camera2D.zoom.x + proposed_move > max_zoom:
		return max_zoom - $Camera2D.zoom.x
	elif $Camera2D.zoom.x + proposed_move < min_zoom:
		return min_zoom - $Camera2D.zoom.x
	else:
		return proposed_move
		
func load_image(image):
	image_size.x = image.get_width()
	image_size.y = image.get_height()
	
	image_data = []
	image_data.resize(image_size.x)
	
	for i in range(image_size.x):
		image_data[i] = []
		image_data[i].resize(image_size.y)
		
	for i in range(image_size.x):
		for j in range(image_size.y):
			var px = int(image.get_pixel(i, j).r * 256)
			var pos = Vector2i(i - image_size.x / 2,j - image_size.y / 2)
			
			image_data[i][j] = px
			
			for l in range(px + 1):
				var layer = heights[l]
				var choice = randi() % len(layers[layer][3])
				
				var atlas = layers[layer][3][choice].x
				var atlas_pos = Vector2i(layers[layer][3][choice].y,layers[layer][3][choice].z)

				get_node(layer).set_cell(pos, atlas, atlas_pos)
				
	var tile_size = $ocean.tile_set.tile_size.x	
	min_world_bounds = Vector2(- image_size.x / 2 * tile_size, - image_size.y / 2 * tile_size)
	max_world_bounds = Vector2(image_size.x / 2 * tile_size, image_size.y / 2 * tile_size)
	world_size = image_size * tile_size
	
	loaded.emit()
	
func _process(_delta):
	var mouse_pos = $Camera2D.get_viewport().get_mouse_position()
	var screen_bounds = $Camera2D.get_viewport_rect().size

	
	if mouse_pos.x >= 0 and mouse_pos.x <= screen_bounds.x and mouse_pos.y >= 0 and mouse_pos.y <= screen_bounds.y:
		if (mouse_pos.x <= scroll_width.x or mouse_pos.x >= screen_bounds.x - scroll_width.x) or (mouse_pos.y <= scroll_width.y or mouse_pos.y >= screen_bounds.y - scroll_width.y):
			var delta : Vector2 = (mouse_pos - screen_bounds/2).normalized()
			
			$Camera2D.position += camera_move(min(screen_bounds.x, screen_bounds.y) * camera_config["move"] * delta / $Camera2D.zoom.x * 0.2)

		#var mouse_screen_pos = mouse_pos #$Camera2D.position / $ui.tile_set.tile_size.x 
		var tile_px_size = Vector2($ocean.tile_set.tile_size) * $Camera2D.zoom
		var screen_tile_size = screen_bounds / tile_px_size
		var mouse_tile_pos = mouse_pos * screen_tile_size / screen_bounds + $Camera2D.position / tile_px_size * $Camera2D.zoom - screen_tile_size/2 + Vector2(1,0.5)
		
		highlight(mouse_tile_pos)
		
	# Generate random ticks
	for i in range(n_ticks):
		var r_x = randi() % image_size.x
		var r_y = randi() % image_size.y
		
		random_tick(Vector2i(r_x, r_y))
	
func highlight(tile : Vector2):
	var tile_i = Vector2i(tile)
	
	if tile_i != selected:
		if highlighted != null:
			$ui.set_cell(highlighted, -1)
		$ui.set_cell(tile_i, 0, Vector2(0,0))
		highlighted = tile_i
	else:
		highlighted = null
	
func select(tile : Vector2):
	var tile_i = Vector2i(tile)
	if selected != null:
		$ui.set_cell(selected, -1)
	
	if tile_i != selected:
		$ui.set_cell(tile_i, 0, Vector2(1,0))
		highlighted = null
		selected = tile_i
	else:
		selected = null
		
func get_selected_info():
	if selected != null:
		return image_data[selected.x][selected.y]
	return null
	
func can_set_selected():
	if selected != null and selected not in decayed:
		var px = image_data[selected.x + image_size.x / 2][selected.y + image_size.y / 2]
	
		if px > 0 and px <= 2:
			return true
			
	return false

func set_selected(val : int):
	if can_set_selected():
		image_data[selected.x + image_size.x / 2][selected.y + image_size.y / 2] = val
		$objects.set_cell(selected, structures[val][0], structures[val][1], structures[val][2])
		decay_around(selected)
	

func decay_around(tile:Vector2i, r : int = 10):
	for i in range(-r, r+1):
		for j in range(-r, r+1):
			if i*i + j*j <= r*r:
				decay_tiles[Vector2i(tile.x + i, tile.y + j)] = null
	
	#print(decay_tiles)
	
func random_tick(tile : Vector2i):
	if tile in decay_tiles:
		if tile not in decayed:
			decay(tile)
			decayed[tile] = null
		decay_tiles.erase(tile)
			
		
func decay(tile : Vector2i):
	var px = image_data[tile.x + image_size.x / 2][tile.y + image_size.y / 2]	
	if px == 0:
		$ocean.set_cell(tile, 5, Vector2i(5,0))
	if px == 1:
		$shore.set_cell(tile,5, Vector2i(4,0))
	if px == 2:
		$grass.set_cell(tile, 7, Vector2i(randi() % 3, randi() % 2))
	if px == 3:
		var sprite = $objects.get_cell_source_id(tile)
		
		if sprite == 1:
			$grass.set_cell(tile, 7, Vector2i(randi() % 3, randi() % 2))
			$objects.set_cell(tile, 8, Vector2i((randi() % 2) * 2, 0))
			
		
