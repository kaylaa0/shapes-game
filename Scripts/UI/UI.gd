extends Control
class_name UI

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_node("Pause").is_visible():
		get_node("Pause").hide()
	pass # Replace with function body.

func pause_menu_toggle():
	if get_node("Pause").is_visible():
		get_node("HUD/HBoxContainer/VBoxContainer/Control6/CanvasLayer/SummonButton/SummonMenu/AnimatedNinePatch").continue_input()
		get_node("Pause").hide()
		get_tree().paused = false
	else:
		get_node("HUD/HBoxContainer/VBoxContainer/Control6/CanvasLayer/SummonButton/SummonMenu/AnimatedNinePatch").ignore_input()
		get_tree().paused = true
		self.show()
		get_node("Pause").show()
		
func set_minimap_camera(camera):
	self.get_node("HUD/HBoxContainer/VBoxContainer3/Control3/Minimap/B3/SubViewportContainer/SubViewport").add_child(camera)
	
func set_minimap_world(world:World2D):
	self.get_node("HUD/HBoxContainer/VBoxContainer3/Control3/Minimap/B3/SubViewportContainer/SubViewport").set_world_2d(world)
	self.get_node("HUD/HBoxContainer/VBoxContainer3/Control3/Minimap/B3/SubViewportContainer/SubViewport").update_worlds()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
