extends MarginContainer
class_name Minimap

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@onready var viewPort = self.get_node("MinimapMargin/SubViewportContainer/SubViewport") : get = get_viewPort
var minimapCamera:AdvancedCamera2D : get = get_camera_3d
var minimapObjects = {}
var focusOnMe = false


# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.set_minimap(self)
	minimapCamera = AdvancedCamera2D.new()
	minimapCamera.set_zoom(Vector2(15,15))
	viewPort.add_child(minimapCamera)
	minimapCamera.make_current()
	
	pass # Replace with function body.



func receive_object(node):
	if node.is_in_group("minimapable_object"):
		minimapObjects[node] = generate_minimap_graphic(node)
		viewPort.add_child(minimapObjects[node])
	else:
		print_debug("Minimap received non-minimap object.")

func generate_minimap_graphic(node):
	if node.is_in_group("minimapable_object"):
		if node.get("minimapGraphic"):
			return node.get("minimapGraphic")
		else:
			var graphic = node.duplicate()
			if graphic.has_method("_physics_process"):
				graphic.set_physics_process(false)
			if graphic.has_method("_process"):
				graphic.set_process(false)
			for N in graphic.get_children():
				if N is CollisionShape2D:
					N.set_process(false)
			if graphic.has_method("set_mode"):
				graphic.set_mode(3)
			if graphic.has_method("to_simpleton"):
				graphic.to_simpleton()
			return graphic
	else:
		print_debug("Can not generate minimap graphic from non minimap object.")

func update_all_positions():
	for key in minimapObjects.keys():
		if minimapObjects[key] == null:
			print_debug("A minimap object has no graphic object.")
		else:
			if minimapObjects[key].has_method("set_global_position"):
				minimapObjects[key].set_global_position(key.get_global_position())
			else:
				print_debug("A minimap graphic object has no set_position method.")
			if minimapObjects[key].has_method("set_global_rotation"):
				minimapObjects[key].set_global_rotation(key.get_global_rotation())
			else:
				print_debug("A minimap graphic object has no set_rotation method.")
	pass

func _gui_input(event):
	if event is InputEventMouseButton and focusOnMe:
		if event.is_pressed():
			# zoom in
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				get_camera_3d().set_zoom(Vector2(clamp(get_camera_3d().get_zoom().x-0.5, 1, 20), clamp(get_camera_3d().get_zoom().y-0.5, 1, 20)))
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				get_camera_3d().set_zoom(Vector2(clamp(get_camera_3d().get_zoom().x+0.5, 1, 20), clamp(get_camera_3d().get_zoom().y+0.5, 1, 20)))


# warning-ignore:unused_argument
func _physics_process(delta):
	update_all_positions()
	pass
	
func get_camera_3d():
	return minimapCamera
	
func get_viewPort():
	return viewPort
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_B1_mouse_entered():
	focusOnMe = true


func _on_B1_mouse_exited():
	focusOnMe = false

