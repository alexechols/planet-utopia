extends Control

var selected
var highlighted

func _ready() -> void:
	$tiles.set_cell(Vector2i(0,0), 1, Vector2i(0,0))
	$tiles.set_cell(Vector2i(0,1), 1, Vector2i(0,1))
	$tiles.set_cell(Vector2i(0,2), 1, Vector2i(0,2))
	
func _input(event):
	if event.is_action_pressed("left_click"):
		var mouse_pos = get_viewport().get_mouse_position()
		var mouse_tile_pos = $tiles.local_to_map(mouse_pos)
		if mouse_tile_pos.x == 0 and mouse_tile_pos.y < 3 and mouse_tile_pos.x <= 0:
			select(mouse_tile_pos)
		
func select(tile : Vector2):
	var tile_i = Vector2i(tile)
	if selected != null:
		$ui.set_cell(selected, -1)
	
	if tile_i != selected:
		$ui.set_cell(tile_i, 1, Vector2(0,4))
		highlighted = null
		selected = tile_i
	else:
		selected = null

func highlight(tile : Vector2):
	var tile_i = Vector2i(tile)
	
	if tile_i != selected:
		if highlighted != null:
			$ui.set_cell(highlighted, -1)
		$ui.set_cell(tile_i, 1, Vector2(0,3))
		highlighted = tile_i
	else:
		highlighted = null
		
func _process(_delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_bounds = get_viewport_rect().size

	
	if mouse_pos.x >= 0 and mouse_pos.x <= screen_bounds.x and mouse_pos.y >= 0 and mouse_pos.y <= screen_bounds.y:
		var mouse_tile_pos = $tiles.local_to_map(mouse_pos)
		if mouse_tile_pos.x == 0 and mouse_tile_pos.y < 3 and mouse_tile_pos.x <= 0:
		
			highlight(mouse_tile_pos)

func get_selected():
	if selected != null:
		return selected.y
	return null
