extends Node2D
class_name Spawner

var sessionSkins:Dictionary : get = get_skins, set = set_skins

var defaultCamera:AdvancedCamera2D

var viewArea:Area2D
var viewCollasion:CollisionShape2D
var shapesInView:Dictionary # Keys are types. Values are array of objects. Value can be null.
var shapesInViewCounts:Dictionary # Keys are types. Values are integers. Value can be 0. Used for recipe checking.


var spawnPoint:Vector2 : set = set_spawn_point
var nextSpawns:Dictionary : get = get_next_spawns # key is name value is object
var selectedSpawn:String = "empty" : get = get_selected_spawn, set = set_selected_spawn
var ownedObjects:Array = []

var nextCraftables:Dictionary : get = get_next_craftables # key is name value is object
var selectedCraftable:String = "empty" : get = get_selected_craftable, set = set_selected_craftable
signal craftableCommunication(string)
var currentlyRunningPlaceChecks:int = 0


var fastPlacing:bool = false
var autoPlacing:bool = false
var recipeSnap

var focusedObject # Object spawner is controlling/interacting.
var previousObject # Previously focused and owned object. AKA Last object

signal spawnedSignal

func _ready():
	# await get_tree().idle_frame
	defaultCamera = AdvancedCamera2D.new()
	add_child(defaultCamera)
	defaultCamera.set_zoom(Vector2(2,2))
	viewArea = Area2D.new()
	viewArea.set_monitoring(true)
	viewCollasion = CollisionShape2D.new()
	var dummyRectShape = RectangleShape2D.new()
	dummyRectShape.set_size(Vector2(1920, 1080))
	viewCollasion.set_shape(dummyRectShape)
	viewArea.add_child(viewCollasion)
# warning-ignore:return_value_discarded
	viewArea.connect("body_entered",Callable(self,"_on_body_enter"))
# warning-ignore:return_value_discarded
	viewArea.connect("body_exited",Callable(self,"_on_body_exit"))
	self.add_child(viewArea)
	generate_next_spawns()
	generate_next_craftables()
	pass

func generate_next_spawns()->void: # Also keys for shapesInView dictionaries created here
	for key in GameManager.get_shapes().keys():
		if GameManager.get_shapes()[key] is Dictionary:
			var dict = GameManager.get_shapes()[key]
			for key2 in dict.keys():
				var shape = GameManager.get_shapes()[key][key2]
				if selectedSpawn == "empty":
					selectedSpawn = shape.get_name()
				nextSpawns[shape.get_name()] = calculate_next_object(shape.get_name(), shape.duplicate())
				shapesInView[shape.get_name()] = []
				shapesInViewCounts[shape.get_name()] = 0
		else:
			var shape = GameManager.get_shapes()[key]
			if selectedSpawn == "empty":
				selectedSpawn = shape.get_name()
			nextSpawns[shape.get_name()] = calculate_next_object(shape.get_name(), shape.duplicate())
			shapesInView[shape.get_name()] = []
			shapesInViewCounts[shape.get_name()] = 0
	#print(GameManager.get_shapes())
	pass

func generate_next_craftables()->void:
	for key in GameManager.get_craftables().keys():
		var craftable = GameManager.get_craftables()[key]
		if selectedCraftable == "empty":
			selectedCraftable = craftable.get_name()
		nextCraftables[craftable.get_name()] = calculate_next_object(craftable.get_name(), craftable.duplicate())
	#print(GameManager.get_craftables())
	pass

# warning-ignore:unused_argument
func calculate_next_object(shapeName:String, dummyObject:Object)->Object:
	return dummyObject


func spawn_object(shapeName:String)->void:
	print("Spawned object: "+shapeName)
	$Shapes.add_child(nextSpawns.get(shapeName), true)
	nextSpawns.get(shapeName).set_position(spawnPoint)
	nextSpawns.get(shapeName).set_owner($Shapes)
	nextSpawns.get(shapeName).set_owner_spawner(self)
	ownedObjects.append(nextSpawns.get(shapeName))
	#print(nextSpawns)
	nextSpawns[shapeName] = calculate_next_object(shapeName, GameManager.get_shape(shapeName).duplicate())
	#print(nextSpawns)
	emit_signal("spawnedSignal")

func place_building(craftable:MyCraftable, point)->void:
	var testCraftable = craftable.duplicate()
	GameManager.globalSessionMap.add_child(testCraftable)
	testCraftable.set_owner(GameManager.globalSessionMap)
	testCraftable.set_position(point)
	testCraftable.get_node("Occupation").add_to_group("occupied")
	pass

func test_craftable_communication_receive(message, object):
	if message == "can_be_placed":
		emit_signal("craftableCommunication", "job_done", self)
		if currentlyRunningPlaceChecks >= -10:
			place_building(get_next_craftables()[selectedCraftable].get_building_version(), object)
			pop_shapes(recipeSnap)
			emit_signal("craftableCommunication", "job_done", self)
		currentlyRunningPlaceChecks = -9999
	elif message == "cannot_be_placed":
		currentlyRunningPlaceChecks -= 1
	else:
		print_debug("Message via signal communicateSignal is invalid.")
		pass
	

