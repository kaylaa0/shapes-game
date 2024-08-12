extends Spawner
class_name Player
# Player body

var minimapCamera:AdvancedCamera2D

@export var playerID := 1 :
	set(id):
		playerID = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)

var userData
var gold:int = 0
# Player synchronized input.
@onready var input = $PlayerInput

# warning-ignore:unused_signal
signal focusSignal
signal sbUpdateNeeded # Summon button selected shape update signal. Will be called on numpad input. Will be connected at AnimatedNinePatch.
# warning-ignore:unused_signal
signal cmbUpdateNeeded # CraftMenu main button update signale. Not-used.
# warning-ignore:unused_signal
signal cmUpdateNeeded # Signal for updating whole CraftMenu. Not-used
signal cmaUpdateNeeded(craftable, state) # Signal for updating a CraftMenu item. Used for syncing craftables craftability.
var space_state

signal focusedShapeInteraction(signalMessage, object)

func _init():
	var shapesNode = Node.new()
	shapesNode.set_name("Shapes")
	add_child(shapesNode)
	
	if MultiplayerHandler.is_multiplayer():
		var shapesSpawner = MultiplayerSpawner.new()
		shapesSpawner.set_name("ShapesSpawner")
		shapesSpawner.set_spawn_limit(0)
		shapesSpawner.set_spawn_path("../Shapes")
		shapesSpawner.add_spawnable_scene("res://Scenes/Objects/Shapes/Circle.tscn")
		shapesSpawner.add_spawnable_scene("res://Scenes/Objects/Shapes/Square.tscn")
		shapesSpawner.add_spawnable_scene("res://Scenes/Objects/Shapes/Triangle.tscn")
		# shapesSpawner.set_spawn_function(shapesSpawner)
		add_child(shapesSpawner)

func _ready():
	print(playerID, multiplayer.get_unique_id())
	if playerID != multiplayer.get_unique_id():
		self.set_process_input(false)
		self.set_process_unhandled_input(false)
		self.set_process_unhandled_key_input(false)
	super()

func check_craftable_craftabilities()->void: # Overridden from parent Spawner. Change is emits signal for CraftMenu on craftability change.
	for craftable in get_next_craftables().values():
		var dummyState = craftable.get_can_craft()
		if check_craftability(craftable):
			if dummyState == false:
				craftable.can_craft()
				emit_signal("cmaUpdateNeeded", craftable, true)
		elif dummyState == true:
			craftable.cant_craft()
			emit_signal("cmaUpdateNeeded", craftable, false)
		
			

func focus_next_object()->void:
	var temp = get_next_object()
	if temp != null:
		focus_on_object(temp)

func focus_previous_object()->void:
	var temp = get_previous_object()
	if temp != null:
		focus_on_object(temp)

func get_focused_object():
	return focusedObject

func focus_on_object(object):
	super.focus_on_object(object)
	$playerCamera.set_followed_object(object)
	
	if GameManager.get_minimap():
		GameManager.get_minimap().get_camera_3d().set_followed_object(object)
	emit_signal("focusedShapeInteraction", "remove_all", self)
	# await get_tree().idle_frame
# warning-ignore:return_value_discarded
	connect("focusedShapeInteraction",Callable(object,"recieve_input_signals"))
	emit_signal("focusedShapeInteraction", "focused_ready", null)


func focus_last_object()->void:
	if previousObject != null:
		focus_on_object(previousObject)

func get_input():
	if Input.is_action_just_pressed("next_object"):
		focus_next_object()
	if Input.is_action_just_pressed("last_object"):
		focus_last_object()
	if Input.is_action_just_pressed("previous_object"):
		focus_previous_object()
	if Input.is_action_just_pressed("fast_craft"):
		fast_craft()
	if Input.is_action_just_pressed("auto_craft"):
		auto_craft()
	if Input.is_action_just_pressed("move_up"):
		emit_signal("focusedShapeInteraction", "move_up_just", null)
	if Input.is_action_just_pressed("move_right"):
		emit_signal("focusedShapeInteraction", "move_right_just", null)
	if Input.is_action_pressed("move_right"):
		emit_signal("focusedShapeInteraction", "move_right", null)
	if Input.is_action_just_released("move_right"):
		emit_signal("focusedShapeInteraction", "move_right_just_released", null)
	if Input.is_action_just_pressed("move_left"):
		emit_signal("focusedShapeInteraction", "move_left_just", null)
	if Input.is_action_pressed("move_left"):
		emit_signal("focusedShapeInteraction", "move_left", null)
	if Input.is_action_just_released("move_left"):
		emit_signal("focusedShapeInteraction", "move_left_just_released", null)
	if Input.is_action_just_pressed("move_down"):
		emit_signal("focusedShapeInteraction", "move_down_just", null)
	if Input.is_action_just_released("move_down"):
		emit_signal("focusedShapeInteraction", "move_down_just_released", null)
	if Input.is_action_pressed("move_down"):
		emit_signal("focusedShapeInteraction", "move_down", null)
	if Input.is_action_pressed("special"):
		emit_signal("focusedShapeInteraction", "special", null)
	if Input.is_action_pressed("interact"):
		emit_signal("focusedShapeInteraction", "interact", null)
	if Input.is_action_just_pressed("interact"):
		emit_signal("focusedShapeInteraction", "pickup", null)
	

func _input(event):
	if GameManager.mapLoaded:
		if Input.is_action_just_pressed("esc"):
			GameManager.globalUI.pause_menu_toggle()
			
		if not get_tree().paused:
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT:
					var parameters = PhysicsPointQueryParameters2D.new()
					parameters.set_position(get_global_mouse_position())
					parameters.set_collide_with_areas(true)
					var results = space_state.intersect_point(parameters, 32)
					#print(results)
					for result in results:
						if result["collider"].is_in_group("shape"):
							focus_on_object(result["collider"])
			
			if Input.is_action_just_pressed("select summon numpad"):
				# print(int(char(event.unicode)))
				var tempName:String = get_parent().get_shape_name_from_numpad(selectedSpawn, int(char(event.unicode)))
				if tempName != "Null":
					set_selected_spawn(tempName)
					emit_signal("sbUpdateNeeded")
			if Input.is_action_just_pressed("Space"):
				spawn_object(selectedSpawn)
			

# warning-ignore:unused_argument
func _physics_process(delta):
	if focusedObject != null:
		get_input()
	space_state = get_world_2d().direct_space_state

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
