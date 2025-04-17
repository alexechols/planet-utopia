extends Label

@export var time_per_character : float
@export var typed_text : String

var i = 0

func start():
	i = 0
	text = ""
	$Timer.start(time_per_character)
		
func font_size(size_i):
	add_theme_font_size_override("font_size", size_i)
	label_settings.font_size = size_i
	
func _on_timer_timeout() -> void:
	if i < len(typed_text):
		text = typed_text.left(i+1)
		i += 1
		$Timer.start(time_per_character)
		
func is_done():
	return i >= len(typed_text)
	
	
