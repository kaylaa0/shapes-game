extends RigidBody2D
class_name MyShape
# Main attributes
var GRAVITY = MapManager.GRAVITY
var FLOOR = Vector2(0, -1)

# Gameplay variables
var ownerSpawner:Spawner = null : get = get_owner_spawner, set = set_owner_spawner


# Specialities
@export var canMove = false
@export var canStick = false
@export var canSticked = false

# Selection variables
var isFocused = false
var isActive = true # Determines if shape is an UI element or active in scene.
var onme = false # Mouse on shape.

# Interacting
var facingDirection:int = -1 # Which way the shape is moving, -1 left 1 right
var interactRightArea:Area2D
var interactLeftArea:Area2D
var nearbyInteractibles:Dictionary = {}


# Sticking variables
var nearbyStickables:Dictionary = {} 
var isBeingCaried:bool
var otherKinematic

# Ray Casts
var topCastsNode
var rightCastsNode
var leftCastsNode
var topRightCast
var topLeftCast
var upCast
var rightUpCast
var leftUpCast
var rightCast
var leftCast

# Movement variables
var canMovementStart = true
var movementStartTimer = Timer.new()
var inertiaMultiplier = 10 # Every shape must customize this. A value which can just barely move shape is advised.
var initInertia = 0
var customInertia = 0
var customMass = get_mass()
var initMass = get_mass()


# Gravity variables
var gravityTimer = Timer.new()
var gravityOn = false
var groundCast


var pinJointOS:PinJoint2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if has_node("InteractRadius"):
		interactRightArea = get_node("InteractRadius/InteractRadiusRight")
		interactLeftArea = get_node("InteractRadius/InteractRadiusLeft")
# warning-ignore:return_value_discarded
		interactRightArea.connect("body_entered",Callable(self,"_on_interact_right_enter"))
# warning-ignore:return_value_discarded
		interactRightArea.connect("body_exited",Callable(self,"_on_interact_right_exit"))
# warning-ignore:return_value_discarded
		interactLeftArea.connect("body_entered",Callable(self,"_on_interact_left_enter"))
# warning-ignore:return_value_discarded
		interactLeftArea.connect("body_exited",Callable(self,"_on_interact_left_exit"))
	
# warning-ignore:return_value_discarded
	self.connect("input_event",Callable(self,"_on_input_event"))
	
	if has_node("GroundCast"):
		groundCast = get_node("GroundCast")
	else:
		print_debug("Every defined shape must have GroundCast. GroundCast not found in: ",self)
	if has_node("RightCast"):
		rightCast = get_node("RightCast")
	else:
		print_debug("Every defined shape must have RightCast. RightCast not found in: ",self)
	if has_node("LeftCast"):
		leftCast = get_node("LeftCast")
	else:
		print_debug("Every defined shape must have LeftCast. LeftCast not found in: ",self)
	
	movementStartTimer.set_one_shot(true)
	movementStartTimer.set_wait_time(10)
	movementStartTimer.connect("timeout",Callable(self,"movement_start_timeout"))
	
	add_child(movementStartTimer)
	
	gravityTimer.set_one_shot(true)
	gravityTimer.set_wait_time(0.1)
	gravityTimer.connect("timeout",Callable(self,"gravity_start_timeout"))
	
	add_child(gravityTimer)
	
	nearbyStickables[1] = []
	nearbyStickables[-1] = []
	nearbyInteractibles[1] = []
	nearbyInteractibles[-1] = []
	

func interact_main():
	if !nearbyInteractibles[facingDirection].is_empty():
		pass
	elif !nearbyStickables[facingDirection].is_empty():
		pass

func movement_start_timeout():
	canMovementStart = true

func gravity_start_timeout():
	gravityOn = true

func _on_interact_right_enter(other_body):
	if isActive:
		if other_body.is_in_group("shape"):
			if other_body.isActive:
				nearbyStickables[1].append(other_body)
		elif other_body.is_in_group("interactable"):
			nearbyInteractibles[1].append(other_body)

func _on_interact_right_exit(other_body):
	if nearbyStickables[1].has(other_body):
		nearbyStickables[1].erase(other_body)
	elif nearbyInteractibles[1].has(other_body):
		nearbyInteractibles[1].erase(other_body)