func try_a_place(craftable:MyCraftable, point:Vector2):
	currentlyRunningPlaceChecks += 1
	var testCraftable = craftable.duplicate()
	GameManager.globalSessionMap.add_child(testCraftable)
	testCraftable.set_owner(GameManager.globalSessionMap)
	testCraftable.get_node("Sprite2D").set_visible(false)
	testCraftable.set_position(point)
# warning-ignore:return_value_discarded
	connect("craftableCommunication",Callable(testCraftable,"communication_receive"))
	emit_signal("craftableCommunication", "try_to_place", self)

func bundled_placement_trier(craftable:MyCraftable, offsetRange:Array, yOffset:int):
	for pos in offsetRange:
		try_a_place(craftable, Vector2(defaultCamera.get_position().x + pos, defaultCamera.get_position().y + yOffset))
		try_a_place(craftable, Vector2(defaultCamera.get_position().x - pos, defaultCamera.get_position().y + yOffset))

func find_fast_place(craftable:MyCraftable):
	for pos in range(0, 150, 50):
		if !fastPlacing:
			break
		bundled_placement_trier(craftable, range(pos, pos+50, 20), 0)
	return false

func find_auto_place(craftable:MyCraftable):
	for pos in range(0, 960, craftable.return_width()*6):
		if !autoPlacing:
			break
		bundled_placement_trier(craftable, range(pos, pos+craftable.return_width()*6, craftable.return_width()/2), 0)
	for pos in range(0, -960, -craftable.return_width()*6):
		if !autoPlacing:
			break
		bundled_placement_trier(craftable, range(pos, pos-craftable.return_width()*6, -craftable.return_width()/2), 0)
	for pos in range(0, 960, craftable.return_width()*6):
		if !autoPlacing:
			break
		bundled_placement_trier(craftable, range(pos, pos+craftable.return_width()*6, craftable.return_width()/2), -1080)
	for pos in range(0, -960, -craftable.return_width()*6):
		if !autoPlacing:
			break
		bundled_placement_trier(craftable, range(pos, pos-craftable.return_width()*6, -craftable.return_width()/2), -1080)
	for pos in range(960, 1920, craftable.return_width()*6):
		if !autoPlacing:
			break
		bundled_placement_trier(craftable, range(pos, pos+craftable.return_width()*6, craftable.return_width()/2), 0)
	for pos in range(-960, -1920, -craftable.return_width()*6):
		if !autoPlacing:
			break
		bundled_placement_trier(craftable, range(pos, pos-craftable.return_width()*6, -craftable.return_width()/2), 0)
	for pos in range(960, 1920, craftable.return_width()*6):
		if !autoPlacing:
			break
		bundled_placement_trier(craftable, range(pos, pos+craftable.return_width()*6, craftable.return_width()/2), -1080)
	for pos in range(-960, -1920, -craftable.return_width()*6):
		if !autoPlacing:
			break
		bundled_placement_trier(craftable, range(pos, pos-craftable.return_width()*6, -craftable.return_width()/2), -1080)
	return false

func get_recipe_snap(craftable:MyCraftable)->Array:
	var dummyArray = []
	for item in craftable.get_recipe().keys():
		for itemNumber in range(0, craftable.get_recipe()[item]):
			dummyArray.append(shapesInView[item][itemNumber])
	return dummyArray

func pop_shapes(shapeArray:Array)->void:
	for shape in shapeArray:
		shape.queue_free()

func fast_craft():
	if selectedCraftable != "empty":
		if get_next_craftables()[selectedCraftable].get_can_craft():
			emit_signal("craftableCommunication", "job_done", self)
			if !fastPlacing:
				fastPlacing = true
				autoPlacing = false
				recipeSnap = get_recipe_snap(get_next_craftables()[selectedCraftable])
				var dummyFunction = find_fast_place(get_next_craftables()[selectedCraftable].get_building_version())
				currentlyRunningPlaceChecks = 0
				while fastPlacing and dummyFunction:
					if currentlyRunningPlaceChecks <= 1:
						dummyFunction = dummyFunction.resume()
					if currentlyRunningPlaceChecks <= -900:
						break
					await get_tree().idle_frame
				fastPlacing = false
			else:
				fastPlacing = false
	pass

func auto_craft():
	if selectedCraftable != "empty":
		if get_next_craftables()[selectedCraftable].get_can_craft():
			emit_signal("craftableCommunication", "job_done", self)
			if !autoPlacing:
				autoPlacing = true
				fastPlacing = false
				recipeSnap = get_recipe_snap(get_next_craftables()[selectedCraftable])
				var dummyFunction = find_auto_place(get_next_craftables()[selectedCraftable].get_building_version())
				currentlyRunningPlaceChecks = 0
				while autoPlacing and dummyFunction:
					if currentlyRunningPlaceChecks <= 1:
						dummyFunction = dummyFunction.resume()
					if currentlyRunningPlaceChecks <= -900:
						break
					await get_tree().idle_frame
				autoPlacing = false
				
			else:
				autoPlacing = false
	pass

