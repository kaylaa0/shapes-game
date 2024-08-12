extends MyShape
class_name MyMotileShape

# Movement variables
var movingRight
var movingLeft
var gotMovement
@export var walkSpeed = 75
var slowerTimer = Timer.new()
var manualSlowTimer = Timer.new()

# Jumping variables
@export var jumpPower = 3500
var jumpTimer = Timer.new()
var jumpAllowed = false
var jumpLooking = true
var jumpCast
var jumpLeftCast
var jumpRightCast

# Speed variables
var velocity:Vector2 = Vector2(0,0)
@export var verticalSpeed = 100
@export var rotationSpeed = 200
@export var maxSpeed = 1500
@export var mirrorSpeed = 300


var currentlyCarrying:bool = false
var stickerShape:RigidBody2D
var pinJointSS:PinJoint2D



signal pickedUpShapeInteraction(signalMessage, object, positionData)

func _ready():
	if has_node("JumpCast"):
		jumpCast = get_node("JumpCast")
	else:
		print_debug("Every defined motile shape must have JumpCast. JumpCast not found in: ",self)
	if has_node("JumpLeftCast"):
		jumpLeftCast = get_node("JumpLeftCast")
	else:
		print_debug("Every defined motile shape must have JumpLeftCast. JumpLeftCast not found in: ",self)
	if has_node("JumpRightCast"):
		jumpRightCast = get_node("JumpRightCast")
	else:
		print_debug("Every defined motile shape must have JumpRightCast. JumpRightCast not found in: ",self)
	
	slowerTimer.set_one_shot(true)
	slowerTimer.set_wait_time(0.5)
	slowerTimer.connect("timeout",Callable(self,"slower_enabled_timeout"))
	
	add_child(slowerTimer)
	
	manualSlowTimer.set_one_shot(true)
	manualSlowTimer.set_wait_time(0.1)
	manualSlowTimer.connect("timeout",Callable(self,"slower_enabled_timeout"))
	
	add_child(manualSlowTimer)
	
	jumpTimer.set_one_shot(true)
	jumpTimer.set_wait_time(0.5)
	jumpTimer.connect("timeout",Callable(self,"jump_disable_timeout"))
	
	add_child(jumpTimer)
	
	super()


func checkWallHit():
	if rightCast:
		if rightCast.is_colliding():
			if rightCast.get_collider().is_in_group("jumpablewall"):
				pass
			elif rightCast.get_collider().is_in_group("wall"):
				if get_constant_torque() > rotationSpeed*2:
					apply_torque(rotationSpeed*2)
				if get_constant_force().x > verticalSpeed:
					apply_force(Vector2(verticalSpeed,get_constant_force().y))
	if leftCast:
		if leftCast.is_colliding():
			if leftCast.get_collider().is_in_group("jumpablewall"):
				pass
			elif leftCast.get_collider().is_in_group("wall"):
				if get_constant_torque() < -rotationSpeed*2:
					apply_torque(-rotationSpeed*2)
				if get_constant_force().x < -verticalSpeed:
					apply_force(Vector2(-verticalSpeed,get_constant_force().y))

func checkAppliedForces():
	if !gotMovement:
		if get_constant_torque() <= 100:
			apply_torque(0)
		elif get_constant_torque() >= -100:
			apply_torque(0)
		else:
			apply_torque(get_constant_torque()/2)
		if get_constant_force().x <= 100:
			apply_force(Vector2(0, get_constant_force().y))
		elif get_constant_force().x >= -100:
			apply_force(Vector2(0, get_constant_force().y))
		else:
			apply_force(Vector2(get_constant_force().x/2, get_constant_force().y))
	if slowerTimer.is_stopped():
		slowerTimer.start()
	if get_constant_torque() > 24000:
		apply_torque(24000)
	elif get_constant_torque() < -24000:
		apply_torque(-24000)
	if get_constant_force().x > 14000:
		apply_force(Vector2(14000,get_constant_force().y))
	elif get_constant_force().x < -14000:
		apply_force(Vector2(-14000,get_constant_force().y))
	if get_linear_velocity().x < 200:
		if get_constant_torque() > 3000:
			apply_torque(3000)
		if get_constant_force().x > 1500:
			apply_force(Vector2(1500, get_constant_force().y))
	if get_linear_velocity().x > -200:
		if get_constant_torque() < -3000:
			apply_torque(-3000)
		if get_constant_force().x < -1500:
			apply_force(Vector2(-1500, get_constant_force().y))

