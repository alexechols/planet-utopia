extends TileMapLayer
@export var cam_mov = 10;

const lookup = {
	0 : Vector3i(0,33,7),
	1 : Vector3i(2,3,0),
	2 : Vector3i(2,2,0),
	3 : Vector3i(2,1,0),
	4 : Vector3i(2,0,0),
	5 : Vector3i(1,2,0),
	6 : Vector3i(0,3,15),
	7 : Vector3i(3,4,0)
}

func load_image(image_path):
	var image = Image.load_from_file(image_path)
	
	var width = image.get_width()
	var height = image.get_height()
	
	for i in range(width):
		for j in range(height):
			var px = int(image.get_pixel(i, j).r * 256)
			
			if px in lookup:
				set_cell(Vector2i(i,j),lookup[px].x, Vector2i(lookup[px].y, lookup[px].z))
	
	
func _ready():
	load_image("res://assets/example_world.png")
	
func _input(event):
	if event.is_action("cam_down"):
		$Camera2D.position += Vector2.DOWN * cam_mov
	if event.is_action("cam_up"):
		$Camera2D.position += Vector2.UP * cam_mov
	if event.is_action("cam_right"):
		$Camera2D.position += Vector2.RIGHT * cam_mov
	if event.is_action("cam_left"):
		$Camera2D.position += Vector2.LEFT * cam_mov
	if event.is_action("cam_zoom_in"):
		$Camera2D.zoom *= 0.9
	if event.is_action("cam_zoom_out"):
		$Camera2D.zoom *= 1.1
		
	
