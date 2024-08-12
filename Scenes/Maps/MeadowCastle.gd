extends SessionMap


var circleDummy = preload("res://Scenes/Objects/Shapes/Circle.tscn").instantiate()
var circle2Dummy = preload("res://Scenes/Objects/Shapes/Circle.tscn").instantiate()
var circle3Dummy = preload("res://Scenes/Objects/Shapes/Circle.tscn").instantiate()
var triangleDummy = preload("res://Scenes/Objects/Shapes/Triangle.tscn").instantiate()
var squareDummy = preload("res://Scenes/Objects/Shapes/Square.tscn").instantiate()

var summonTotemDummy = preload("res://Scenes/Objects/Craftables/Basics/BasicSummonTotem.tscn").instantiate()
var shapeLauncherDummy = preload("res://Scenes/Objects/Craftables/Basics/BasicShapeLauncher.tscn").instantiate()
var summonTotem2Dummy = preload("res://Scenes/Objects/Craftables/Basics/BasicSummonTotem.tscn").instantiate()
var summonTotem3Dummy = preload("res://Scenes/Objects/Craftables/Basics/BasicSummonTotem.tscn").instantiate()
var summonTotem4Dummy = preload("res://Scenes/Objects/Craftables/Basics/BasicSummonTotem.tscn").instantiate()
var summonTotem5Dummy = preload("res://Scenes/Objects/Craftables/Basics/BasicSummonTotem.tscn").instantiate()
var summonTotem6Dummy = preload("res://Scenes/Objects/Craftables/Basics/BasicSummonTotem.tscn").instantiate()
var summonTotem7Dummy = preload("res://Scenes/Objects/Craftables/Basics/BasicSummonTotem.tscn").instantiate()
var summonTotem8Dummy = preload("res://Scenes/Objects/Craftables/Basics/BasicSummonTotem.tscn").instantiate()
var summonTotem9Dummy = preload("res://Scenes/Objects/Craftables/Basics/BasicSummonTotem.tscn").instantiate()
var summonTotem10Dummy = preload("res://Scenes/Objects/Craftables/Basics/BasicSummonTotem.tscn").instantiate()
var summonTotem11Dummy = preload("res://Scenes/Objects/Craftables/Basics/BasicSummonTotem.tscn").instantiate()

func _ready():
	
	circle2Dummy.set_name("Circle2")
	circle3Dummy.set_name("Circle3")
	summonTotem2Dummy.set_name("summonTotem2")
	summonTotem3Dummy.set_name("summonTotem3")
	summonTotem4Dummy.set_name("summonTotem4")
	summonTotem5Dummy.set_name("summonTotem5")
	summonTotem6Dummy.set_name("summonTotem6")
	summonTotem7Dummy.set_name("summonTotem7")
	self.shapesInScene = {1:circleDummy, 2:{1:triangleDummy, 2:circle2Dummy}, 3:squareDummy, 4:circle3Dummy}
	self.craftablesInScene = {1:summonTotemDummy, 2:shapeLauncherDummy, 8:summonTotem2Dummy, 3:summonTotem3Dummy, 4:summonTotem4Dummy, 5:summonTotem5Dummy, 6:summonTotem6Dummy, 
	7:summonTotem7Dummy}
	set_global_session_shapes()
	set_global_session_craftables()
	await get_tree().process_frame
	await get_tree().physics_frame
	GameManager.mapLoaded = true
	
	super()
		




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	pass