func recieve_input_signals(signalName:String, object):
	#print(signalName)
	if isActive:
		if get_linear_velocity().x < 0:
			facingDirection = -1
		elif get_linear_velocity().x > 0:
			facingDirection = 1
		if signalName == "remove_all":
			object.disconnect("focusedShapeInteraction",Callable(self,"recieve_input_signals"))
			return
		elif signalName == "focused_ready":
			pass
		if isFocused:
			if canMove:
				if signalName == "move_up_just" and jumpAllowed:
					if jumpTimer.is_stopped():
						jumpTimer.start()
						apply_central_impulse(Vector2(0, -jumpPower))
						jumpAllowed = false
						jumpLooking = false
					gotMovement = true
					slowerTimer.start()
				elif signalName == "move_right_just":
					# Mirroring movement from other side
					if velocity[0] < -mirrorSpeed:
						apply_torque(get_constant_torque()/-2)
						apply_force(Vector2(get_constant_force().x/-2, get_constant_force().y))
						set_linear_velocity(Vector2(-get_linear_velocity().x*3/4, get_linear_velocity().y))
					apply_central_impulse(Vector2(verticalSpeed*8,0))
					apply_torque_impulse(rotationSpeed*12)
					apply_torque(rotationSpeed*26)
					apply_central_force(Vector2(verticalSpeed*14,0))
				elif signalName == "move_right":
					if velocity[0] <= maxSpeed:
						apply_central_force(Vector2(verticalSpeed,0))
						apply_torque(rotationSpeed)
					else:
						apply_torque(get_constant_torque()/10)
						apply_force(Vector2(get_constant_force().x/10,get_constant_force().y))
					gotMovement= true
					slowerTimer.start()
				elif signalName == "move_left_just":
					if velocity[0] > mirrorSpeed:
						apply_torque(get_constant_torque()/-2)
						apply_force(Vector2(get_constant_force().x/-2, get_constant_force().y))
						set_linear_velocity(Vector2(-get_linear_velocity().x*3/4, get_linear_velocity().y))
					apply_central_impulse(Vector2(-verticalSpeed*8,0))
					apply_torque_impulse(-rotationSpeed*12)
					apply_torque(-rotationSpeed*26)
					apply_central_force(Vector2(-verticalSpeed*14,0))
				elif signalName == "move_left":
					if velocity[0] >= -maxSpeed:
						apply_central_force(Vector2(-verticalSpeed,0))
						apply_torque(-rotationSpeed)
					else:
						apply_torque(get_constant_torque()/10)
						apply_force(Vector2(get_constant_force().x/10,get_constant_force().y))
					gotMovement = true
					slowerTimer.start()
				elif signalName == "move_down" and manualSlowTimer.is_stopped():
					if get_constant_torque() <= 12000:
						apply_torque(0)
					elif get_constant_torque() >= -12000:
						apply_torque(0)
					else:
						apply_torque(get_constant_torque()/2)
					
					if get_constant_force().x <= 7000:
						apply_force(Vector2(0, get_constant_force().y))
					elif get_constant_force().x >= -7000:
						apply_force(Vector2(0, get_constant_force().y))
					else:
						apply_force(Vector2(get_constant_force().x/2, get_constant_force().y))
					set_angular_velocity(get_angular_velocity()*4/5)
					set_linear_velocity(Vector2(get_linear_velocity().x*2/3, get_linear_velocity().y))
				elif signalName == "move_down_just":
					if manualSlowTimer.is_stopped():
						manualSlowTimer.start()
				elif signalName == "move_down_just_released":
					get_physics_material_override().set_friction(1)
				# print(OS.get_time()," ",get_linear_velocity(), " ", get_constant_torque(), " ", get_constant_force())
			if signalName == "special":
				specialAbility()
			if signalName == "pickup":
				if !currentlyCarrying:
					pickup_closest_object()
				else:
					drop_carried_object()

