extends Control

@onready var world = $"SubViewportContainer/SubViewport/World Map"

var structures = {
	0:5,
	1:4,
	2:6
}

func _input(event):
	if event.is_action_pressed("do_action"):
		print(world.can_set_selected())
		var sel = $SelectorMenu.get_selected()
		if sel != null:
			world.set_selected(structures[sel])
		