func _on_interact_left_enter(other_body):
	if isActive:
		if other_body.is_in_group("shape"):
			if other_body.isActive:
				nearbyStickables[-1].append(other_body)
		elif other_body.is_in_group("interactable"):
			nearbyInteractibles[-1].append(other_body)

func _on_interact_left_exit(other_body):
	if nearbyStickables[-1].has(other_body):
		nearbyStickables[-1].erase(other_body)
	elif nearbyInteractibles[-1].has(other_body):
		nearbyInteractibles[-1].erase(other_body)

func recieve_pickup_signals(signalName:String, object, positionData):
	if signalName == "getting_picked_up":
		# eski func rigid boy modu idi set_mode(3)
		set_global_position(Vector2(positionData.x, positionData.y - 65))
		set_gravity_scale(0.3)
		pinJointOS = PinJoint2D.new()
		pinJointOS.set_global_position(get_global_position())
		pinJointOS.set_script(GameManager.pinJointScript)
		pinJointOS.set_node_a("../"+get_name())
		pinJointOS.set_node_b("../"+object.get_name())
		pinJointOS.set_bias(0)
		pinJointOS.set_softness(0)
		pinJointOS.set_name("pinJointOS"+get_name())
		get_parent().call_deferred("add_child", pinJointOS)
		topCastsNode = Node.new()
		topCastsNode.set_script(GameManager.topNodeScript)
		topCastsNode.set_name("TopCastsNode")
		add_child(topCastsNode)
		rightCastsNode = Node.new()
		rightCastsNode.set_script(GameManager.rightNodeScript)
		rightCastsNode.set_name("RightCastsNode")
		add_child(rightCastsNode)
		leftCastsNode = Node.new()
		leftCastsNode.set_script(GameManager.leftNodeScript)
		leftCastsNode.set_name("LeftCastsNode")
		add_child(leftCastsNode)
		topRightCast = RayCast2D.new()
		topRightCast.set_script(GameManager.rotationDisableScript)
		topRightCast.set_position(Vector2(0, -25))
		topRightCast.set_target_position(Vector2(30,0))
		topRightCast.set_exclude_parent_body(true)
		topRightCast.set_enabled(true)
		topRightCast.set_collision_mask_value(0, false)
		topRightCast.set_collision_mask_value(15, true)
		topRightCast.set_name("TopRightCast")
		topCastsNode.add_child(topRightCast)
		topLeftCast = RayCast2D.new()
		topLeftCast.set_script(GameManager.rotationDisableScript)
		topLeftCast.set_position(Vector2(0, -25))
		topLeftCast.set_target_position(Vector2(-30,0))
		topLeftCast.set_exclude_parent_body(true)
		topLeftCast.set_enabled(true)
		topLeftCast.set_collision_mask_value(0, false)
		topLeftCast.set_collision_mask_value(15, true)
		topLeftCast.set_name("TopLeftCast")
		topCastsNode.add_child(topLeftCast)
		rightUpCast = RayCast2D.new()
		rightUpCast.set_script(GameManager.rotationDisableScript)
		rightUpCast.set_position(Vector2(25, 0))
		rightUpCast.set_target_position(Vector2(0, -31))
		rightUpCast.set_exclude_parent_body(true)
		rightUpCast.set_enabled(true)
		rightUpCast.set_collision_mask_value(0, false)
		rightUpCast.set_collision_mask_value(15, true)
		rightUpCast.set_name("RightUpCast")
		rightCastsNode.add_child(rightUpCast)
		leftUpCast = RayCast2D.new()
		leftUpCast.set_script(GameManager.rotationDisableScript)
		leftUpCast.set_position(Vector2(-25, 0))
		leftUpCast.set_target_position(Vector2(0, -31))
		leftUpCast.set_exclude_parent_body(true)
		leftUpCast.set_enabled(true)
		leftUpCast.set_collision_mask_value(0, false)
		leftUpCast.set_collision_mask_value(15, true)
		leftUpCast.set_name("LeftUpCast")
		leftCastsNode.add_child(leftUpCast)
		upCast = RayCast2D.new()
		upCast.set_script(GameManager.rotationDisableScript)
		upCast.set_position(Vector2(0, 0))
		upCast.set_target_position(Vector2(0,-31))
		upCast.set_exclude_parent_body(true)
		upCast.set_enabled(true)
		upCast.set_collision_mask_value(0, false)
		upCast.set_collision_mask_value(15, true)
		upCast.set_name("UpCast")
		add_child(upCast)
		object.set_attached_body(self)
		set_rotation(0)
		# eski func rigid boy modu idi set_mode(2)
	elif signalName == "getting_dropped":
		# eski func rigid boy modu idi set_mode(3)
		set_global_position(Vector2(object.get_global_position().x + (object.facingDirection*65), object.get_global_position().y - 55))
		set_gravity_scale(1)
		pinJointOS.queue_free()
		pinJointOS = null
		topRightCast.queue_free()
		topRightCast = null
		topLeftCast.queue_free()
		topLeftCast = null
		topCastsNode.queue_free()
		topCastsNode = null
		upCast.queue_free()
		upCast = null
		# eski func rigid boy modu idi set_mode(0)
		object.disconnect("pickedUpShapeInteraction",Callable(self,"recieve_pickup_signals"))
		return

