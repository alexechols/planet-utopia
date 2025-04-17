extends Node2D

var step = 0
var started = false
signal completed
signal faded
# 0 -> All black
# 1 -> Fade in
# 2 -> Planet and star background + Text typing
# 3 -> Fade out


func _ready() -> void:
	var size = get_viewport_rect().size
	
	$ScreenCover.position = -size/2
	$ScreenCover.size = size
	
	$Planet.position = Vector2.ZERO
	$Planet.scale = Vector2.ONE * 3
	
	$SpaceBackground.position = -size/2
	$SpaceBackground.scale = Vector2.ONE * 3
	
	$TypedText.set_process(false)
	
func start():
	started = true
	
func _process(_delta):
	if not started:
		return
		
	if step == 0:
		$Timer.start(3)
		$Planet.play()
		step = 1
	
	elif step == 1:
		$ScreenCover.color = Color(0, 0, 0, $Timer.time_left / $Timer.wait_time)
	
	elif step == 3:
		$TypedText.typed_text = ""
		$TypedText.start()
		$ScreenCover.color = Color(0, 0, 0, ($Timer.wait_time - $Timer.time_left) / $Timer.wait_time)
	
	elif step == -1:
		$ScreenCover.color = Color(0, 0, 0, $Timer.time_left / $Timer.wait_time)
		
func _on_timer_timeout() -> void:
	if step == 1:
		step = 2
		$TypedText.set_process(true)
		$TypedText.time_per_character = 0.1
		$TypedText.font_size(20)
		$TypedText.horizontal_alignment=1
		$TypedText.vertical_alignment=1
		$TypedText.size=Vector2(1000,100)
		$TypedText.position = -$TypedText.size / 2 + Vector2(0,(get_viewport().size.y/2 + 150)/2)
		$TypedText.typed_text = "The Earth... Endless possibilities.\nWe discovered the island by accident, but the abundance of resources is just what we needed. \nThe perfect place to build our ideal society..."
		$TypedText.start()
		
	elif step == 3:
		step = 4
		completed.emit()
		
	elif step == -1:
		faded.emit()
		
		
func _input(event):
	if event.is_action_pressed("left_click"):
		if step == 2 and $TypedText.is_done():
			step = 3

func fade_out():
	$ScreenCover.color = Color(0,0,0,1)
	remove_child($Planet)
	remove_child($SpaceBackground)
	remove_child($TypedText)
	
	$Timer.start(3)
	step = -1