func drop_carried_object():
	emit_signal("pickedUpShapeInteraction", "getting_dropped", self, null)
	stickerShape.queue_free()
	pinJointSS.queue_free()
	stickerShape = null
	pinJointSS = null
	currentlyCarrying = false

func pickup_object(object:MyShape):
# warning-ignore:return_value_discarded
	connect("pickedUpShapeInteraction",Callable(object,"recieve_pickup_signals"))
	emit_signal("pickedUpShapeInteraction", "getting_picked_up", stickerShape, get_global_position())
	currentlyCarrying = true

func init_sticking_elements():
	stickerShape = RigidBody2D.new()
	var temp = get_node("CollisionShape2D").duplicate()
	stickerShape.add_child(temp)
	temp.set_disabled(true)
	stickerShape.set_script(GameManager.stickyScript)
	stickerShape.set_global_position(get_global_position())
	stickerShape.set_name("StickerShape"+get_name())
	stickerShape.set_carrying_body(self)
	get_parent().call_deferred("add_child", stickerShape)
	
	pinJointSS = PinJoint2D.new()
	pinJointSS.set_global_position(get_global_position())
	pinJointSS.set_script(GameManager.pinJointScript)
	pinJointSS.set_node_a("../"+get_name())
	pinJointSS.set_node_b("../"+stickerShape.get_name())
	pinJointSS.set_bias(0)
	pinJointSS.set_softness(0)
	pinJointSS.set_name("pinJointSS"+get_name())
	get_parent().call_deferred("add_child", pinJointSS)

func pickup_closest_object():
	if nearbyStickables[facingDirection].size() >= 2:
		init_sticking_elements()
		pickup_object(nearbyStickables[facingDirection][1])
		var temp = nearbyStickables[facingDirection][1]
		nearbyStickables[facingDirection].remove_at(1)
		nearbyStickables[facingDirection].append(temp)
	elif nearbyStickables[-facingDirection].size() >= 2:
		init_sticking_elements()
		pickup_object(nearbyStickables[-facingDirection][1])
		var temp = nearbyStickables[-facingDirection][1]
		nearbyStickables[-facingDirection].remove_at(1)
		nearbyStickables[-facingDirection].append(temp)

func slower_enabled_timeout():
	gotMovement = false

func jump_disable_timeout():
	jumpAllowed = false
	jumpLooking = true

func _integrate_forces(_state):
	if isActive:
		if isFocused:
			checkAppliedForces()
			velocity = get_linear_velocity()
			#print(velocity)
		checkWallHit()
		
		if isFocused:
			if jumpCast.is_colliding() and jumpTimer.is_stopped() and not jumpAllowed and jumpLooking:
				if jumpCast.get_collider().is_in_group("jumpable"):
					jumpAllowed = true
			if jumpLeftCast.is_colliding():
				if jumpLeftCast.get_collider().is_in_group("jumpablewall") and not jumpAllowed and jumpLooking:
					jumpAllowed = true
			if jumpRightCast.is_colliding():
				if jumpRightCast.get_collider().is_in_group("jumpablewall") and not jumpAllowed and jumpLooking:
					jumpAllowed = true
		
		# Gravity lowered when on ground
		if groundCast:
			if groundCast.is_colliding():
				if groundCast.get_collider().is_in_group("jumpable"):
					if gravityOn:
						gravityOn = false
					if !(abs(get_gravity_scale() - 0.6) <= 0.00001) and !isBeingCaried:
						set_gravity_scale(0.6)
				else:
					if gravityOn:
						pass
					elif gravityTimer.is_stopped():
						gravityTimer.start()
			else:
				if gravityOn:
					pass
				elif gravityTimer.is_stopped():
					gravityTimer.start()
		if onme:
			onme = false

#func get_class()->String: return "MyMotileShape"

#func is_class(name:String)->bool:
#	return super.is_class(name) or (get_class() == name)

#func _process(delta):
#	pass