func check_craftability(craftable:MyCraftable)->bool:
	for shapeToCompare in craftable.get_recipe().keys():
		if craftable.get_recipe()[shapeToCompare] > shapesInViewCounts[shapeToCompare]:
			return false
	return true

func check_craftable_craftabilities()->void:
	for craftable in get_next_craftables().values():
		if check_craftability(craftable):
			craftable.can_craft()
		else:
			craftable.cant_craft()

func register_shape_to_vision(shape:RigidBody2D, shapeType:String)->void:
	shapesInView[shapeType].append(shape)
	shapesInViewCounts[shapeType] += 1

func deregister_shape_to_vision(shape:RigidBody2D, shapeType:String)->void:
	shapesInView[shapeType].erase(shape)
	shapesInViewCounts[shapeType] -= 1

func _on_body_enter(body):
	if body.is_class("MyShape"):
		if body.has_method("get_owner_spawner"):
			if body.get_owner_spawner() == self:
				if body.get_name().begins_with("@"):
					register_shape_to_vision(body, body.get_name().left(body.get_name().rfind("@")).right(1))
				else:
					register_shape_to_vision(body, body.get_name())
		else:
			print_debug("A shape that does not have get_owner_spawner method entered viewArea: "+body.to_string())

func _on_body_exit(body):
	if body.is_class("MyShape"):
		if body.has_method("get_owner_spawner"):
			if body.get_owner_spawner() == self:
				if body.get_name().begins_with("@"):
					deregister_shape_to_vision(body, body.get_name().left(body.get_name().rfind("@")).right(1))
				else:
					deregister_shape_to_vision(body, body.get_name())
		else:
			print_debug("A shape that does not have get_owner_spawner method exited viewArea: "+body.to_string())

func view_area_follow(delta)->void:
	viewArea.set_global_position(lerp(viewArea.get_global_position(), focusedObject.get_global_position(), delta*10))

func focus_on_object(object):
	if focusedObject == object:
		return
	if focusedObject != null:
		if does_own(focusedObject):
			previousObject = focusedObject
		emit_signal("focusSignal", false)
		disconnect("focusSignal",Callable(focusedObject,"_focus_signal_receive"))
	focusedObject = object
# warning-ignore:return_value_discarded
	connect("focusSignal",Callable(object,"_focus_signal_receive"))
	emit_signal("focusSignal", true)
	defaultCamera.set_followed_object(object)

func does_own(object)->bool:
	if object in ownedObjects:
		return true
	else:
		return false
	
func get_next_object()->Object:
	var i:int = 0
	if ownedObjects.size() == 0:
		print("You do not own any objects.")
		return null
	if focusedObject == null:
		return ownedObjects[0]
	while i < ownedObjects.size() - 1:
		if ownedObjects[i] == focusedObject:
			return ownedObjects[i + 1]
		i += 1
	if ownedObjects[ownedObjects.size() - 1] == focusedObject:
		return ownedObjects[0]
	else:
		if previousObject != null:
			i = 0
			while i < ownedObjects.size() - 1:
				if ownedObjects[i] == previousObject:
					return ownedObjects[i + 1]
				i += 1
			if ownedObjects[ownedObjects.size() - 1] == previousObject:
				return ownedObjects[0]
		if ownedObjects.size() > 0:
			return ownedObjects[0]
		else:
			print_debug("Problem getting next object of spawner: ", self.get_name())
			return null
		
func get_previous_object()->Object:
	var i:int = ownedObjects.size() - 1
	if ownedObjects.size() == 0:
		print("You do not own any objects.")
		return null
	if focusedObject == null:
		return ownedObjects[ownedObjects.size() - 1]
	while i > 0:
		if ownedObjects[i] == focusedObject:
			return ownedObjects[i - 1]
		i -= 1
	if ownedObjects[0] == focusedObject:
		return ownedObjects[ownedObjects.size() - 1]
	else:
		if previousObject != null:
			i = ownedObjects.size() - 1
			while i > 0:
				if ownedObjects[i] == previousObject:
					return ownedObjects[i - 1]
				i -= 1
			if ownedObjects[0] == previousObject:
				return ownedObjects[ownedObjects.size() - 1]
		if ownedObjects.size() > 0:
			return ownedObjects[ownedObjects.size() - 1]
		else:
			print_debug("Problem getting next object of spawner: ", self.get_name())
			return null

func set_selected_spawn(name:String)->void:
	selectedSpawn = name

func get_selected_spawn()->String:
	return selectedSpawn

func set_selected_craftable(name:String)->void:
	selectedCraftable = name

func get_selected_craftable()->String:
	return selectedCraftable

func set_spawn_point(position:Vector2)->void:
	spawnPoint = position

func get_next_spawns()->Dictionary:
	return nextSpawns

func get_next_craftables()->Dictionary:
	return nextCraftables

# warning-ignore:unused_argument
func set_skins(dummy):
	pass
	
func get_skins():
	return sessionSkins


func _physics_process(delta):
	if !nextCraftables.is_empty():
		check_craftable_craftabilities()
	if focusedObject != null:
		view_area_follow(delta)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