func recieve_input_signals(signalName:String, object):
	#print(signalName)
	if isActive:
		if signalName == "remove_all":
			object.disconnect("focusedShapeInteraction",Callable(self,"recieve_input_signals"))
			return
		if isFocused:
			if canMove:
				if signalName == "move_up_just" and canMovementStart:
					apply_central_impulse(Vector2(0,-MapManager.GRAVITY*get_gravity_scale()*customMass/6))
					canMovementStart = false
					movementStartTimer.start()
				elif signalName == "move_right_just":
					apply_torque(customInertia *inertiaMultiplier)
				elif signalName == "move_right_just_released":
					apply_torque(0)
				elif signalName == "move_left_just":
					apply_torque(-customInertia *inertiaMultiplier)
				elif signalName == "move_left_just_released":
					apply_torque(0)
			if signalName == "interact":
				interact_main()
			elif signalName == "special":
				specialAbility()
				# print(scale)


func get_input():
	# Input is recieved with signals from owner.
	pass

# warning-ignore:unused_argument
func _input(event):
	# Input is recieved with signals from owner.
	pass

# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_input_event(viewport, event, shape_idx):
	pass
	
func specialAbility():
	pass
	
func _focus_signal_receive(state):
	if isActive:
		isFocused = state
		# print(state)
		print("Focused on object: ", self.get_instance_id ( ))
	
	
func to_simpleton():
	for child in self.get_children():
		if !(child.get_name() == "Polygon2D"):
			child.queue_free()
	if has_node("InteractRadius"):
		get_node("InteractRadius/InteractRadiusRight/CollisionShape2D").set_disabled(true)
		get_node("InteractRadius/InteractRadiusLeft/CollisionShape2D").set_disabled(true)
	if has_node("GroundCast"):
		get_node("GroundCast").set_enabled(false)
	if has_node("RightCast"):
		get_node("RightCast").set_enabled(false)
	if has_node("LeftCast"):
		get_node("LeftCast").set_enabled(false)
	self.set_process(false)
	self.set_process_input(false)
	self.set_process_internal(false)
	self.set_process_unhandled_input(false)
	self.set_process_unhandled_key_input(false)
	self.set_physics_process(false)
	self.set_physics_process_internal(false)
	self.isActive = false

# warning-ignore:unused_argument
func _integrate_forces(state):
	if isActive:
		if gravityOn and not isBeingCaried:
			if get_gravity_scale() < 1:
				set_gravity_scale(get_gravity_scale() + 0.2)
			elif get_gravity_scale() > 1:
				set_gravity_scale(1)
		
		if isBeingCaried:
			set_gravity_scale(0)
		
		if get_linear_velocity().x < 0:
			facingDirection = -1
		elif get_linear_velocity().x > 0:
			facingDirection = 1

# warning-ignore:unused_argument
func _physics_process(delta):
	if isActive:
		if initInertia == 0:
			if get_inertia() != 0:
				initInertia = get_inertia()
				customInertia = initInertia

func set_owner_spawner(ownerS:Spawner)->void:
	if(ownerSpawner == null):
		ownerSpawner = ownerS
	else:
		print_debug("Attempt to set owner of already owned object: "+self.to_string()+" from "+get_owner_spawner().to_string()+" to "+ownerS.to_string())

func get_owner_spawner()->Spawner:
	return ownerSpawner

#func get_class()->String: return "MyShape"

#func is_class(name:String)->bool:
#	return super.is_class(name) or (get_class() == name)

#func _process(delta):
#	pass
