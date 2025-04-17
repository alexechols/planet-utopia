extends Control

@onready var world = load("res://game_window.tscn")
var world_child

func _on_texture_button_pressed() -> void:
	$IntroCutscene.start()
	$IntroCutscene.position = get_viewport_rect().size/2
	$IntroCutscene.show()
	remove_child($Background)
	remove_child($TextureButton)
	



func _on_intro_cutscene_completed() -> void:
	world_child = world.instantiate()
	add_child(world_child)
	$IntroCutscene.fade_out()
	


func _on_intro_cutscene_faded() -> void:
	remove_child($IntroCutscene)
