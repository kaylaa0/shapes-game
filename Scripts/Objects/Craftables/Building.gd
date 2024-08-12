extends "Craftable.gd"
class_name MyBuilding

# Every building scene must have a sprite, and a node2d named FloorRays which has rays it is touching at ground.
# Also must have an area2d name Occupation which will define it's occupation shape. It's group must have occupied name. Monitoring disabled, pickable disabled, priority 100, layer and mask 6.

var buildableCheckState:bool = false
var checkComplete:bool = false
var requiredRay = 1 # Should be manually set in object init, can be lower than FloorRays but not higher.
var currentPlacePoint:Vector2 = Vector2(0,0)
var placePoints:Array = []

var Occupied:bool = false
var ideledFrame:bool = false

var rayIgnoreList = []

signal communicateSignal(message, variable)

func _ready():
# warning-ignore:return_value_discarded
	get_node("Occupation").connect("area_entered",Callable(self,"_on_area_enter"))
	pass # Replace with function body.

func return_width()->int:
	if get_node("FloorRays").get_child_count() <= 1:
		return 100 # This is default min width.
	else:
		var positions = []
		for dummyRay in get_node("FloorRays").get_children():
			positions.append(dummyRay.get_position().x)
		if positions.max()-positions.min() >= 100:
			return positions.max()-positions.min()
		else:
			return 100

func check_a_ray(dummyRay:RayCast2D, world):
	var ray = world.intersect_ray(dummyRay.get_global_position(), dummyRay.get_global_position()+dummyRay.get_target_position(), rayIgnoreList)
	if(!ray.is_empty()):
		if ray.collider.is_in_group("buildable_floor"):
			placePoints.append(ray.position)
		elif ray.collider.is_in_group("buildable_canceler"):
			pass
		else:
			rayIgnoreList.append(ray.collider)
			check_a_ray(dummyRay, world)

func communication_receive(message:String, object):
	if message == "try_to_place":
		if !self.buildableCheckState:
# warning-ignore:return_value_discarded
			connect("communicateSignal",Callable(object,"test_craftable_communication_receive"))
			self.get_node("Occupation").set_monitoring(true)
			self.placePoints = []
			self.ideledFrame = false
			self.buildableCheckState = true
	if message == "job_done":
		object.disconnect("craftableCommunication",Callable(self,"communication_receive"))
		self.buildableCheckState = false
		self.checkComplete = false
		self.get_node("Occupation").set_monitoring(false)
		currentPlacePoint = Vector2(0,0)
		self.placePoints = []
		self.ideledFrame = false
		self.queue_free()

func compare_points(point1, point2)->bool:
	if point1.y > point2.y-10:
		if point1.y < point2.y+10:
			return true
		else:
			return false
	else:
		return false

func average_points(point1, point2):
	return Vector2((point1.x+point2.x)/2, (point1.y+point2.y)/2)

func get_place_point()->bool:
	var extremePoints = {}
	for point in self.placePoints:
		if extremePoints.is_empty():
			extremePoints[point] = 1
			
		else:
			for pointCheck in extremePoints.keys():
				if compare_points(point, pointCheck):
					var dummyInt = extremePoints[pointCheck]
					extremePoints.erase(pointCheck)
					extremePoints[average_points(point,pointCheck)] = dummyInt+1
				else:
					extremePoints[point] = 1
	for point in extremePoints.keys():
		if extremePoints[point] >= requiredRay:
			currentPlacePoint = point
			return true
	return false

func is_current_place_occupied()->bool:
	return self.Occupied

func _on_area_enter(area:Area2D):
	if area.is_in_group("occupied"):
		self.Occupied = true

func _physics_process(_delta):
	if self.buildableCheckState:
		if checkComplete:
			if !is_current_place_occupied():
				if get_place_point():
					if ideledFrame:
						emit_signal("communicateSignal", "can_be_placed", currentPlacePoint)
						self.queue_free()
					else:
						self.set_global_position(currentPlacePoint)
						ideledFrame = true
				else:
					emit_signal("communicateSignal", "cannot_be_placed", null)
					self.queue_free()
			else:
				emit_signal("communicateSignal", "cannot_be_placed", null)
				self.queue_free()
		else:
			var world = PhysicsServer2D.space_get_direct_state(get_world_2d().space)
			for dummyRay in get_node("FloorRays").get_children():
				check_a_ray(dummyRay, world)
			checkComplete = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
