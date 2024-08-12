extends Node2D
class_name MyCraftable

var recipe:Dictionary : get = get_recipe, set = set_recipe # Keys shape names as string, values are amount as integer.
var basicVersion:Node2D : get = get_basic_version, set = set_basic_version # Pointer to basic version. When a basic version initialized it fills it's own variables.
var buildingVersion:Node2D : get = get_building_version, set = set_building_version # Pointer to building version. When a building initialized from basic version copies from basic version.

func _ready():
	pass # Replace with function body.

func to_simpleton():
	for child in self.get_children():
		if !(child.get_name() == "Sprite2D"):
			child.queue_free()
	self.set_process(false)
	self.set_process_input(false)
	self.set_process_internal(false)
	self.set_process_unhandled_input(false)
	self.set_process_unhandled_key_input(false)
	self.set_physics_process(false)
	self.set_physics_process_internal(false)

func set_recipe(dummyRecipe:Dictionary)->void:
	if recipe.is_empty():
		recipe = dummyRecipe
	else:
		#print_debug("Attempt to override recipe of: "+self.to_string()+" from "+String(recipe)+" to "+String(dummyRecipe))
		print_debug("error")
		
func get_recipe()->Dictionary:
	return recipe

#func get_class()->String: return "MyCraftable"

#func is_class(name:String)->bool:
#	return super.is_class(name) or (get_class() == name)

func set_basic_version(dummyBasic:Node2D)->void:
	if basicVersion == null:
		basicVersion = dummyBasic
	else:
		print_debug("Attempt to override basic version of: "+self.to_string()+" from "+basicVersion.to_string()+" to "+dummyBasic.to_string())

func get_basic_version()->Node2D:
	return basicVersion

func set_building_version(dummyBuilding:Node2D)->void:
	if buildingVersion == null:
		buildingVersion = dummyBuilding
	else:
		print_debug("Attempt to override building version of: "+self.to_string()+" from "+buildingVersion.to_string()+" to "+dummyBuilding.to_string())

func get_building_version()->Node2D:
	return buildingVersion

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
